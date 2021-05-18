import 'dart:convert';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:flutter/material.dart';

class SearchLocation extends StatefulWidget {
  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  final _repository = Repository();
  final _prefManager = PrefManager();
  final _controller = TextEditingController();
  List results;
  bool isLoading = false;

  List favoritePlaces = [];
  List recentPlaces = [];

  @override
  void initState() {
    _prefManager.get("favorite_places", "{}").then((source) {
      Map response = json.decode(source);
      if (response.containsKey("data")) {
        setState(() {
          favoritePlaces = response["data"];
        });
      }
    });
    _prefManager.get("recent_places", "{}").then((source) {
      Map response = json.decode(source);
      if (response.containsKey("data")) {
        setState(() {
          recentPlaces = response["data"];
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.api("Search for your location")),
      ),
      body: Column(
        children: <Widget>[
          getSearchWidget(),
//          getAddFavoriteWidget(),
          Flexible(
            child: getScrollableContent(),
          ),
        ],
      ),
    );
  }

  Widget getScrollableContent() {
    if (_controller.text.length < 3) {
      if (favoritePlaces.length == 0 && recentPlaces.length == 0) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.explore,
                  size: 42,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  lang.api("Start typing to find a new place"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        );
      } else {
        return ListView(
          children: <Widget>[
            getFavorite(),
            getRecentPlaces(),
          ],
        );
      }
    } else {
      return getSearchResult();
    }
  }

  Widget getSearchWidget() {
    return Container(
      child: TextFormField(
        controller: _controller,
        onChanged: doSearch,
        decoration: InputDecoration(
          hintText: lang.api("Search for place"),
          contentPadding: EdgeInsets.all(18),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  void doSearch(String text) async {
    if (text.length >= 3) {
      results = [];
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> response = await _repository.getPlaces(text);
      isLoading = false;
      if (response.containsKey("status") && response["status"] == "OK") {
        results = response["results"];
      }
    }
    setState(() {});
  }

  Widget getSearchResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          color: Colors.grey[300],
          padding: EdgeInsets.all(16),
          child: Text(
            lang.api("Search result"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Flexible(
          child: isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      LoadingWidget(
                        size: 84,
                        useLoader: true,
                      ),
                    ],
                  ),
                )
              : results.length == 0
                  ? Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.error_outline,
                              size: 42,
                              color: Colors.red,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              lang.api("No data found."),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, index) {
                        return Divider(
                          height: 2,
                        );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        Map item = results[index];
                        int itemIndex = 0;
                        bool isFavorite = false;
                        favoritePlaces.forEach((favoritePlace) {
                          if (favoritePlace["id"] == item["id"]) {
                            itemIndex = favoritePlaces.indexOf(favoritePlace);
                            isFavorite = true;
                          }
                        });
                        return buildItem(item, isFavorite, itemIndex,
                            Theme.of(context).primaryColor);
                      },
                    ),
        ),
      ],
    );
  }

  Widget buildItem(Map item, bool isFavorite, int itemIndex, Color color,
      [VoidCallback onClear]) {
    return getPlaceItem(
        name: item["name"],
        address: item["formatted_address"],
        favoriteIcon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: color,
        ),
        onLocationClicked: () async {
//        int itemIndex = 0;
          bool exist = false;
          recentPlaces.forEach((recentPlace) {
            if (recentPlace["id"] == item["id"]) {
              exist = true;
            }
          });
          if (!exist) {
            recentPlaces.add(item);
            await _prefManager.set(
                "recent_places",
                json.encode({
                  "data": recentPlaces,
                }));
          }
          Navigator.of(context).pop(item);
        },
        onFavoriteClicked: () async {
//        print("isFavorite: $isFavorite");
          if (isFavorite) {
            favoritePlaces.removeAt(itemIndex);
          } else {
            favoritePlaces.add(item);
          }
          setState(() {});
          await _prefManager.set(
              "favorite_places",
              json.encode({
                "data": favoritePlaces,
              }));
        },
        onClear: onClear);
  }

  Widget getFavorite() {
    if (favoritePlaces.length == 0) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          color: Colors.grey[300],
          padding: EdgeInsets.all(16),
          child: Text(
            lang.api("Favorite places"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.separated(
          primary: false,
          shrinkWrap: true,
          itemCount: favoritePlaces.length,
          separatorBuilder: (_, index) {
            return Divider(
              height: 2,
            );
          },
          itemBuilder: (BuildContext context, int index) {
            Map item = favoritePlaces[index];
            return buildItem(item, true, index, Theme.of(context).primaryColor);
          },
        ),
      ],
    );
  }

  Widget getRecentPlaces() {
    if (recentPlaces.length == 0) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          color: Colors.grey[300],
          padding: EdgeInsets.all(16),
          child: Text(
            lang.api("RECENT LOCATION"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.separated(
          primary: false,
          shrinkWrap: true,
          itemCount: recentPlaces.length,
          separatorBuilder: (_, index) {
            return Divider(
              height: 2,
            );
          },
          itemBuilder: (BuildContext context, int index) {
            Map item = recentPlaces[index];
            int itemIndex = 0;
            bool isFavorite = false;
            favoritePlaces.forEach((favoritePlace) {
              if (favoritePlace["id"] == item["id"]) {
                itemIndex = favoritePlaces.indexOf(favoritePlace);
                isFavorite = true;
              }
            });
            return buildItem(item, isFavorite, itemIndex, Colors.grey, () {
              setState(() {
                recentPlaces.removeAt(index);
              });
            });
          },
        ),
      ],
    );
  }

  Widget getPlaceItem(
      {@required String name,
      @required String address,
      @required Icon favoriteIcon,
      @required VoidCallback onFavoriteClicked,
      @required VoidCallback onLocationClicked,
      VoidCallback onClear}) {
    return Container(
      child: Row(
        children: <Widget>[
          IconButton(icon: favoriteIcon, onPressed: onFavoriteClicked),
          Expanded(
            child: InkWell(
              onTap: onLocationClicked,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      name ?? "",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      address ?? "",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          onClear == null
              ? Container()
              : IconButton(
                  icon: Icon(Icons.close),
                  color: Colors.grey,
                  onPressed: onClear,
                ),
        ],
      ),
    );
  }
}

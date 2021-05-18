import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/search/IdleWidget.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/home/home_widget/search_box_widget.dart';
import 'package:afandim/view/home/home_widget/search_page.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _repo = Repository();
  bool isLoading = true;
  List list = [];
  String message;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  init() async {
    setState(() {
      isLoading = true;
      list = [];
    });
    Map<String, dynamic> response = await _repo.getRecentSearch();
    isLoading = false;
    if (response.containsKey("code") && response["code"] == 1) {
      list = response["details"]["data"];
    } else {
      message = response["msg"];
    }
    setState(() {});
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          lang.api("Search"),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: RefreshIndicator(
            onRefresh: () async {
              await init();
              return;
            },
            child: ListView(
              padding: EdgeInsets.only(top: 8),
              children: <Widget>[
                SearchBox(
                  normalText:
                      lang.api("Search for restaurant, cuisine or food"),
                  title: "",
                  onSearchClicked: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return SearchPage(
                          title: lang
                              .api("Search for restaurant, cuisine or food"),
                          searchType: SearchType.MerchantFood,
                        );
                      }),
                    );
                    init();
                  },
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          lang.api("Recent Searches"),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FlatButton(
                        child: Text(lang.api("CLEAR")),
                        textColor: Theme.of(context).primaryColor,
                        onPressed: list.isEmpty
                            ? null
                            : () async {
                                clearAll();
                              },
                      ),
                    ],
                  ),
                ),
                getList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  clearAll([bool check = true]) async {
    bool delete = true;
    if (check) {
      delete = await showCustomErrorDialog(lang.api("Clear Recent Search"),
          lang.api("Are you sure?"), lang.api("Yes"));
    }
    if (delete) {
      showLoadingDialog(lang.api("loading"));
      Map<String, dynamic> response = await _repo.clearRecentSearches();
      Navigator.of(context).pop();
      if (!response.containsKey("code") || response["code"] != 1) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.api("failed deleting recent searches"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            action: SnackBarAction(
                label: lang.api("Retry"),
                onPressed: () {
                  clearAll(false);
                }),
          ),
        );
      } else {
        setState(() {
          list = [];
        });
      }
    }
  }

  Widget getList() {
    if (isLoading) {
      return Container(
        height: 350,
        child: LoadingWidget(
          message: lang.api("loading"),
          useLoader: true,
          size: 82.0,
        ),
      );
    } else {
      if (list.isEmpty) {
        return Container(
          height: 350,
          child: IdleWidget(),
        );
      } else {
        return listView();
      }
    }
  }

  Widget listView() {
    return ListView.separated(
        primary: false,
        shrinkWrap: true,
        itemCount: list.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 2,
            color: Colors.grey,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return SearchPage(
                    searchText: list[index]["search_string"],
                    title: lang.api("Search for restaurant, cuisine or food"),
                    searchType: SearchType.MerchantFood,
                  );
                }),
              );
              init();
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(list[index]["search_string"]),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

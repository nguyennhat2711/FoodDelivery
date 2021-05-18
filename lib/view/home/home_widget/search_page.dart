import 'dart:convert';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/circle_image.dart';
import 'package:afandim/custom_widget/custom_rating_bar.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/search/IdleWidget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/home/home_widget/category_items.dart';
import 'package:afandim/view/home/home_widget/services_list.dart';
import 'package:afandim/view/restaurant_details/restaurant_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

enum SearchType { MerchantName, MerchantFood, FoodCategory }

class SearchPage extends StatefulWidget {
  final String title;
  final String searchText;
  final String merchantId;
  final SearchType searchType;
//  final bool searchByName;
  const SearchPage({
    Key key,
    @required this.title,
    this.searchText,
    this.searchType = SearchType.MerchantName,
    this.merchantId,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  bool isLoading = false;
  List list;
  String message;
  final _repo = Repository();

  @override
  void initState() {
    super.initState();
    if (widget.searchText != null) {
      _controller.text = widget.searchText;
      doSearch(widget.searchText);
    }
  }

  @override
  void dispose() {
    closeRepo();
    super.dispose();
  }

  closeRepo() {
    if (_repo != null) {
      _repo.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.api("Search"),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      doSearch(_controller.text);
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: (text) {
                        if (text.length >= 3) {
                          doSearch(text);
                        }
                      },
                      onFieldSubmitted: doSearch,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 0, bottom: 11, top: 11, right: 15),
                        hintText: widget.title,
                      ),
                    ),
                  ),
                  _controller.text.isEmpty
                      ? Container()
                      : IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            _controller.clear();
                            list = null;
                            setState(() {});
                          },
                        ),
                ],
              ),
            ),
            Expanded(
              child: getBody(),
            ),
          ],
        ),
      ),
    );
  }

  void doSearch(String text) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response;

    switch (widget.searchType) {
      case SearchType.MerchantName:
        response = await _repo.searchByMerchantName(text);
        break;
      case SearchType.MerchantFood:
        response = await _repo.searchMerchantFood(text);
        break;
      case SearchType.FoodCategory:
        response = await _repo.searchFoodCategory(widget.merchantId, text);
        break;
    }
    isLoading = false;
    if (response.containsKey("code") && response["code"] == 1) {
      switch (widget.searchType) {
        case SearchType.MerchantName:
          list = response["details"]["list"];
          break;
        case SearchType.MerchantFood:
          list = response["details"]["data"];
          break;
        case SearchType.FoodCategory:
          list = response["details"]["data"];
          break;
      }
    } else {
      message = response["msg"];
      list = [];
    }
    setState(() {});
  }

  Widget getBody() {
    if (isLoading) {
      return Container(
        child: LoadingWidget(
          message: lang.api("loading"),
          useLoader: true,
          size: 82.0,
        ),
      );
    } else {
      if (list == null) {
        return IdleWidget();
      } else {
        if (list.length > 0) {
          return getList();
        } else {
          return EmptyWidget(
            message: message,
            size: 128.0,
          );
        }
      }
    }
  }

  Widget getList() {
    return ListView.separated(
      itemCount: list.length,
      padding: EdgeInsets.all(6),
      separatorBuilder: (_, index) {
        return Divider(
          height: 2,
          color: Colors.grey,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        Map item = list[index];
        switch (widget.searchType) {
          case SearchType.MerchantName:
            return getItemName(item);
            break;
          case SearchType.MerchantFood:
            return getItemFood(item);
            break;
          case SearchType.FoodCategory:
            return getItemCategory(item);
            break;
        }
        return Container();
      },
    );
  }

  Widget getItemName(var item) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return MerchantDetailsView(
              merchantId: item["merchant_id"],
            );
          }),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
//          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleImage(
              child: CachedNetworkImage(
                imageUrl: item["logo"],
                placeholder: (context, text) {
                  return Image(
                    image: AssetImage("assets/images/logo-placeholder.png"),
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  );
                },
                width: 46,
                height: 46,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Html(
                    data: item["restaurant_name"],
                    style: {
                      ".highlight": Style(
                        color: Theme.of(context).primaryColor,
                      ),
                      "*": Style(
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                      ),
                    },
                  ),
                  Text(
                    item.cuisine,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      CustomRatingBar(
                        isInt: false,
                        rating: double.parse("${item.rating.ratings}"),
                        onChanged: (value) {},
                        size: 12,
                      ),
                      SizedBox(width: 8),
                      Text("${item["rating"]["votes"]}"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemCategory(var item) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return CategoryItems(
              item: item,
            );
          }),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleImage(
              child: CachedNetworkImage(
                imageUrl: item["photo"],
                placeholder: (context, text) {
                  return Image(
                    image: AssetImage("assets/images/logo-placeholder.png"),
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  );
                },
                width: 46,
                height: 46,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    json.decode(
                        item["category_name_trans"])[lang.getLanguageText()],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    json.decode(item["category_description_trans"])[
                        lang.getLanguageText()],
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemFood(var item) {
    return InkWell(
      onTap: () {
        if (item["restaurant"] == "cuisine") {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return ServicesList(
                cuisineId: "${item["id"]}",
                title: "${item["category"]}",
                searchType: "byCuisine",
              );
            }),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return MerchantDetailsView(
                merchantId: item["merchant_id"],
              );
            }),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleImage(
              child: CachedNetworkImage(
                imageUrl: item["logo"],
                placeholder: (context, text) {
                  return Image(
                    image: AssetImage("assets/images/logo-placeholder.png"),
                    width: 46,
                    fit: BoxFit.cover,
                    height: 46,
                  );
                },
                width: 46,
                fit: BoxFit.cover,
                height: 46,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Html(
                    data: item["title"],
                    style: {
                      ".highlight": Style(
                        color: Theme.of(context).primaryColor,
                      ),
                    },
                  ),
                  Text(
                    item["sub_title"],
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

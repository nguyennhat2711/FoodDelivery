import 'package:afandim/core/services/repository.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/helper/utils.dart';
import 'package:afandim/model/search_merchant.dart';
import 'package:afandim/view/home/home_widget/home_header_widget.dart';
import 'package:afandim/view/home/home_widget/services_list.dart';
import 'package:afandim/view/restaurant_details/restaurant_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../loading_widget.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final _repository = Repository();
  bool isLoading = true;
  SearchMerchantDart searchMerchantDart;
  List<SearchMerchantList> list = [];

  String searchType = "favorites";
  int paginateTotal = 1;
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
    bool forceRefresh = await PrefManager().get("forceRefresh", false);
    Map<String, dynamic> response = await _repository.searchMerchant({
      "with_distance": "1",
      "sort_by": "distance",
      "search_type": searchType
    });
    isLoading = false;
    if (forceRefresh) {
      await PrefManager().set("forceRefresh", false);
    }
    if (response.containsKey("success") && response["success"]) {
      searchMerchantDart = SearchMerchantDart.fromJson(response);
      list = searchMerchantDart.details.searchMerchantList;
      paginateTotal = searchMerchantDart.details.paginateTotal;
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: list.isEmpty && !isLoading
          ? Container()
          : Column(
              children: <Widget>[
                HomeHeader(
                  title: lang.api("Favorites Restaurants"),
                  subTitle:
                      lang.api("These ones have a special place in your heart"),
                  showViewAll: list.length != 0,
                  onViewAllTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return ServicesList(
                          title: lang.api("Favorites Restaurants"),
                          list: list,
                          paginateTotal: paginateTotal,
                          searchType: searchType,
                        );
                      }),
                    );
                  },
                ),
                getListView(),
              ],
            ),
    );
  }

  Widget getListView() {
    if (isLoading) {
      return LoadingWidget();
    } else {
      if (list.length == 0) {
        return Container();
      } else {
        return listView();
      }
    }
  }

  Widget listView() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          SearchMerchantList item = list[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return MerchantDetailsView(
                      searchMerchantList: item,
                      merchantId: item.merchantId,
                    );
                  }),
                );
              },
              child: Container(
                constraints: BoxConstraints(minWidth: 240),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: CachedNetworkImage(
                            imageUrl: item.logo,
                            width: 70,
                            height: 70,
                            placeholder: (context, url) {
                              return Image(
                                image: AssetImage(
                                    "assets/images/category-placeholder.png"),
                                width: 70,
                                height: 70,
                                fit: BoxFit.contain,
                              );
                            },
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.api(item.restaurantName),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            lang.api(item.cuisine),
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).primaryColor,
                              ),
                              Text(
                                "${customRound(double.parse("${item.distance}"), 1)} ${lang.api("KM")}",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

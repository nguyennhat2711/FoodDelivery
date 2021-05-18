import 'dart:math';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/grey_button.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/model/search_merchant.dart';
import 'package:afandim/view/helper/sort_by.dart';
import 'package:afandim/view/home/home_widget/all_restaurant_card_widget.dart';
import 'package:afandim/view/home/home_widget/search_page.dart';
import 'package:afandim/view/merchant/merchant_maps.dart';
import 'package:afandim/view/specific_merchant/widget/filter_by.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_villains/villain.dart';

class ServicesList extends StatefulWidget {
  final List<SearchMerchantList> list;
  SearchMerchantDart searchMerchantDart;

  final String cuisineId;
  final String title;
  final String searchType;
  final int paginateTotal;
  final dynamic item;
  final Map<String, dynamic> extraFields;

  ServicesList({
    Key key,
    this.list,
    this.searchMerchantDart,
    this.cuisineId,
    @required this.title,
    @required this.searchType,
    this.item,
    this.paginateTotal,
    this.extraFields,
  }) : super(key: key);

  @override
  _ServicesListState createState() => _ServicesListState(paginateTotal);
}

class _ServicesListState extends State<ServicesList> {
  final _repository = Repository();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool loadingMore = false;
  List<SearchMerchantList> list = [];
  String message;
  Map sortBySelected = {"id": "distance", "name": lang.api("Distance")};
  bool isAsc = false;
  ScrollController controller;

  Map filterBy = {};
  int initPage = 1;
  int paginateTotal;

  _ServicesListState(this.paginateTotal);

  @override
  void initState() {
    super.initState();
    controller = new ScrollController()..addListener(_scrollListener);
    init();
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Column(
        children: [
          getTop(),
          widget.item != null
              ? Container(
                  child: Card(
                    child: InkWell(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24.0)),
                            child: Hero(
                              tag: widget.item["banner"],
                              child: CachedNetworkImage(
                                imageUrl: widget.item["banner"],
                                fit: BoxFit.fitWidth,
                                width: MediaQuery.of(context).size.width,
                                height: (MediaQuery.of(context).size.width / 2),
                                placeholder: (_, text) {
                                  return Image(
                                    image: AssetImage(
                                        "assets/images/item-placeholder.png"),
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        (MediaQuery.of(context).size.width / 2),
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 8, bottom: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                widget.item["title"] != null &&
                                        widget.item["title"].length > 2
                                    ? Container(
                                        padding: EdgeInsets.all(2.5),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.zero,
                                              topRight: Radius.circular(15.0),
                                              bottomLeft: Radius.zero,
                                              bottomRight:
                                                  Radius.circular(15.0),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 1,
                                                color: Colors.white,
                                                offset: Offset(1, 2),
                                              )
                                            ] // Make rounded corner of border

                                            ),
                                        child: Text(
                                          lang.api(widget.item["title"]),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 10,
                                ),
                                widget.item["sub_title"] != null &&
                                        widget.item["sub_title"].length > 2
                                    ? Container(
                                        padding: EdgeInsets.all(2.5),
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(222, 152, 83, 1),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.zero,
                                              topRight: Radius.circular(15.0),
                                              bottomLeft: Radius.zero,
                                              bottomRight:
                                                  Radius.circular(15.0),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 1,
                                                color: Colors.white,
                                                offset: Offset(1, 2),
                                              )
                                            ] // Make rounded corner of border

                                            ),
                                        child: Text(
                                          lang.api(widget.item["sub_title"]),
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                                255, 217, 159, 1),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black38,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.5],
                            )),
                            width: MediaQuery.of(context).size.width,
                            height: (MediaQuery.of(context).size.width / 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          Flexible(
            child: Villain(
                villainAnimation: VillainAnimation.fromBottom(),
                child: getListView()),
          ),
        ],
      ),
    );
  }

  init() async {
    Map<String, dynamic> filterRequest = {};
    if (filterBy.containsKey("delivery_fee") &&
        filterBy["delivery_fee"].toString().isNotEmpty) {
      filterRequest["filter_delivery_fee"] = 1;
    }
    if (filterBy.containsKey("promos") &&
        filterBy["promos"].toString().isNotEmpty) {
      filterRequest["filter_promos"] = filterBy["promos"];
    }
    if (filterBy.containsKey("minimum_order") &&
        filterBy["minimum_order"].toString().isNotEmpty) {
      filterRequest["filter_minimum"] = filterBy["minimum_order"];
    }
    if (filterBy.containsKey("selected_services") &&
        filterBy["selected_services"].isNotEmpty) {
      List temp = [];
      filterBy["selected_services"].keys.toList().forEach((key) {
        bool selected = filterBy["selected_services"][key];
        if (selected) {
          temp.add(key);
        }
      });
      filterRequest["filter_services"] = temp;
    }
    if (filterBy.containsKey("selected_cuisine") &&
        filterBy["selected_cuisine"].isNotEmpty) {
      List temp = [];
      filterBy["selected_cuisine"].keys.toList().forEach((key) {
        bool selected = filterBy["selected_cuisine"][key];
        if (selected) {
          temp.add(key);
        }
      });
      filterRequest["filter_cuisine"] = temp;
    }

    if (widget.list == null && widget.cuisineId == null) {
      initPage = 0;
    }
    if (widget.list == null && widget.cuisineId != null) {
      setState(() {
        isLoading = true;
        list = [];
      });

      Map<String, dynamic> request = {
        "search_type": widget.searchType,
        "with_distance": "1",
        "sort_by": sortBySelected["id"],
        "sort_asc_desc": isAsc ? "asc" : "desc",
        "cuisine_id": widget.cuisineId,
      }
        ..addAll(filterRequest)
        ..addAll(widget.extraFields ?? {});
      Map<String, dynamic> response = await _repository.searchMerchant(request);
      isLoading = false;
      if (initPage == 0) {
        initPage++;
      }
      if (response.containsKey("code") && response["code"] == 1) {
        widget.searchMerchantDart = SearchMerchantDart.fromJson(response);

        list = widget.searchMerchantDart.details.searchMerchantList;
        paginateTotal = widget.searchMerchantDart.details.paginateTotal;
      } else {
        message = response["msg"];
      }
    } else {
      if (initPage == 0) {
        setState(() {
          isLoading = true;
          list = [];
        });
        Map<String, dynamic> response = await _repository.searchMerchant({
          "search_type": widget.searchType,
          "with_distance": "1",
          "sort_by": sortBySelected["id"],
          "sort_asc_desc": isAsc ? "asc" : "desc"
        }
          ..addAll(filterRequest)
          ..addAll(widget.extraFields ?? {}));
        isLoading = false;
        if (response.containsKey("code") && response["code"] == 1) {
          widget.searchMerchantDart = SearchMerchantDart.fromJson(response);
          initPage++;

          list = widget.searchMerchantDart.details.searchMerchantList;
          paginateTotal = widget.searchMerchantDart.details.paginateTotal;
        } else {
          message = response["msg"];
        }
        setState(() {});
      } else {
        setState(() {
          isLoading = false;
          list = widget.list;
        });
      }
    }
    setState(() {});
  }

  Widget getTop() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      padding: EdgeInsets.all(8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          (list ?? []).length == 0
              ? Container()
              : GreyButton(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return MerchantMaps(
                            list: list,
                          );
                        }),
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: SvgPicture.asset(
                        "assets/icons/location.svg",
                        width: 24,
                      ),
                    ),
                  ),
                ),
          GreyButton(
              child: InkWell(
            onTap: () async {
              var result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return SortBy(
                    isAsc: isAsc,
                    selected: sortBySelected,
                    byValue: SortByValue.restaurant,
                  );
                }),
              );
              if (result != null) {
                setState(() {
                  sortBySelected = result["sort_by"];
                  isAsc = result["sort"] == "asc";
                  initPage = 0;
                });
                init();
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Transform.rotate(
                    angle: (isAsc ? 180 : 0) * pi / 180,
                    child: Icon(
                      Icons.sort,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(lang.api("Sort by ")),
                  Text(sortBySelected["name"]),
                ],
              ),
            ),
          )),
          GreyButton(
            child: InkWell(
              onTap: () async {
                var result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return FilterBy(
                      filterData: filterBy,
                      isfromService: true,
                    );
                  }),
                );
                if (result is bool) {
                  filterBy = {};
                } else {
                  filterBy = result;
                }
                initPage = 0;
                init();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/filter.svg",
                      color: Theme.of(context).primaryColor,
                      width: 24,
                    ),
                    Text(lang.api("Filter By")),
                  ],
                ),
              ),
            ),
          ),
          GreyButton(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return SearchPage(
                      title: lang.api("Search for restaurant"),
                      searchType: SearchType.MerchantName,
                    );
                  }),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Theme.of(context).primaryColor),
                    Text(lang.api("Search")),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getListView() {
    if (isLoading) {
      return LoadingWidget(
        message: lang.api("loading"),
        size: 84.0,
        useLoader: true,
      );
    } else {
      if (list.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: EmptyWidget(
            size: 128,
            message: message,
          ),
        );
      } else {
        return getList();
      }
    }
  }

  Widget getList() {
    return RefreshIndicator(
      onRefresh: () async {
        initPage = 0;
        init();
        return;
      },
      child: Scrollbar(
        child: ListView.builder(
          controller: controller,
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            var item = list[index];
            if (loadingMore && index == list.length - 1) {
              return Column(
                children: <Widget>[
                  MerchantCard(item: item),
                  LoadingWidget(
                    size: 64,
                    message: "",
                    useLoader: true,
                  ),
                ],
              );
            }
            return MerchantCard(item: item);
          },
        ),
      ),
    );
  }

  void _scrollListener() async {
    if (controller.position.extentAfter < 100) {
      Map<String, dynamic> filterRequest = {};
      if (filterBy.containsKey("delivery_fee") &&
          filterBy["delivery_fee"].toString().isNotEmpty) {
        filterRequest["filter_delivery_fee"] = 1;
      }
      if (filterBy.containsKey("promos") &&
          filterBy["promos"].toString().isNotEmpty) {
        filterRequest["filter_promos"] = filterBy["promos"];
      }
      if (filterBy.containsKey("minimum_order") &&
          filterBy["minimum_order"].toString().isNotEmpty) {
        filterRequest["filter_minimum"] = filterBy["minimum_order"];
      }
      if (filterBy.containsKey("selected_services") &&
          filterBy["selected_services"].isNotEmpty) {
        List temp = [];
        filterBy["selected_services"].keys.toList().forEach((key) {
          bool selected = filterBy["selected_services"][key];
          if (selected) {
            temp.add(key);
          }
        });
        filterRequest["filter_services"] = temp;
      }
      if (filterBy.containsKey("selected_cuisine") &&
          filterBy["selected_cuisine"].isNotEmpty) {
        List temp = [];
        filterBy["selected_cuisine"].keys.toList().forEach((key) {
          bool selected = filterBy["selected_cuisine"][key];
          if (selected) {
            temp.add(key);
          }
        });
        filterRequest["filter_cuisine"] = temp;
      }
      if (paginateTotal != null && initPage < paginateTotal && !loadingMore) {
        if (widget.list == null && widget.cuisineId != null) {
          setState(() {
            loadingMore = true;
          });
          Map<String, dynamic> request = {
            "search_type": widget.searchType,
            "with_distance": "1",
            "sort_by": sortBySelected["id"],
            "sort_asc_desc": isAsc ? "asc" : "desc",
            "cuisine_id": widget.cuisineId,
            "page": initPage
          }
            ..addAll(filterRequest)
            ..addAll(widget.extraFields ?? {});

          Map<String, dynamic> response =
              await _repository.searchMerchant(request);
          initPage++;
          if (response.containsKey("success") && response["success"]) {
            response["details"]["list"].forEach((element) {
              if (!list.contains(element)) {
                list.add(element);
              }
            });
            paginateTotal =
                int.parse("${response["details"]["paginate_total"]}");
          }
          setState(() {
            loadingMore = false;
          });
        } else {
          // print("initPage: $initPage");
          setState(() {
            loadingMore = true;
          });
          Map<String, dynamic> response = await _repository.searchMerchant({
            "search_type": widget.searchType,
            "with_distance": "1",
            "sort_by": sortBySelected["id"],
            "sort_asc_desc": isAsc ? "asc" : "desc",
            "page": initPage
          }
            ..addAll(filterRequest)
            ..addAll(widget.extraFields ?? {}));
          initPage++;
          if (response.containsKey("success") && response["success"]) {
            response["details"]["list"].forEach((element) {
              if (!list.contains(element)) {
                list.add(element);
              }
            });
            paginateTotal =
                int.parse("${response["details"]["paginate_total"]}");
          }
          setState(() {
            loadingMore = false;
          });
        }
      }
    }
  }
}

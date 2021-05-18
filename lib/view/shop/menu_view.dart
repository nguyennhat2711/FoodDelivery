import 'dart:async';
import 'dart:convert';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/circle_image.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/merchant/price_widget.dart';
import 'package:afandim/helper/app_builder.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/control_view.dart';
import 'package:afandim/view/home/home_widget/search_page.dart';
import 'package:afandim/view/merchant/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Menu extends StatefulWidget {
  final String merchantId;
  final Map merchantData;
  final List list;
  final Function(List) onLoadList;
  final VoidCallback openOverView;
  const Menu({
    Key key,
    this.merchantData,
    @required this.merchantId,
    @required this.onLoadList,
    this.list,
    this.openOverView,
  }) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final _repo = Repository();
  final _prefManager = PrefManager();
  List list = [];
  bool isLoading = true;
  String message;
  String selectedCategoryId = "0";
  bool viewCart = false;
  Timer timer;

  @override
  void initState() {
    init();
    checkViewCart();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  init() async {
    if (widget.list == null) {
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> response =
          await _repo.getMerchantMenu(widget.merchantId);
      isLoading = false;
      if (response.containsKey("code") && response["code"] == 1) {
        list = response["details"]["list"];
        widget.onLoadList(list);
      } else {
        message = response["msg"];
      }
    } else {
      isLoading = false;
      list = widget.list;
    }
    setState(() {});
  }

  checkViewCart() async {
    timer = Timer.periodic(Duration(seconds: 7), (timer) async {
      Map basketDetails =
          json.decode(await _prefManager.get("cart_details", "{}"));
      if (basketDetails != null && basketDetails.containsKey("basket_count")) {
        setState(() {
          viewCart = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _repo.close();
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text("Menu"),
//        centerTitle: true,
//      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return getBodyContent();
  }

  Widget getBodyContent() {
    if (widget.merchantData == null) {
      return LoadingWidget(
        size: 84,
        useLoader: true,
      );
    }
    return getMenuList();
  }

  List getCategories() {
    List categories = [
      {"cat_id": "0", "category_name": lang.api("All")}
    ];
    list.forEach((element) {
      if ((!element.containsKey("item") || element["item"].length != 0)) {
        categories.add(element);
      }
    });
    return categories;
  }

  List getListData() {
    List items = [];
    list.forEach((element) {
      if ("${element["cat_id"]}" == selectedCategoryId ||
          selectedCategoryId == "0") {
        items.addAll(element["item"]);
      }
    });
    return items;
  }

  Widget getMenuList() {
    return Column(
      children: [
        getTop(),
        isLoading ? Container() : getCategoryList(),
        Divider(
          height: 2,
          color: Colors.grey,
        ),
        Flexible(
//                  (getListData().length == 0 && !isLoading)
          child: (!isLoading && list.length == 0)
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: EmptyWidget(
                    message: message,
                    size: 128,
                  ),
                )
              : buildMenuList(),
        ),
      ],
    );
  }

  Widget buildMenuList() {
    return ListView.separated(
      separatorBuilder: (_, index) {
        if (!isLoading) {
          var item = list[index];
          if ((selectedCategoryId != item["cat_id"] &&
                  selectedCategoryId != "0") ||
              item["item"].length == 0) {
            return Container();
          } else {
            return Divider(
              height: 2,
              color: Colors.grey,
            );
          }
        } else {
          return Container();
        }
      },
      itemCount: isLoading ? 4 : list.length,
      itemBuilder: (BuildContext context, int index) {
        if (isLoading) {
          return getLoadingCard();
        } else {
          var item = list[index];
          return getCategoryItem(item);
        }
      },
    );
  }

  Widget getTop() {
    return Container(
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: widget.merchantData["background_url"] ?? "",
            placeholder: (_, t) {
              return Image(
                image: AssetImage("assets/images/background-2.jpg"),
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                height: 140,
              );
            },
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: 140,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 140,
            color: Colors.black38,
          ),
          SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back),
                        color: Colors.white,
                      ),
                      viewCart
                          ? IconButton(
                              onPressed: () async {
                                await PrefManager().set("has_page", true);
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return ControlView(
                                    selectedIndex: 3,
                                  );
                                }));
                              },
                              icon: Icon(
                                Icons.shopping_cart,
                                size: 32,
                              ),
                              color: Colors.white,
                            )
                          : Container(),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  Card(
                    margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: InkWell(
                      onTap: () {
                        widget.openOverView();
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lang.api(
                                        widget.merchantData["restaurant_name"]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      child: Text(
                                        "${widget.merchantData["rating"]["ratings"]}",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                lang.api(widget.merchantData["cuisine"]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: getDeliveryDetails(),
                            ),
//                        getOffers()
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getDeliveryDetails() {
    List<Widget> list = [];
    if (widget.merchantData.containsKey("minimum_order") &&
        widget.merchantData["minimum_order"].toString().isNotEmpty) {
      list.add(getColumn(
          widget.merchantData["minimum_order"], lang.api("Min Order")));
    }
    if (widget.merchantData.containsKey("delivery_fee") &&
        widget.merchantData["delivery_fee"].toString().isNotEmpty) {
      list.add(getColumn(
          widget.merchantData["delivery_fee"], lang.api("Min Delivery")));
    } else {
      list.add(getColumn(lang.api("Free Delivery"), lang.api("Min Delivery")));
    }
    if (widget.merchantData.containsKey("delivery_estimation") &&
        widget.merchantData["delivery_estimation"].toString().isNotEmpty) {
      list.add(getColumn(widget.merchantData["delivery_estimation"],
          lang.api("Delivery Duration")));
    }
    return list;
  }

  Column getColumn(String value, String label) {
    return Column(
      children: <Widget>[
        Container(
          height: 24,
          child: Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontFamily: "Roboto"),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget getCategoryItem(item) {
    if ((selectedCategoryId != item["cat_id"] && selectedCategoryId != "0") ||
        item["item"].length == 0) {
      return Container();
    }
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            item["category_name"],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ListView.separated(
          primary: false,
          shrinkWrap: true,
          itemCount: item["item"].length,
          separatorBuilder: (_, index) {
            return Divider(
              height: 2,
              color: Colors.grey,
            );
          },
          itemBuilder: (context, index) {
            var listItem = item["item"][index];
            return getItem(listItem);
          },
        ),
      ],
    );
  }

  Widget getCategoryList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 42,
        margin: EdgeInsets.only(top: 8),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return SearchPage(
                      title: lang.api("Search for category"),
                      searchType: SearchType.FoodCategory,
                      merchantId: widget.merchantId,
                    );
                  }),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.all(8),
                child: Icon(Icons.search),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              primary: false,
              scrollDirection: Axis.horizontal,
              itemCount: getCategories().length,
              itemBuilder: (context, index) {
                var item = getCategories()[index];
                String catId = "${item["cat_id"]}";
                if (item.containsKey("item") && item["item"].length == 0) {
                  return Container();
                }
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: selectedCategoryId == catId
                        ? Theme.of(context).primaryColor
                        : Colors.grey[50],
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategoryId = catId;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      child: Center(
                        child: Text(
                          item["category_name"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedCategoryId == catId
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getLoadingCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: Container(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              height: 64,
              width: 64,
              padding: EdgeInsets.all(8),
              color: Colors.grey[500],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18,
                    width: MediaQuery.of(context).size.width / 2,
                    margin: EdgeInsets.all(8),
                    color: Colors.grey[500],
                  ),
                  Container(
                    height: 16,
                    width: MediaQuery.of(context).size.width / 3,
                    margin: EdgeInsets.all(8),
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTap(item) async {
    String name = json.decode(item["item_name_trans"])[lang.getLanguageText()];
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return Product(
          merchantId: "${item["merchant_id"]}",
          catId: "${item["cat_id"]}",
          itemId: "${item["item_id"]}",
          itemName: name,
        );
      }),
    );
    AppBuilder.of(context).rebuild();
  }

  Widget getItem(var item) {
    String name = json.decode(item["item_name_trans"])[lang.getLanguageText()];
    String description =
        json.decode(item["item_description_trans"])[lang.getLanguageText()];

    return Dismissible(
      key: Key("item: $name"),
      direction: DismissDirection.startToEnd,
      onDismissed: (dismissDirection) {
        onTap(item);
      },
      child: Container(
        child: InkWell(
          onTap: () {
            onTap(item);
          },
          child: Container(
            margin: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            description ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: item["prices2"].length,
                          itemBuilder: (context, index) {
                            var priceItem = item["prices2"][index];
                            bool hasDiscount =
                                ("${priceItem["discount"]}".isNotEmpty &&
                                    "${priceItem["discount"]}" != "0");
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: PriceWidget(
                                      price: hasDiscount
                                          ? priceItem["discounted_price_pretty"]
                                          : priceItem["original_price"],
                                      oldPrice: hasDiscount
                                          ? priceItem["original_price"]
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: CircleImage(
                    borderRadius: 8,
                    borderWidth: 0,
                    child: CachedNetworkImage(
                      imageUrl: item["photo"],
                      fit: BoxFit.cover,
                      placeholder: (context, text) {
                        return Image(
                          image:
                              AssetImage("assets/images/item-placeholder.png"),
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

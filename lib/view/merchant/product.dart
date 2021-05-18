import 'dart:convert';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/help/checkbox_list.dart';
import 'package:afandim/custom_widget/help/radio_list.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/merchant/price_widget.dart';
import 'package:afandim/custom_widget/merchant/qty_widget.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/control_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'gallery_list.dart';

class Product extends StatefulWidget {
  final String merchantId;
  final String itemId;
  final String catId;
  final String itemName;
  final String row;
  Product(
      {Key key,
      this.merchantId,
      this.itemId,
      this.catId,
      this.itemName,
      this.row})
      : super(key: key);

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final _repo = Repository();
  final _prefManager = PrefManager();
  bool isLoading = true;
  Map data;
  String selectedPrice;
  int quantity = 1;
  final _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool viewCart = false;
  bool orderingDisabled = false;
  bool forceRefresh = false;
  Map<String, bool> ingredients = {};
  String cookingRef;

  Map<String, dynamic> subItemMulti = {};
  Map<String, String> subItemSingle = {};
  Map<String, int> subItemQty = {};

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response = await _repo.itemDetails(
        widget.merchantId,
        widget.itemId,
        widget.catId,
        widget.row,
        widget.row == null ? forceRefresh : true);
    isLoading = false;
    if (response.containsKey("code") && response["code"] == 1) {
      var orderingDisabled = response["details"]["ordering_disabled"];
      if (orderingDisabled is bool && orderingDisabled) {
        this.orderingDisabled = true;
        showError(_scaffoldKey, response["details"]["ordering_msg"]);
      } else {
        this.orderingDisabled = false;
      }
      data = response["details"]["data"];
      if (response["details"]["cart_data"] is Map) {
        print(
            "response[\"details\"][\"cart_data\"]: ${json.encode(response["details"]["cart_data"])}");
        Map cartData = response["details"]["cart_data"];
        if (cartData["ingredients"] is List) {
          for (int j = 0; j < cartData["ingredients"].length; j++) {
            ingredients[cartData["ingredients"][j]] = true;
          }
        }
        cookingRef = cartData["cooking_ref"];
        quantity = int.parse("${cartData["qty"]}");
        _controller.text = cartData["notes"];

        if (cartData["sub_item"] is Map) {
          Map cartSubItem = cartData["sub_item"];
          for (int i = 0; i < cartSubItem.keys.toList().length; i++) {
            String cId = cartSubItem.keys.toList()[i];
            if (data["addon_item"] is List) {
              List addonList = data["addon_item"];
              for (int i = 0; i < addonList.length; i++) {
                var addonItem = addonList[i];
                if (addonItem["multi_option"] != "multiple" &&
                    addonItem["subcat_id"] == cId) {
                  if (cartSubItem[cId] is List && cartSubItem[cId].length > 0) {
                    this.subItemSingle[cId] = cartSubItem[cId][0];
                  }
                }
              }
            }
            this.subItemMulti[cId] = {};
            for (int j = 0; j < cartSubItem[cId].length; j++) {
              String x = cartSubItem[cId][j];
              List<String> l = x.split("|");
              this.subItemMulti[cId][l[0]] = {
                "sub_item_name": l[2],
                "sub_item_id": l[0],
                "subcat_id": cId,
                "price": l[1],
                "item_id": l[0],
              };
              if (cartData["addon_qty"] is Map) {
                Map cartAddonQty = cartData["addon_qty"];
                subItemQty[l[0]] = int.parse(cartAddonQty[cId][j]);
              }
            }
          }
        }
      }
    }

    Map basketDetails =
        json.decode(await _prefManager.get("cart_details", "{}"));
    if (basketDetails != null &&
        basketDetails.containsKey("basket_count") &&
        "${basketDetails["basket_count"]}" != "0") {
      viewCart = true;
      print("basketDetails: $basketDetails");
    }
    setState(() {});
    return;
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  String getProductLabel(String key) {
    return data[key][lang.getLanguageText()] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: getBody(),
    );
  }

  Widget getScaffold({Widget child}) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemName),
      ),
      body: child,
    );
  }

  Widget getBody() {
    if (isLoading) {
      return getScaffold(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: LoadingWidget(
            size: 84.0,
            useLoader: true,
            message: lang.api("loading"),
          ),
        ),
      );
    } else {
      if (data != null) {
        return Container(
          child: getBodyContent(),
        );
      } else {
        return getScaffold(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: EmptyWidget(
                  message: lang.api("Fail to get item details"),
                  size: 128,
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget getBodyContent() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            actions: viewCart
                ? <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.shopping_cart,
                        size: 32,
                      ),
//                color: Theme.of(context).primaryColor,
                      onPressed: openCart,
                    )
                  ]
                : <Widget>[],
            flexibleSpace: FlexibleSpaceBar(
//                centerTitle: true,
              title: Text(
                getProductLabel("item_name_trans"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              background: Container(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                color: Colors.grey[50],
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(
                        imageUrl: data["photo"],
                        height: 250,
                        fit: BoxFit.cover,
                        placeholder: (context, text) {
                          return Image(
                            image: AssetImage("assets/images/item-cover.png"),
                            fit: BoxFit.cover,
                            height: 250,
                          );
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 250,
                      padding: EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.7],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: Container(
        child: RefreshIndicator(
          onRefresh: () async {
            forceRefresh = true;
            await init();
            return;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: getChildren(),
          ),
        ),
      ),
    );
  }

  List<Widget> getChildren() {
    return <Widget>[
      Flexible(
        child: Container(
          child: ListView(
            children: [
//    data["gallery"].add(data["photo"]);
              getProductDetails(),

              getBanner(),
              getPrices(),
              getIngredients(),
              getCookingRef(),
              getAddonItem(),
              getEditableText(),
            ],
          ),
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        child: getBottomWidget(),
      ),
    ];
  }

  List<Map<String, dynamic>> matToList(Map map) {
    List<Map<String, dynamic>> list = [];
    for (int i = 0; i < map.keys.toList().length; i++) {
      var key = map.keys.toList()[i];
      list.add({"key": key, "value": map[key]});
    }
    return list;
  }

  Widget getIngredients() {
    if (data["ingredients"] is Map) {
      List<Map<String, dynamic>> list = matToList(data["ingredients"]);
      if (list.isEmpty) {
        return Container();
      }
      return Container(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(color: Colors.grey, height: 2),
            SizedBox(height: 8),
            Text(
              lang.api("Ingredients"),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            CheckboxList(
              list: list,
              selectedValues: ingredients,
              onSelect: (selectedData) {
                ingredients = selectedData;
              },
              twoColumns: false,
              labelKey: "value",
              idKey: "value",
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget getCookingRef() {
    if (data["cooking_ref"] is Map) {
      List<Map<String, dynamic>> list = matToList(data["cooking_ref"]);
      if (list.isEmpty) {
        return Container();
      }
//      cookingRef = list[0]["value"];
      return Container(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(color: Colors.grey, height: 2),
            SizedBox(height: 8),
            Text(
              lang.api("Cooking Preference"),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            RadioList(
              list: list,
              selectedValue: cookingRef,
              labelKey: "value",
              idKey: "value",
              onSelect: (item) {
                cookingRef = item["value"];
              },
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget getAddonItem() {
    if (data["addon_item"] is List) {
      List addonList = data["addon_item"];
      return Column(
        children: <Widget>[
          Divider(color: Colors.grey, height: 2),
          SizedBox(height: 8),
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: addonList.length,
            itemBuilder: (context, index) {
              Map item = addonList[index];
//              "multi_option": "multiple",
              String multiOption = item["multi_option"];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item["subcat_name_trans"][lang.getLanguageText()],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    multiOption == "multiple"
                        ? getMultiSelectList(item)
                        : getSingleSelectList(item),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }
    return Container();
  }

  Widget getSingleSelectList(item) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: item["sub_item"].length,
      itemBuilder: (context, index) {
        String catId = item["subcat_id"];
        Map subItem = item["sub_item"][index];
        String id =
            "${subItem["sub_item_id"]}|${subItem["price"]}|${subItem["sub_item_name"]}";
        String defaultValue = subItemSingle[catId] ?? "";
        if (defaultValue.isEmpty &&
            index == 0 &&
            "${item["require_addons"]}" == "2") {
          subItemSingle[catId] = id;
        }
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: <Widget>[
              Radio<String>(
                value: id,
                groupValue: subItemSingle[catId] ?? "",
                onChanged: (String newValue) {
                  setState(() {
                    subItemSingle[catId] = newValue;
                  });
                },
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      subItemSingle[catId] = id;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${subItem["sub_item_name_trans"][lang.getLanguageText()]} ${subItem["pretty_price"]}",
                        style: TextStyle(
                          fontFamily: "Roboto",
                        ),
                      ),
                      Text(
                        "${subItem["item_description_trans"][lang.getLanguageText()]}",
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getMultiSelectList(item) {
    String catId = item["subcat_id"];
    if (!this.subItemMulti.containsKey(catId)) {
      this.subItemMulti[catId] = {};
    }
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: item["sub_item"].length,
      itemBuilder: (context, index) {
        Map subItem = item["sub_item"][index];
        String id = "${subItem["sub_item_id"]}";
        Map savedSubItem = {
          "sub_item_name": subItem["sub_item_name"],
          "sub_item_id": subItem["sub_item_id"],
          "subcat_id": item["subcat_id"],
          "price": subItem["price"],
          "item_id": id,
        };
        bool checked = false;
        if (this.subItemMulti[catId].containsKey(id)) {
          checked = true;
          savedSubItem = this.subItemMulti[catId][id];
        }
        return Container(
          child: Row(
            children: <Widget>[
              //
              Checkbox(
                  value: checked,
                  onChanged: (val) {
                    if (val) {
                      this.subItemMulti[catId][id] = savedSubItem;
                    } else {
                      this.subItemMulti[catId].remove(id);
                    }
                    setState(() {});
                  }),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (checked) {
                      this.subItemMulti[catId].remove(id);
                    } else {
                      this.subItemMulti[catId][id] = savedSubItem;
                    }
                    setState(() {});
                  },
                  child: Text(
                    "${subItem["sub_item_name_trans"][lang.getLanguageText()]} ${subItem["pretty_price"]}",
                    style: TextStyle(
                      fontFamily: "Roboto",
                    ),
                  ),
                ),
              ),
              QtyWidget(
                qty: "${subItemQty[id] ?? 1}",
                direction: QtyDirection.horizontal,
                onQtyChanged: (int newQty) {
                  subItemQty[id] = newQty;
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getEditableText() {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey, height: 2),
          SizedBox(height: 8),
          Text(
            lang.api("Special Request"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          AlternativeTextField(
            controller: _controller,
            hint: lang.api("Your preferences or request"),
            maxLines: 4,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }

  Widget getBottomWidget() {
    bool isUpdate =
        widget.row != null && widget.row.isNotEmpty && widget.row != "null";
    return SafeArea(
      bottom: true,
      top: false,
      child: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey, width: 2))),
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: AlternativeButton(
                label: isUpdate
                    ? lang.api("Update Cart")
                    : lang.api("Add to cart"),
                onPressed:
                    (quantity > 0 && !orderingDisabled) ? addToCart : null,
              ),
            ),
            SizedBox(width: 16),
            cartIconButton(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                color: Colors.green,
                onTap: () {
                  setState(() {
                    quantity++;
                  });
                }),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.all(8),
              child: Text(
                "$quantity",
                style: TextStyle(fontSize: 32),
              ),
            ),
            cartIconButton(
              child: Icon(
                Icons.remove,
                color: Colors.white,
              ),
              color: Colors.grey[400],
              onTap: (quantity > 0)
                  ? () {
                      if (quantity > 0) {
                        setState(() {
                          quantity--;
                        });
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  openCart() async {
    await _prefManager.set("has_page", true);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ControlView(
        selectedIndex: 3,
      );
    }));
  }

  addToCart() async {
    if (selectedPrice == null || selectedPrice.isEmpty) {
      showError(_scaffoldKey, lang.api("Please select price"));
    } else {
      bool con = true;
      String activeMerchant = await _prefManager.get("active_merchant", "0");
      if (await _prefManager.contains("active_merchant") &&
          "$activeMerchant" != widget.merchantId) {
        con = await showCustomErrorDialog(
          lang.api("Orde from 2 Merchant"),
          lang.api("You can't order from more than one merchant, continue?"),
          lang.api("Continue"),
        );
        if (con) {
          showLoadingDialog(lang.api("loading"));
          await _repo.clearCart();
          Navigator.of(context).pop();
        }
      }
      if (con) {
        _prefManager.set("active_merchant", widget.merchantId);
        if (data["addon_item"] is List) {
          List addonList = data["addon_item"];
          for (int i = 0; i < addonList.length; i++) {
            var addonItem = addonList[i];
            if ("${addonItem["require_addons"]}" == "2") {
              bool isEmpty = false;
              if (addonItem["multi_option"] == "multiple") {
                if (!subItemMulti.containsKey("${addonItem["subcat_id"]}") ||
                    subItemMulti["${addonItem["subcat_id"]}"].isEmpty) {
                  isEmpty = true;
                }
              } else {
                if (!subItemSingle.containsKey("${addonItem["subcat_id"]}") ||
                    subItemSingle["${addonItem["subcat_id"]}"].isEmpty) {
                  isEmpty = true;
                }
              }
              if (isEmpty) {
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 3),
                    content: Text(
                      "${lang.api("You must select at least one addon for")} ${addonItem["subcat_name_trans"][lang.getLanguageText()]}",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
            }
          }
        }
        bool isUpdate =
            widget.row != null && widget.row.isNotEmpty && widget.row != "null";
        Map<String, dynamic> request = {
          "category_id": widget.catId,
          "item_id": widget.itemId,
          "two_flavors": "0",
          "price": "$selectedPrice",
          "notes": _controller.text,
          "qty": "$quantity",
        };
        if (isUpdate) {
          request["row"] = widget.row;
        }
        var ingredientsList = [];
        if (data["ingredients"] is Map) {
          List<Map<String, dynamic>> list = matToList(data["ingredients"]);
          for (int i = 0; i < list.length; i++) {
            var key = list[i]["value"];
            if (ingredients.containsKey(key) && ingredients[key]) {
              ingredientsList.add(list[i]["value"]);
            }
          }
        }
        request["ingredients"] = ingredientsList;
        request["cooking_ref"] = cookingRef;

        request["sub_item"] = {};
        request["addon_qty"] = {};
        if (subItemMulti.isNotEmpty) {
          for (int i = 0; i < subItemMulti.keys.toList().length; i++) {
            String catId = subItemMulti.keys.toList()[i];
            if (subItemMulti[catId].isNotEmpty) {
              request["sub_item"][catId] = [];
              request["addon_qty"][catId] = [];
              for (int i = 0;
                  i < subItemMulti[catId].keys.toList().length;
                  i++) {
                String itemId = subItemMulti[catId].keys.toList()[i];
                Map subItemData = subItemMulti[catId][itemId];
                request["sub_item"][catId].add(
                    "$itemId|${subItemData["price"]}|${subItemData["sub_item_name"]}");

                if (subItemQty.containsKey(itemId)) {
                  request["addon_qty"][catId].add(subItemQty[itemId]);
                } else {
                  request["addon_qty"][catId].add(1);
                }
              }
            }
          }
        }
        if (subItemSingle.isNotEmpty) {
          Map x = request["sub_item"] ?? {};
          for (int i = 0; i < subItemSingle.keys.toList().length; i++) {
            String cId = subItemSingle.keys.toList()[i];
            x[cId] = [subItemSingle[cId]];
          }
          request["sub_item"] = x;
        }
        showLoadingDialog(lang.api("loading"));

        Map<String, dynamic> response = await _repo.addToCart(request);
        Navigator.of(context).pop();
        setState(() {
          viewCart = true;
        });
        await _prefManager.set("load_cart_count", true);
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
//                              duration: Duration(minutes: 10),
            content: Text(
              response["msg"] ?? lang.api("System error"),
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            action: (response.containsKey("code") && response["code"] == 1)
                ? SnackBarAction(
                    textColor: Colors.white,
                    label: lang.api("View cart"),
                    onPressed: openCart,
                  )
                : null,
            backgroundColor:
                (response.containsKey("code") && response["code"] == 1)
                    ? Colors.green
                    : Colors.red,
          ),
        );
      }
    }
  }

  Widget cartIconButton({Widget child, Color color, VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }

  Widget getBanner() {
    if (data["gallery"].length == 0) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: CarouselSlider.builder(
        itemCount: data["gallery"].length,
        itemBuilder: (BuildContext context, int index, int ss) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return GalleryList(
                    image: data["gallery"][index],
                    list: data["gallery"],
                  );
                }),
              );
            },
            child: CachedNetworkImage(
              imageUrl: data["gallery"][index],
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: 280,
              placeholder: (context, text) {
                return Image(
                  image: AssetImage("assets/images/background-2.jpg"),
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: 280,
                );
              },
            ),
          );
        },
        options: CarouselOptions(
          autoPlay: true,
//          enableInfiniteScroll: false,
          pauseAutoPlayOnManualNavigate: true,
          enlargeCenterPage: true,
          viewportFraction: 0.85,
        ),
      ),
    );
  }

  Widget getProductDetails() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getProductLabel("item_name_trans"),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          getProductLabel("item_description_trans").isEmpty
              ? Container()
              : SizedBox(
                  height: 8,
                ),
          getProductLabel("item_description_trans").isEmpty
              ? Container()
              : Text(
                  getProductLabel("item_description_trans"),
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
        ],
      ),
    );
  }

  Widget getPrices() {
    if (data["prices"] is bool) {
      return Container();
    }
    if (selectedPrice == null) {
      if (data["prices"].length == 1) {
        selectedPrice = "${data["prices"][0]["price"]}";
      } else {
        selectedPrice =
            "${data["prices"][0]["price"]}|${data["prices"][0]["size_id"]}|${data["prices"][0]["size"]}";
      }
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.api("Price"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: data["prices"].length,
            itemBuilder: (context, index) {
              var item = data["prices"][index];
              bool hasDiscount = ("${item["discount_price"]}".isNotEmpty &&
                  "${item["discount_price"]}" != "0");
              String radioValue;
              if (data["prices"].length == 1) {
                radioValue = "${item["price"]}";
              } else {
                radioValue =
                    "${item["price"]}|${item["size_id"]}|${item["size"]}";
              }
              bool noName =
                  (item["size"] == null || item["size"].toString().isEmpty);
              return Row(
                children: [
                  Radio<String>(
                    value: radioValue,
                    groupValue: selectedPrice,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (value) {
                      setState(() {
                        selectedPrice = value;
                      });
                    },
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedPrice = radioValue;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            noName
                                ? Container()
                                : Text((item["size_trans"] is Map
                                    ? item["size_trans"][lang.getLanguageText()]
                                    : item["size"])),
                            Row(
                              children: [
                                Icon(
                                  Icons.local_offer,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                PriceWidget(
                                  price: hasDiscount
                                      ? item["formatted_discount_price"]
                                      : item["formatted_price"],
                                  oldPrice: hasDiscount
                                      ? item["formatted_price"]
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

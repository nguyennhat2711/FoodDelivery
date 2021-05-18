import 'dart:convert';
import 'dart:developer';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/merchant/about_cart_row.dart';
import 'package:afandim/custom_widget/merchant/qty_widget.dart';
import 'package:afandim/helper/app_builder.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/address_selector_view/address_selector.dart';
import 'package:afandim/view/auth/login/login_view.dart';
import 'package:afandim/view/cart/widget/cart_error.dart';
import 'package:afandim/view/cart/widget/cart_header.dart';
import 'package:afandim/view/cart/widget/cart_merchant_data.dart';
import 'package:afandim/view/cart/widget/cart_prices.dart';
import 'package:afandim/view/cart/widget/voucher_widget.dart';
import 'package:afandim/view/helper/payment_method.dart';
import 'package:afandim/view/merchant/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

class CartView extends StatefulWidget {
  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final _repo = Repository();
  final _prefManager = PrefManager();
  bool isLoading = true;
  List items = [];
  String message;
  String subMessage;
  Map transactionType = {"key": "delivery"};
  String deliveryAddress;
  Map deliveryDate;
  Map deliveryTime;
  bool deliveryAsap = true;
  Map details;
  Map total;
  Map<String, List> mapList = {};
  Map<String, int> removeList = {};

  Map<String, Map> itemQty = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> init() async {
    if (!await _prefManager.contains("token")) {
      _prefManager.set("come_from", "cart");
      Get.off(LoginPhone());
    }
    if (await _prefManager.contains("active_merchant")) {
      setState(() {
        isLoading = true;
        details = null;
        itemQty = {};
      });
      Map<String, dynamic> response =
          await _repo.loadCart({"transaction_type": transactionType["key"]});
      isLoading = false;
      if (response.containsKey("code") && response["code"] == 1) {
        details = response["details"];
        if (details["data"]["item"] is Map) {
          List temp = [];
          details["data"]["item"].keys.toList().forEach((key) {
            temp.add(details["data"]["item"][key]..addAll({"row": key}));
          });
          items = temp;
        } else {
          items = details["data"]["item"];
        }
        var cartDetails = details["cart_details"];
        print("cartDetails: $cartDetails");
        deliveryAddress = cartDetails["location_name"] ?? "";
        if (deliveryAddress.trim().isEmpty) {
          deliveryAddress = lang.api("Please enter address here");
        }
        log("details: ${json.encode(details)}");
        deliveryDate = {"key": details["default_delivery_date"]};
        deliveryTime = {"key": details["required_delivery_time"]};
        deliveryAsap = deliveryTime["key"].toString().isEmpty;
        if (details["required_delivery_time"] == "yes") {
          deliveryTime = {"key": ""};
        } else {
          deliveryAsap = true;
        }
        total = details["data"]["total"];
        setState(() {});
        loadLookups();
      } else {
        details = null;
        itemQty = {};
        message = response["msg"];
        if (response["code"] == -1) {
          subMessage =
              lang.api("Ooops, Please check your internet connection.");
        } else {
          subMessage =
              lang.api("Your cart is empty. Add something from the menu");
        }
      }
    } else {
      details = null;
      itemQty = {};
      isLoading = false;
      message = lang.api("Make your first order");
      subMessage = lang.api("Your cart is empty. Add something from the menu");
    }
    setState(() {});
  }

  loadLookups() async {
    await loadDates();
    await loadTimes();
    await loadServices();
  }

  loadDates() async {
    Map<String, dynamic> response = await _repo.deliveryDateList();
    check(response, "dates");
  }

  loadTimes() async {
    Map<String, dynamic> response = await _repo.deliveryTimeList();
    check(response, "times");
  }

  loadServices() async {
    Map<String, dynamic> response = await _repo.servicesList();
    check(response, "services");
  }

  check(response, name) {
    if (response.containsKey("code") && response["code"] == 1) {
      List list = [];
      List temp = getKeyValList(response["details"]["data"]);
      if (name == "times") {
        temp.forEach((element) {
          DateTime time = DateFormat("yyyy-MM-dd HH:mm")
              .parse("${deliveryDate["key"]} ${element["key"]}}");
          if (time.compareTo(DateTime.now()) >= 0) {
            list.add(element);
          }
        });
      } else {
        list = temp;
      }
      mapList[name] = list;
      AppBuilder.of(context).rebuild();
    }
  }

  List getKeyValList(Map map) {
    List temp = [];
    map.forEach((key, value) {
      temp.add({"key": key, "label": value});
    });
    return temp;
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          lang.api("Cart"),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: getBody(),
      ),
    );
  }

  Widget getBody() {
    if (isLoading) {
      return LoadingWidget(
        message: lang.api("loading"),
        size: 84.0,
        useLoader: true,
      );
    } else {
      if (details == null) {
        return Container(
          padding: EdgeInsets.all(24),
          child: EmptyWidget(
            size: 128,
            message: message,
            subMessage: subMessage,
            svgPath: "assets/icons/empty.svg",
          ),
        );
      }
    }
    return getCartContent();
  }

  Widget getCartContent() {
    return Container(
      child: RefreshIndicator(
        onRefresh: () async {
          await init();
          return;
        },
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CartError(
                  errorList: details["cart_error"],
                ),
                CartHeader(
                  scaffoldKey: _scaffoldKey,
                  reloadCart: () {
                    init();
                  },
                ),
                CartMerchantData(
                  details: details,
                ),
                SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, index) {
                          return Divider(height: 2, color: Colors.grey);
                        },
                        itemBuilder: (context, index) {
                          var item = items[index];
                          var row = item["row"] ?? index;
                          String ingredients = "";
                          if (item["ingredients"] is List) {
                            for (int i = 0;
                                i < item["ingredients"].length;
                                i++) {
                              ingredients +=
                                  (i > 0 ? ", " : "") + item["ingredients"][i];
                            }
                          }
                          String cookingRef = (item["cooking_ref"] is String)
                              ? item["cooking_ref"]
                              : "";
                          NumberFormat priceFormat = new NumberFormat(
                              "#,###.00", lang.currentLanguage);

                          var curr = total["curr"];
                          String pName = '';
                          double subTotal =
                              double.parse("${item["discounted_price"]}") *
                                  int.parse("${item["qty"]}");
                          List itemNameTrans = item["item_name_trans"] as List;
                          if (itemNameTrans != null &&
                              itemNameTrans.length > 0) {
                            dynamic itemNameSubTrans = itemNameTrans[0];

                            if (itemNameSubTrans != null) {
                              pName = itemNameSubTrans[lang.getLanguageText()];
                            }
                          }
                          // String pName = item["item_name_trans"]["item_name_trans"][lang.getLanguageText()];

                          return Container(
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(12, 8, 8, 8),
                                  child: QtyWidget(
                                    qty: "${item["qty"]}",
                                    onQtyChanged: (int newQty) {
                                      setState(() {
                                        if (newQty == null) {
                                          itemQty.remove(
                                              "${item["row"] ?? index}");
                                        } else {
                                          itemQty["${item["row"] ?? index}"] = {
                                            "qty": newQty,
                                            "row": row,
                                            "item_id": item["item_id"],
                                            "category_id": item["category_id"],
                                            "ingredients": item["ingredients"],
                                            "cooking_ref": item["cooking_ref"],
                                            "new_sub_item":
                                                item["new_sub_item"],
//                                            "sub_item": item["sub_item"],
                                            "normal_price":
                                                item["normal_price"],
                                          };
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      String merchantId = await _prefManager
                                          .get("active_merchant", "0");
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return Product(
                                            merchantId: merchantId,
                                            catId: "${item["category_id"]}",
                                            itemId: "${item["item_id"]}",
                                            itemName: pName,
                                            row: "$row",
                                          );
                                        }),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text: pName,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: " " +
                                                            item["category_name_trans"]
                                                                    [
                                                                    "category_name_trans"]
                                                                [
                                                                lang.getLanguageText()],
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  // 	"Are you sure you want to remove all items in your cart?": {
                                                  bool delete =
                                                      await showCustomErrorDialog(
                                                    lang.api(
                                                        "Remove From Cart?"),
                                                    lang.api(
                                                        "Are you sure you want to remove this item in your cart?"),
                                                    lang.api("Remove"),
                                                  );
                                                  if (delete) {
                                                    showLoadingDialog(
                                                        lang.api("loading"));
                                                    Map<String, dynamic>
                                                        response = await _repo
                                                            .removeCartItem(
                                                                {"row": index});
                                                    ;

                                                    // if(items.length == 1)
                                                    //   response  = await _repo.clearCart();
                                                    //   else
                                                    //  response =
                                                    //     await _repo.removeCartItem(
                                                    //         {"row": index});

                                                    Navigator.of(context).pop();
                                                    if (response.containsKey(
                                                            "code") &&
                                                        response["code"] == 1) {
                                                      init();
                                                    } else {
                                                      showError(_scaffoldKey,
                                                          response["msg"]);
                                                    }
                                                  }
                                                },
                                                child: Icon(
                                                  Icons.cancel,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ingredients.isEmpty
                                              ? Container()
                                              : Text(
                                                  ingredients,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          cookingRef.isEmpty
                                              ? Container()
                                              : Text(
                                                  lang.api("Cooking Ref") +
                                                      ": " +
                                                      cookingRef,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                "${lang.api("Price")}: ${item["discounted_price"]} $curr",
                                                style: TextStyle(
                                                  fontFamily: "Roboto",
                                                ),
                                              ),
                                              Text(
                                                "${priceFormat.format(subTotal)} $curr",
                                                textDirection:
                                                    TextDirection.ltr,
                                                style: TextStyle(
                                                  fontFamily: "Roboto",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          item["new_sub_item"] is Map
                                              ? Container(
                                                  child: ListView.builder(
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        item["new_sub_item"]
                                                            .keys
                                                            .toList()
                                                            .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      String key =
                                                          item["new_sub_item"]
                                                              .keys
                                                              .toList()[index];
                                                      return Container(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              key,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            ListView.builder(
                                                              primary: false,
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  item["new_sub_item"]
                                                                          [key]
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                Map subItem =
                                                                    item["new_sub_item"]
                                                                            [
                                                                            key]
                                                                        [index];
                                                                return Container(
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        "${subItem["addon_qty"]} x ${subItem["addon_price"]} $curr",
                                                                        textDirection:
                                                                            TextDirection.ltr,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              "Roboto",
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              6),
                                                                      Expanded(
                                                                        child: Text(
                                                                            "${subItem["addon_name"]}"),
                                                                      ),
                                                                      Text(
                                                                        "${priceFormat.format(int.parse(subItem["addon_qty"]) * double.parse(subItem["addon_price"] is bool ? "0" : subItem["addon_price"]))} $curr",
                                                                        textDirection:
                                                                            TextDirection.ltr,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              "Roboto",
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Container(),
//                                          new_sub_item
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      itemQty.isEmpty
                          ? Container()
                          : Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              width: MediaQuery.of(context).size.width,
                              child: RaisedButton(
                                textColor: Colors.white,
                                color: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                onPressed: () async {
                                  showLoadingDialog();
                                  List l = itemQty.keys.toList();
                                  for (int i = 0; i < l.length; i++) {
                                    String key = l[i];
                                    Map element = itemQty[key];
                                    await _repo.addToCart({
                                      "category_id": element["category_id"],
                                      "item_id":
                                          int.parse("${element["item_id"]}"),
                                      "two_flavors": "0",
                                      "price": element["normal_price"],
                                      "ingredients": element["ingredients"],
                                      "cooking_ref": element["cooking_ref"],
                                      "new_sub_item": element["new_sub_item"],
//                                      "sub_item": element["sub_item"],
                                      "notes": "",
                                      "row":
                                          int.parse("${element["row"]}"), //i,
                                      "qty": element["qty"]
                                    });
                                  }
                                  Navigator.of(context).pop();
                                  await PrefManager()
                                      .set("load_cart_count", true);
                                  init();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check),
                                    Text(
                                      lang.api("Apply"),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      Divider(height: 4, color: Colors.black54),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${lang.api("Discount")} (${total["merchant_discount_amount"]} %)",
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "-${total["discounted_amount"]} ${total["curr"]}",
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Roboto",
//                              color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang.api("Sub Total"),
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${total["subtotal"]} ${total["curr"]}",
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontFamily: "Roboto",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                details["merchant_settings"]["enabled_voucher"] != "yes"
                    ? Container()
                    : SizedBox(height: 16),
                details["merchant_settings"]["enabled_voucher"] != "yes"
                    ? Container()
                    : VoucherWidget(
                        scaffoldKey: _scaffoldKey,
                        transactionType: transactionType,
                        reloadCart: () {
                          init();
                        },
                      ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      lang.api("About the order"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    transactionType["key"] == "delivery" &&
                            details.containsKey("checkout_stats") &&
                            details["checkout_stats"] is Map &&
                            details["checkout_stats"]
                                .containsKey("is_pre_order") &&
                            "${details["checkout_stats"]["is_pre_order"]}" !=
                                "1"
                        ? Row(
                            children: <Widget>[
                              Text(lang.api("Delivery Asap")),
                              Switch(
                                onChanged: (value) {
                                  setState(() {
                                    deliveryAsap = value;
                                  });
                                },
                                activeColor: Theme.of(context).primaryColor,
                                value: deliveryAsap,
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
                Card(
                  child: Container(
                    child: Column(
                      children: [
                        transactionType["key"] != "delivery"
                            ? Container()
                            : AboutCart(
                                text: lang.api("Delivery Address"),
                                value: deliveryAddress,
                                onTap: () async {
                                  bool result =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return AddressSelector();
                                    }),
                                  );
                                  if (result != null && result) {
                                    bool deliveryAsapTemp = deliveryAsap;
                                    await init();
                                    setState(() {
                                      deliveryAsap = deliveryAsapTemp;
                                    });
                                  }
                                },
                              ),
                        transactionType["key"] != "delivery"
                            ? Container()
                            : Divider(color: Colors.grey, height: 2),
                        AboutCart(
                          text: lang.api("Transaction Type"),
                          value: details["services"][transactionType["key"]],
                          onTap: () async {
                            var serviceResult =
                                await showListDialog("services", "label");
                            if (serviceResult != null &&
                                transactionType["key"] !=
                                    serviceResult["key"]) {
                              transactionType = serviceResult;
                              init();
                            }
                          },
                        ),
                        deliveryAsap
                            ? Container()
                            : Divider(color: Colors.grey, height: 2),
                        deliveryAsap
                            ? Container()
                            : AboutCart(
                                text: transactionType["key"] == "pickup"
                                    ? lang.api("Pickup Date")
                                    : lang.api("Delivery Date"),
                                value: deliveryDate.containsKey("label")
                                    ? deliveryDate["label"]
                                    : deliveryDate["key"],
                                onTap: () async {
//                          var dateResult =
//                              await showListDialog("dates", "label");
//                          if (dateResult != null) {
//                            setState(() {
//                              deliveryDate = dateResult;
//                            });
//                          }
                                  List dates = mapList["dates"];
                                  if (dates == null) {
                                    showLoadingDialog();
                                    Map<String, dynamic> response =
                                        await _repo.deliveryDateList();
                                    Navigator.of(context).pop();
                                    if (response.containsKey("code") &&
                                        response["code"] == 1) {
                                      dates = getKeyValList(
                                          response["details"]["data"]);
                                      check(response, "dates");
                                    }
                                  }
//                          "2020-07-11"
                                  if (dates == null) {
                                    showError(
                                        _scaffoldKey,
                                        lang.api(
                                            "Fail to load delivery date list"));
                                  }
                                  DateTime firstDate = DateFormat("yyyy-MM-dd")
                                      .parse("${dates.first["key"]}");
                                  DateTime lastDate = DateFormat("yyyy-MM-dd")
                                      .parse("${dates.last["key"]}");

                                  final DateTime picked = await showDatePicker(
                                    context: context,
                                    locale: Locale(lang.currentLanguage),
                                    initialDate: DateTime.now(),
                                    firstDate: firstDate,
                                    lastDate: lastDate,
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      deliveryDate = {
                                        "key": DateFormat("yyyy-MM-dd",
                                                lang.currentLanguage)
                                            .format(picked),
                                        "label": DateFormat("dd MMM, yyyy",
                                                lang.currentLanguage)
                                            .format(picked),
                                      };
                                    });
                                  }
                                },
                              ),
                        deliveryAsap
                            ? Container()
                            : Divider(color: Colors.grey, height: 2),
                        deliveryAsap
                            ? Container()
                            : AboutCart(
                                text: transactionType["key"] == "pickup"
                                    ? lang.api("Pickup Time")
                                    : lang.api("Delivery Time"),
                                value: deliveryTime.containsKey("label")
                                    ? deliveryTime["label"]
                                    : deliveryTime["key"],
                                onTap: () async {
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
//                          List times = mapList["times"];
//                          if(times == null){
//                            Map<String, dynamic> response = await _repo.deliveryTimeList();
//                            if(response.containsKey("code") && response["code"] == 1){
//                              times = getKeyValList(response["details"]["data"]);
//                              check(response, "times");
//                            }
//                          }
                                  if (picked != null) {
                                    // times != null ||
//                            Map first = times.first;
//                            Map last = times.last;
                                    DateTime selectedTime = DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day,
                                        picked.hour,
                                        picked.minute);
//                            DateTime firstTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse("${deliveryDate["key"]} ${first["key"]}");
//                            DateTime lastTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse("${deliveryDate["key"]} ${last["key"]}");
//                            print("firstTime: $firstTime");
//                            print("lastTime: $lastTime");
//                            if (selectedTime.isBefore(firstTime) ||
//                                selectedTime.isAfter(lastTime)) {
//                              showError(_scaffoldKey, lang.api("Merchant is now close and not accepting any orders"));
//                              return;
//                            }
                                    deliveryTime = {
                                      "key": DateFormat("H:mm:ss")
                                          .format(selectedTime),
                                      "label": DateFormat("hh:mm a")
                                          .format(selectedTime),
                                    };
//                              print("deliveryTime: $deliveryTime");
                                    DateTime dateTime =
                                        DateFormat("yyyy-MM-dd HH:mm:ss").parse(
                                            "${deliveryDate["key"]} ${deliveryTime["key"]}");
                                    if (dateTime.compareTo(DateTime.now()) <
                                        0) {
                                      showError(
                                          _scaffoldKey,
                                          lang.api(
                                              "Sorry but you have selected Delivery Time that already past"));
                                      return;
                                    }

//                            if (DateTime.now().isAfter(selectedTime)) {
//                              showError(_scaffoldKey, lang.api("Sorry but you have selected Delivery Time that already past"));
//                              return;
//                            }

//                            var timeResult = await showListDialog("times", "label");
//                            if (timeResult != null) {
//                              deliveryTime = timeResult;
//                            }
                                    setState(() {});
                                  }
                                },
                              ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                CartPrices(
                  total: total,
                ),
                SizedBox(height: 16),
                AlternativeButton(
                  label: lang.api("Place Order"),
                  onPressed: details["cart_error"].isNotEmpty ? null : checkout,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future showListDialog(String name, String displayName) async {
    var item = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Container(
            child: getList(name, displayName), // , isLoaded[name]
          ),
          contentPadding: EdgeInsets.all(0),
        );
      },
    );
    return item;
  }

  Widget getList(String name, String displayName) {
    List list = mapList[name];
    if (list == null) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: LoadingWidget(),
      );
    } else {
      if (list.length == 0) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: EmptyWidget(),
        );
      } else {
        return widgetList(list, displayName, name);
      }
    }
  }

  Widget widgetList(List list, String displayName, String type) {
    if (list.length <= 3) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(list.length, (index) {
          return Container(
            child: ListTile(
              onTap: () {
                Navigator.of(context).pop(list[index]);
              },
              title: Text(list[index][displayName]),
            ),
          );
        }),
      );
    }
    if (type == "times") {
      return getTimesList(list);
    }
    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: ListTile(
            onTap: () {
              Navigator.of(context).pop(list[index]);
            },
            title: Text(list[index][displayName]),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 1,
          color: Colors.grey,
        );
      },
    );
  }

  Widget getTimesItem(var item) {
    String label = item["label"].substring(0, item["label"].lastIndexOf(":"));
    String sun =
        item["label"].substring(item["label"].toString().indexOf(" ") + 1);
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(item);
        },
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                sun.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTimesList(list) {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          width: MediaQuery.of(context).size.width,
          child: Text(
            transactionType["key"] == "pickup"
                ? lang.api("Pickup Time")
                : lang.api("Delivery Time"),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.all(8),
          itemCount: list.length,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 4 / 2, mainAxisSpacing: 1.0),
          itemBuilder: (BuildContext context, int index) {
            var item = list[index];
            return getTimesItem(item);
          },
        ),
      ],
    );
  }

  bool validateCheckout() {
    bool valid = false;
    if (transactionType["key"] == null ||
        transactionType["key"].toString().isEmpty) {
      showError(_scaffoldKey, lang.api("Transaction type is required"));
      return false;
    }
    switch (transactionType["key"]) {
      case "delivery":
        if (deliveryAddress == lang.api("Please enter address here")) {
          showError(_scaffoldKey, lang.api("Please enter delivery address"));
          return false;
        }
        if (deliveryTime["key"].toString().isEmpty) {
          showError(_scaffoldKey, lang.api("Delivery time is required"));
        } else if (deliveryDate["key"].toString().isEmpty) {
          showError(_scaffoldKey, lang.api("Delivery date is required"));
        }
        break;
    }
    return valid;
  }

  checkout() async {
    if (transactionType["key"] == null ||
        transactionType["key"].toString().isEmpty) {
      showError(_scaffoldKey, lang.api("Transaction type is required"));
    } else if (deliveryAddress == lang.api("Please enter address here") &&
        transactionType["key"] == "delivery") {
      showError(_scaffoldKey, lang.api("Please enter delivery address"));
    } else if (deliveryTime["key"].toString().isEmpty && !deliveryAsap) {
      if (transactionType["key"] == "delivery") {
        showError(_scaffoldKey, lang.api("Delivery time is required"));
      } else {
        showError(_scaffoldKey, lang.api("Pickup time is required"));
      }
    } else if (deliveryDate["key"].toString().isEmpty) {
      if (transactionType["key"] == "delivery") {
        showError(_scaffoldKey, lang.api("Delivery date is required"));
      } else {
        showError(_scaffoldKey, lang.api("Pickup date is required"));
      }
    } else {
      if (!deliveryAsap) {
        DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse("${deliveryDate["key"]} ${deliveryTime["key"]}");
        if (dateTime.compareTo(DateTime.now()) < 0) {
          showError(
              _scaffoldKey,
              lang.api(
                  "Sorry but you have selected Delivery Time that already past"));
          return;
        }
      }

      showLoadingDialog();
      Map<String, dynamic> preReq = {
        "delivery_date": deliveryDate["key"],
        "transaction_type": transactionType["key"],
      };
      if (deliveryTime["key"].toString().isNotEmpty) {
        if (deliveryAsap) {
          preReq["delivery_time"] = "";
        } else {
          preReq["delivery_time"] = deliveryTime["key"];
        }
      }
      Map<String, dynamic> response = await _repo.preCheckout(preReq);
      Navigator.of(context).pop();
      if (response.containsKey("code") && response["code"] == 1 ||
          response["code"] == 2) {
        await _prefManager.set("load_cart_count", true);
        bool isContinue = true;
        if (response["details"]["future_order"] &&
            response["details"]["future_order_confirm"] == "1") {
          isContinue = await showCustomSuccessDialog(
            context,
            isDismissible: false,
            title: lang.api("Cart"),
            subtitle: response["details"]["future_order_message"],
            positive: lang.api("CONTINUE"),
            negative: lang.api("Cancel"),
          );
        }
        if (isContinue) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return PaymentMethod(
                deliveryAsap: deliveryAsap,
                transactionType: transactionType["key"],
                deliveryTime: deliveryAsap
                    ? ""
                    : deliveryTime.containsKey("label")
                        ? deliveryTime["label"]
                        : deliveryTime["key"],
                deliveryDate: deliveryDate["key"],
              );
            }),
          );
        }
      } else {
        showError(_scaffoldKey, response["msg"]);
      }
    }
  }
}

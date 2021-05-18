import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/merchant/qty_widget.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:flutter/material.dart';

class CartItems extends StatefulWidget {
  final itemQty;
  final VoidCallback onQtyChanged;
  final List items;
  final scaffoldKey;
  final total;
  const CartItems({
    Key key,
    this.itemQty,
    this.onQtyChanged,
    this.scaffoldKey,
    this.items,
    this.total,
  }) : super(key: key);

  @override
  _CartItemsState createState() => _CartItemsState();
}

class _CartItemsState extends State<CartItems> {
  final _repo = Repository();

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListView.separated(
            primary: false,
            shrinkWrap: true,
            itemCount: widget.items.length,
            separatorBuilder: (_, index) {
              return Divider(height: 2, color: Colors.grey);
            },
            itemBuilder: (context, index) {
              var item = widget.items[index];
              var curr = widget.total["curr"];
              double subTotal = double.parse("${item["discounted_price"]}") *
                  int.parse("${item["qty"]}");
              return Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    QtyWidget(
                      qty: "${item["qty"]}",
                      onQtyChanged: (int newQty) {
                        setState(() {
                          if (newQty == null) {
                            widget.itemQty.remove("${item["item_id"]}");
                          } else {
                            widget.itemQty["${item["item_id"]}"] = {
                              "qty": newQty,
                              "item_id": item["item_id"],
                              "category_id": item["category_id"],
                              "normal_price": item["normal_price"]
                            };
                          }
                        });
                      },
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item["item_name_trans"]["item_name_trans"]
                                    [lang.getLanguageText()],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  // 	"Are you sure you want to remove all items in your cart?": {
                                  bool delete = await showCustomErrorDialog(
                                    lang.api("Remove From Cart?"),
                                    lang.api(
                                        "Are you sure you want to remove this item in your cart?"),
                                    lang.api("Remove"),
                                  );
                                  if (delete) {
                                    showLoadingDialog(lang.api("loading"));
                                    Map<String, dynamic> response = await _repo
                                        .removeCartItem({"row": index});
                                    Navigator.of(context).pop();
                                    if (response.containsKey("code") &&
                                        response["code"] == 1) {
                                      if (widget.onQtyChanged != null) {
                                        widget.onQtyChanged();
                                      }
                                    } else {
                                      showError(
                                          widget.scaffoldKey, response["msg"]);
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
                          Text(
                            item["category_name_trans"]["category_name_trans"]
                                [lang.getLanguageText()],
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "${lang.api("Price")}: ${item["discounted_price"]} $curr",
                            style: TextStyle(
                              fontFamily: "Roboto",
                            ),
                          ),
                          Text(
                            "${lang.api("Sub Total")}: $subTotal $curr",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontFamily: "Roboto"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          widget.itemQty.isEmpty
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
                      List l = widget.itemQty.keys.toList();
                      for (int i = 0; i < l.length; i++) {
                        String key = l[i];
                        Map element = widget.itemQty[key];
                        await _repo.addToCart({
                          "category_id": element["category_id"],
                          "item_id": element["item_id"],
                          "two_flavors": "0",
                          "price": element["normal_price"],
                          "notes": "",
                          "row": i,
                          "qty": element["qty"]
                        });
                      }
                      Navigator.of(context).pop();
                      if (widget.onQtyChanged != null) {
                        await PrefManager().set("load_cart_count", true);
                        widget.onQtyChanged();
                      }
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
                  "${lang.api("Discount")} (${widget.total["merchant_discount_amount"]} %)",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  "-${widget.total["discounted_amount"]} ${widget.total["curr"]}",
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
                  "${widget.total["subtotal"]} ${widget.total["curr"]}",
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
    );
  }
}

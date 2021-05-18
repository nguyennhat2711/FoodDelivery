import 'package:afandim/core/services/repository.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:flutter/material.dart';

class CartHeader extends StatefulWidget {
  final scaffoldKey;
  final VoidCallback reloadCart;

  const CartHeader({Key key, this.scaffoldKey, this.reloadCart})
      : super(key: key);

  @override
  _CartHeaderState createState() => _CartHeaderState();
}

class _CartHeaderState extends State<CartHeader> {
  final _repo = Repository();

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          lang.api("Order details"),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          child: InkWell(
            onTap: () async {
              bool delete = await showCustomErrorDialog(
                lang.api("Clear cart?"),
                lang.api(
                    "Are you sure you want to remove all items in your cart?"),
                lang.api("Remove"),
              );
              if (delete) {
                showLoadingDialog(lang.api("loading"));
                Map<String, dynamic> response = await _repo.clearCart();
                Navigator.of(context).pop();
                if (response.containsKey("code") && response["code"] == 1) {
                  await PrefManager().remove("active_merchant");
                  await PrefManager().set("load_cart_count", true);
                  widget.reloadCart();
                } else {
                  showError(widget.scaffoldKey, response["msg"]);
                }
              }
            },
            child: Row(
              children: [
                Text(
                  lang.api("CLEAR CART"),
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                Icon(Icons.cancel, color: Colors.red),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

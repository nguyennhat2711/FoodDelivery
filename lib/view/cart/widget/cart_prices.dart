import 'package:afandim/custom_widget/merchant/total_row.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';

class CartPrices extends StatelessWidget {
  final total;

  const CartPrices({Key key, this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TotalRow(
            text: lang.api("Cart total"),
            value: "${total["subtotal"]} ${total["curr"]}",
          ),
          total["delivery_charges"] != null &&
                  "${total["delivery_charges"]}".isNotEmpty &&
                  double.parse("${total["delivery_charges"]}") > 0
              ? TotalRow(
                  text: lang.api("Delivery Fee"),
                  value:
                      "${double.parse("${total["delivery_charges"]}")} ${total["curr"]}",
                )
              : Container(),
          total["merchant_packaging_charge"] != null &&
                  "${total["merchant_packaging_charge"]}".isNotEmpty &&
                  int.parse("${total["merchant_packaging_charge"]}") > 0
              ? TotalRow(
                  text: lang.api("Packaging"),
                  value:
                      "${double.parse("${total["delivery_charges"]}")} ${total["curr"]}",
                )
              : Container(),
          TotalRow(
            text: lang.api("Voucher Discount"),
            value:
                "-${double.parse("${total["less_voucher"]}")} ${total["curr"]}",
          ),
          total["taxable_total"] != null &&
                  "${total["taxable_total"]}".isNotEmpty &&
                  double.parse("${total["taxable_total"]}") > 0
              ? TotalRow(
                  text:
                      "${lang.api("Tax")} ${(double.parse("${total["tax"]}") * 100)} %",
                  value: "${total["taxable_total"]} ${total["curr"]}",
                )
              : Container(),
          Divider(
            height: 2,
            color: Colors.grey,
          ),
          TotalRow(
            text: lang.api("Total"),
            value: "${double.parse("${total["total"]}")} ${total["curr"]}",
            boldValue: true,
            valueFontSize: 18,
          ),
        ],
      ),
    );
  }
}

import 'package:afandim/custom_widget/divider_middle_text.dart';
import 'package:afandim/helper/closable.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/control_view.dart';
import 'package:afandim/view/order/track_order.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Receipt extends StatefulWidget {
  final String message;
  final data;

  Receipt({Key key, this.message, this.data}) : super(key: key);

  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Closable(
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage("assets/images/logo-shop.png"),
                        width: 180,
                      ),
                      SizedBox(height: 24),
                      Text(
                        lang.api("Order Success"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 40),
                      RaisedButton(
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return TrackOrder(
                                orderId: widget.data["order_id"],
                              );
                            }),
                          );
                        },
                        child: Text(
                          lang.api("Track Order"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: DividerMiddleText(
                          text: lang.api("Or"),
                        ),
                      ),
                      RaisedButton(
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        onPressed: () {
                          Get.off(ControlView());
                        },
                        child: Text(
                          lang.api("BACK TO HOME"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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

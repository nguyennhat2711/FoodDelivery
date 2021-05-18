import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/control_view.dart';
import 'package:afandim/view/order/add_review.dart';
import 'package:afandim/view/order/track_order.dart';
import 'package:afandim/view/order/view_order.dart';
import 'package:afandim/view/support_chat/order_chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderList extends StatefulWidget {
  final String code;
  final String label;
  final Function(String msg) showMessage;

  const OrderList({Key key, this.code, this.label, this.showMessage})
      : super(key: key);

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final _repository = Repository();
  bool isLoading = true;
  List list = [];
  String message;
  String subMessage;

  @override
  void initState() {
    super.initState();
    init(false);
  }

  init([bool forceRefresh = false]) async {
    setState(() {
      isLoading = true;
      list = [];
    });
    Map<String, dynamic> response =
        await _repository.getOrderList({"tab": widget.code}, forceRefresh);
    isLoading = false;
//    print(response);
    if (response.containsKey("code") && response["code"] == 1) {
      list = response["details"]["data"];
    } else {
      if (response.containsKey("details")) {
        message = response["msg"];
        subMessage = response["details"]["message"];
      } else {
        message = lang.api("System error");
        subMessage = lang.api("Fail to load orders");
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    if (isLoading) {
      return LoadingWidget(
          message: lang.api("loading"), useLoader: true, size: 84.0);
    } else {
      if (list.length == 0) {
        return EmptyWidget(
            size: 128.0, message: message, subMessage: subMessage);
      } else {
        return buildList();
      }
    }
  }

  Widget buildList() {
    return RefreshIndicator(
      onRefresh: () async {
        init(true);
        return;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: list.length,
        itemBuilder: (context, index) {
          var item = list[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: InkWell(
              onTap: () async {
                OrderOptions options =
                    await showOrderOptions(context, item, widget.code);
                switch (options) {
                  case OrderOptions.chat:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderChatScreen(
                            item['merchant_id'],
                            item['merchant_name'],
                            item['order_id']),
                      ),
                    );
                    break;
                  case OrderOptions.viewOrder:
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return ViewOrder(
                          orderId: item["order_id"],
                        );
                      }),
                    );
                    break;
                  case OrderOptions.reOrder:
                    showLoadingDialog(lang.api("loading"));
                    Map<String, dynamic> response =
                        await _repository.reOrder(item["order_id"]);
                    Navigator.of(context).pop();
                    if (response.containsKey("code") && response["code"] == 1) {
                      await PrefManager()
                          .set("active_merchant", item["merchant_id"]);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) {
                        return ControlView(
                          selectedIndex: 3,
                        );
                      }), ModalRoute.withName("/no_route"));
                    } else {
                      widget.showMessage(response["msg"]);
                    }
                    break;
                  case OrderOptions.addReview:
                    bool result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return AddReview(
                          orderData: item,
                        );
                      }),
                    );
                    if (result != null && result) {
                      init(true);
                    }
                    break;
                  case OrderOptions.cancelOrder:
                    break;
                  case OrderOptions.trackOrder:
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return TrackOrder(
                          orderId: item["order_id"],
                        );
                      }),
                    );
                    break;
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: item["logo"],
                          width: 46,
                          height: 46,
                          placeholder: (context, text) {
                            return Image(
                              image: AssetImage(
                                  "assets/images/logo-placeholder.png"),
                              width: 46,
                              height: 46,
                            );
                          },
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${item["merchant_name"] ?? lang.api("Merchant deleted")}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("${lang.api("Status")}: ${item["status"]}"),
                              Text(
                                  "${lang.api("Order ID")}: ${item["order_id"]}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        height: 2,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time),
                            SizedBox(width: 4),
                            Text(
                                "${timeago.format(DateTime.parse(item["date_created_raw"]), locale: lang.currentLanguage)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.star),
                            SizedBox(width: 4),
                            Text("${item["rating"] ?? 0}"),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        height: 2,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item["payment_type"],
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          item["total_w_tax"],
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

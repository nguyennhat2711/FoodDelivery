import 'dart:convert';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/order/track_driver.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TrackOrder extends StatefulWidget {
  final String orderId;

  TrackOrder({
    Key key,
    @required this.orderId,
  }) : super(key: key);

  @override
  _TrackOrderState createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  final _repo = Repository();
  bool isLoading = true;
  Map orderHistoryDetails;
  String message;
  String subMessage = "";
  bool canTrack = true;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await _repo.getOrderHistory(widget.orderId);
    if (response.containsKey("code") && response["code"] == 1) {
      orderHistoryDetails = response["details"];
      Map<String, dynamic> runTrack =
          await _repo.checkRunTrackHistory(widget.orderId);
      print("runTrack: $runTrack");
      if (runTrack.containsKey("code") && runTrack["code"] == 1) {}
    } else {
      message = response["msg"];
      if (response["details"] != null &&
          response["details"].containsKey("message")) {
        subMessage = response["details"]["message"];
      }
    }
    isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.api("Track Order") //
            ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.autorenew), onPressed: isLoading ? null : init),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: getBody(),
      ),
    );
  }

  Widget getBody() {
    if (isLoading) {
      return LoadingWidget(
        size: 84.0,
        useLoader: true,
        message: lang.api("loading"),
      );
    } else {
      if (orderHistoryDetails == null) {
        return EmptyWidget(
          message: message,
          subMessage: subMessage ?? "",
          size: 128,
        );
      } else {
        return buildBody();
      }
    }
  }

//
  Widget buildBody() {
    return Container(
      child: RefreshIndicator(
        onRefresh: () {
          init();
          return;
        },
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          children: <Widget>[
            SizedBox(height: 8),
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: orderHistoryDetails["order_info"]["logo"],
                  width: 46,
                  height: 46,
                  placeholder: (context, text) {
                    return Image(
                      image: AssetImage("assets/images/logo-placeholder.png"),
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
                        orderHistoryDetails["order_info"]["merchant_name"],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                          "${lang.api("Status")}: ${lang.api(orderHistoryDetails["order_info"]["status_raw"])}"),
                      Text(
                          "${orderHistoryDetails["order_info"]["transaction"]}"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            buildList(),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget buildList() {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: orderHistoryDetails["data"].length,
      itemBuilder: (context, index) {
        var item = orderHistoryDetails["data"][index];
        print("item: ${json.encode(item)}");
//        if(["successful", "declined", "delivered", "paid", "failed"].contains(item["status_raw"])){
//          canTrack = false;
//        }
        return Card(
          margin: EdgeInsets.all(8),
          child: InkWell(
            onTap: (item["status_raw"] == "started" && canTrack)
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return TrackDriver(
                          orderId: widget.orderId,
                        );
                      }),
                    );
                  }
                : null,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item["status"],
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item["remarks"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(item["date"]),
                      ],
                    ),
                  ),
                  item["status_raw"] == "started" && canTrack
                      ? Container(
                          child: Column(
                            children: <Widget>[
                              Image(
                                image: AssetImage(
                                    "assets/images/logo-delivary.png"),
                                height: 64,
                                width: 64,
                                fit: BoxFit.contain,
                              ),
                              Text(
                                lang.api("Track driver"),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

class ViewOrder extends StatefulWidget {
  final String orderId;

  ViewOrder({Key key, this.orderId}) : super(key: key);

  @override
  _ViewOrderState createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  final _repo = Repository();
  bool isLoading = true;
  Map details;
  String message;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await _repo.viewOrder(widget.orderId);
    if (response.containsKey("code") && response["code"] == 1) {
      details = response["details"];
    } else {
      message = response["msg"];
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
        title: Text(lang.api("Order Receipt")),
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
        size: 84.0,
        useLoader: true,
        message: lang.api("loading"),
      );
    } else {
      if (details == null) {
        return EmptyWidget(
          message: message,
          size: 128,
        );
      } else {
        return buildBody();
      }
    }
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              lang.api("Order Receipt"),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${lang.api("Order ID")}: ${widget.orderId}",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            getKeyValue(),
            getHtml(),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget getHtml() {
    return Html(
      data: details["html"],
      style: {
        ".text-right": Style.fromTextStyle(TextStyle(
          fontWeight: FontWeight.bold,
        )),
      },
    );
  }

  Widget getKeyValue() {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: details["data"].length,
      itemBuilder: (context, index) {
        Map item = details["data"][index];
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item["label"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item["value"],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

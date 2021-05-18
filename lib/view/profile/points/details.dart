import 'dart:io';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final Map item;

  const Details({Key key, this.item}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final _repository = Repository();
  bool isLoading = true;
  List list = [];
  String message;
  String subMessage;

  @override
  void initState() {
    super.initState();
    init();
  }

  init([bool forceRefresh = false]) async {
    setState(() {
      isLoading = true;
      list = [];
    });
    Map<String, dynamic> response =
        await _repository.getPointDetails(widget.item["point_type"]);
    isLoading = false;
    if (response.containsKey("success") && response["success"]) {
    } else {
      message = response["msg"];
      subMessage = response["details"]["message"];
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
    return CustomPage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text(
                  "${widget.item["label"]}",
                  textAlign:
                      Platform.isIOS ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  init(true);
                },
                icon: Icon(
                  Icons.autorenew,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Card(
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 4,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  getListView(),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getListView() {
    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// todo
            LoadingWidget(),
//            Loading(indicator: BallPulseIndicator(), size: 82.0,color: Theme.of(context).primaryColor),
//             SpinKitThreeBounce(
//               size: 82.0,
//               color: Theme.of(context).primaryColor,
//             ),
            Text(
              lang.api("Loading..."),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      if (list.length == 0) {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16.0),
          child: EmptyWidget(
            size: 128.0,
            message: message,
          ),
        );
      } else {
        return Container(
          child: Text("${list.toString()}"),
        );
      }
    }
  }
}

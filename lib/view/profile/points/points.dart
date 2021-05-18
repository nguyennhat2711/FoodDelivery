import 'dart:io';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/profile/points/details.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Points extends StatefulWidget {
  @override
  _PointsState createState() => _PointsState();
}

class _PointsState extends State<Points> {
  final _repository = Repository();
  bool isLoading = true;
  List list = [];

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
    Map<String, dynamic> response = await _repository.getPointSummary();
    isLoading = false;
    if (response.containsKey("success") && response["success"]) {
      list = response["details"]["data"];
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
                  lang.api("Points"),
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
          Container(
            child: getListView(),
          ),
        ],
      ),
    );
  }

  Widget getListView() {
    if (isLoading) {
      return getList();
    } else {
      if (list.length == 0) {
        return Card(
          margin: EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 4,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16.0),
            child: EmptyWidget(
              size: 128.0,
            ),
          ),
        );
      } else {
        return getList();
      }
    }
  }

  Widget getList() {
    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: isLoading ? 4 : list.length,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 3.5 / 4, mainAxisSpacing: 1.0),
      itemBuilder: (BuildContext context, int index) {
        if (!isLoading) {
          var item = list[index];
          return getCard(item);
        } else {
          return Card(
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Container(
                          height: 64,
                          width: 64,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[500],
//                    borderRadius: BorderRadius.circular(80)
                          ),
                        ),
                        Container(
                          height: 18,
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.all(8),
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget getCard(item) {
    var value = "${item["value"]}";
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return Details(
                item: item,
              );
            }),
          );
        },
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: value.length <= 3 ? 72 : 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                "${item["label"]}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final _repository = Repository();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoading = true;
  List list = [];
  String message;

  @override
  void initState() {
    init(forceRefresh: true);
    super.initState();
  }

  init({bool forceRefresh = false}) async {
    setState(() {
      isLoading = true;
      list = [];
    });
    Map<String, dynamic> response = await _repository.getNotifications();
    isLoading = false;
    if (response.containsKey("success") && response["success"]) {
      list = response["details"]["data"];
    } else {
      if (response.containsKey("details") &&
          response["details"].containsKey("message")) {
        message = response["details"]["message"];
      } else {
        message = lang.api("System error, please try again");
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
    return CustomPage(
      scaffoldKey: _scaffoldKey,
      onRefresh: () async {
        await init();
        return;
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              list.isEmpty
                  ? Container()
                  : IconButton(
                      onPressed: list.isEmpty
                          ? null
                          : () async {
                              bool remove = await showCustomErrorDialog(
                                lang.api("Remove all notification"),
                                lang.api("Are you sure?"),
                                lang.api("Yes"),
                              );
                              if (remove != null && remove) {
                                showLoadingDialog();
                                await _repository.markAllNotifications();
                                Navigator.of(context).pop();
                                init(forceRefresh: true);
                              }
                            },
                      icon: Icon(
                        Icons.delete,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          lang.api("Notifications"),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          lang.api("Push Logs"),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  getListView(),
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
      return getLoadingList();
    } else {
      if (list.length > 0) {
        return getList();
      } else {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 260,
          child: EmptyWidget(
            message: message,
            size: 128,
          ),
        );
      }
    }
  }

  Widget getList() {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        Map item = list[index];
        return getItemWidget(item);
      },
    );
  }

  Widget getItemWidget(item) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          onOrderClicked(item);
        },
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item["push_title"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(item["push_message"]),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey,
                height: 0,
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.access_time,
                      color: Colors.grey,
                    ),
                    Expanded(
                      child: Text(
                        item["date_created"],
                        style: TextStyle(
                          color: Colors.grey,
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
    );
  }

  onOrderClicked(item) async {
    NotificationOptions options = await showNotificationOptions(context);
    if (options == NotificationOptions.delete) {
      bool remove = await showCustomErrorDialog(
        lang.api("Remove from notification list"),
        lang.api("Are you sure?"),
        lang.api("Yes"),
      );
      if (remove != null && remove) {
        showLoadingDialog();
        Map<String, dynamic> request =
            await _repository.readNotification(item["id"]);
        Navigator.of(context).pop();
        if (request.containsKey("code") && request["code"] == 1) {
          init(forceRefresh: true);
        } else {
          showError(_scaffoldKey, request["msg"]);
        }
      }
    }
  }

  Widget getLoadingList() {
    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemCount: 4,
      separatorBuilder: (_, index) {
        return Divider(
          height: 2,
          color: Colors.grey,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  height: 64,
                  width: 64,
                  padding: EdgeInsets.all(8),
                  color: Colors.grey[500],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: MediaQuery.of(context).size.width / 2,
                        margin: EdgeInsets.all(8),
                        color: Colors.grey[500],
                      ),
                      Container(
                        height: 18,
                        width: MediaQuery.of(context).size.width / 3,
                        margin: EdgeInsets.all(8),
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

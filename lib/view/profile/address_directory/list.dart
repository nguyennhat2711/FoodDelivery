import 'dart:io';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import 'add.dart';
import 'edit.dart';

class AddressDirectory extends StatefulWidget {
  @override
  _AddressDirectoryState createState() => _AddressDirectoryState();
}

class _AddressDirectoryState extends State<AddressDirectory> {
  final _repository = Repository();
  bool isLoading = true;
  List list = [];
  String message;

  @override
  void initState() {
    super.initState();
    init(true);
  }

  init([bool forceRefresh = false]) async {
    setState(() {
      isLoading = true;
      list = [];
    });
    Map<String, dynamic> response = await _repository.getAddressBookList();
    isLoading = false;
    if (response.containsKey("success") && response["success"]) {
      list = response["details"]["data"];
    } else {
      message = response["msg"];
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  lang.api("Address Book"),
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
                icon: Icon(
                  Icons.autorenew,
                  color: Colors.white,
                ),
                onPressed: () {
                  init(true);
                },
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              lang.api("Manage your list of saved addresses"),
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            child: getListView(),
          ),
        ],
      ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              tooltip: lang.api("Add New Address"),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return AddAddressDirectory(
                      fromOrder: false,
                    );
                  }),
                );
                init(true);
              },
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
              message: message,
            ),
          ),
        );
      } else {
        return getList();
      }
    }
  }

  Widget getList() {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: isLoading ? 4 : list.length,
      itemBuilder: (BuildContext context, int index) {
        if (!isLoading) {
          var item = list[index];
          return getCard(item);
        } else {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 4,
            child: Shimmer.fromColors(
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
            ),
          );
        }
      },
    );
  }

  Widget getCard(item) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4,
      child: InkWell(
        onTap: () async {
          var result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return EditAddressDirectory(
                id: item["id"],
              );
            }),
          );
          if (result is bool && result) {
            init(true);
          }
        },
        child: Container(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/icons/home.svg",
                color: Colors.grey,
                width: 54,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["address"],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item["date_created"],
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
}

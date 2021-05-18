import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/routes.dart';
import 'package:afandim/helper/utils.dart';
import 'package:afandim/view/profile/credit_cards/edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class CreditCards extends StatefulWidget {
  @override
  _CreditCardsState createState() => _CreditCardsState();
}

class _CreditCardsState extends State<CreditCards> {
  final _repository = Repository();
  bool isLoading = true;
  List list = [];
  String message;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      isLoading = true;
      list = [];
    });
    Map<String, dynamic> response = await _repository.getCreditCartList();
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
              Text(
                lang.api("Credit Cards"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              lang.api("Manage your list of saved cards"),
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
              tooltip: lang.api("Add New Card"),
              onPressed: () {
                Navigator.of(context).pushNamed(addCardRoute);
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
          return Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Card(
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 4,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 180,
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
      color: Colors.grey[300],
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return EditCard(
                ccId: item["id"],
              );
            }),
          );
        },
        child: Container(
          height: 180,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SvgPicture.asset(
                "assets/icons/visa.svg",
                height: 32,
              ),
              Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["card_name"],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatCardNumber(item["credit_card_number"], false),
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              textDirection: TextDirection.ltr,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.api("CVV"),
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "XXX",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              textDirection: TextDirection.ltr,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "GOOD THRU",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "MM/YY",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(),
                          ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

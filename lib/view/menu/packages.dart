import 'package:afandim/core/services/repository.dart';
import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/config.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/utils.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Packages extends StatefulWidget {
  final Function(Map) onPackageSelected;

  Packages({
    Key key,
    @required this.onPackageSelected,
  }) : super(key: key);

  @override
  _PackagesState createState() => _PackagesState();
}

class _PackagesState extends State<Packages> {
  final _repo = Repository();
  List list = [];
  bool isLoading = true;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    setState(() {
      isLoading = true;
      list = [];
    });
    final provider = context.read(generalProvider);
    String url =
        "${provider.apiBaseUrl}/api/merchantPackageList?x-api-key=$xApiKey&post_type=get";
    Map<String, dynamic> response = await _repo.callUrl(url);
    isLoading = false;
    if (response.containsKey("details") && response["details"] is List) {
      list = response["details"];
    }
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    if (isLoading) {
      return LoadingWidget(
        size: 84.0,
        message: lang.api("loading"),
        useLoader: true,
      );
    } else {
      if (list.isEmpty) {
        return EmptyWidget(
          size: 128,
        );
      }
    }
    return Container(
      padding: EdgeInsets.only(top: 24),
      child: CarouselSlider.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int itemIndex, int ss) {
          return getItem(itemIndex);
        },
        options: CarouselOptions(
          autoPlay: true,
          enableInfiniteScroll: false,
          pauseAutoPlayOnManualNavigate: true,
//          enlargeCenterPage: true,
          height: 320,
//        autoPlayCurve: Curves.bounceIn,
        ),
      ),
    );
  }

  Widget getItem(int index) {
    var item = list[index];
    var expiration = item["expiration"];
    if (item["expiration_type"] == "year") {
      expiration = int.parse(item["expiration"]) / 365;
    }
    List rows = [
      {
        "label": "${lang.api("Membership Limit")}",
        "value": "$expiration ${lang.api(item["expiration_type"])}",
      },
      {
        "label": "${lang.api("Sell Limit")}",
        "value":
            "${item["sell_limit"] == "0" ? lang.api("Unlimited") : item["sell_limit"]}",
      },
      {
        "label": "${lang.api("Usage")}",
        "value":
            "${item["post_limit"] == "0" ? lang.api("Unlimited") : lang.api("Limited")}",
      },
    ];
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
        child: Column(
          children: <Widget>[
            Text(
              lang.api(item["title"]),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "${customRound(double.parse("${item["price"]}"), 2)} ${lang.api("TL")}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  fontFamily: "Roboto",
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Text(
              lang.api(item["description"]),
//              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              primary: false,
              itemCount: rows.length,
              padding: EdgeInsets.symmetric(horizontal: 8),
              separatorBuilder: (_, i) {
                return Divider();
              },
              itemBuilder: (context, index) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        rows[index]["label"],
                        style: TextStyle(
//                        color: Colors.white,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rows[index]["value"],
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 8),
            RaisedButton(
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              onPressed: () {
                widget.onPackageSelected(item);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.check_circle),
                  SizedBox(width: 8),
                  Text(
                    lang.api("Select"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

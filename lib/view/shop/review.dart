import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/circle_image.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/rating_bar.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:timeago/timeago.dart' as timeago;

class Review extends StatefulWidget {
  final String merchantId;
  final List list;
  final bool forceRefresh;
  final Function(List) onLoadReviews;

  const Review({
    Key key,
    @required this.merchantId,
    this.list,
    @required this.onLoadReviews,
    this.forceRefresh,
  }) : super(key: key);

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final _repo = Repository();
  List list = [];
  bool isLoading = true;
  String message;
  String subMessage;
  final _randomColor = RandomColor();
  double avgRating = 0.0;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    if (widget.list == null) {
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> response =
          await _repo.getReviewList(widget.merchantId);
      isLoading = false;
      print("response: $response");
      if (response.containsKey("code") && response["code"] == 1) {
        list = response["details"]["data"];
        widget.onLoadReviews(list);
      } else {
        message = response["msg"];
        if (response.containsKey("details") &&
            response["details"].containsKey("message")) {
          subMessage = response["details"]["message"];
        }
      }
    } else {
      isLoading = false;
      list = widget.list;
    }
    for (int i = 0; i < list.length; i++) {
      avgRating += double.parse("${list[i]["rating"]}");
    }
    avgRating /= list.length;
    setState(() {});
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.api("Review")),
        centerTitle: true,
      ),
      body: SafeArea(
        child: getBody(),
      ),
    );
  }

  Widget getBody() {
    if (isLoading) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: LoadingWidget(
          message: lang.api("loading"),
          useLoader: true,
          size: 82.0,
        ),
      );
    } else {
      if (list.length == 0) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: EmptyWidget(
                message: message,
                size: 128,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            subMessage != null
                ? Text(
                    subMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  )
                : Container(),
          ],
        );
      } else {
        return Column(
          children: [
            SizedBox(height: 32),
            Text(
              "$avgRating",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            RatingBar(
              onChanged: (value) {},
              size: 24,
              rating: avgRating,
            ),
            Text(
              "${lang.api("Based on")} ${list.length} ${lang.api("reviews")}",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = list[index];
                  print("item: $item");
                  item["avatar"] = "";
                  if (item["as_anonymous"] != "0") {
                    item["customer_name"] = lang.api("Afandim User");
                  }
                  return Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            item["avatar"].toString().isEmpty
                                ? CircleAvatar(
                                    backgroundColor: _randomColor.randomColor(),
                                    child: Text(
                                      getFirstChars(item["customer_name"]),
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : CircleImage(
                                    borderWidth: 0,
                                    child: CachedNetworkImage(
                                      imageUrl: item["avatar"],
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["customer_name"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          RatingBar(
                                            onChanged: (value) {},
                                            size: 14,
                                            rating: double.parse(
                                                "${item["rating"]}"),
                                          ),
                                          SizedBox(width: 16),
                                          Text(
                                            "${item["rating"]}",
                                          ),
                                        ],
                                      ),
                                      Text(
                                          "${timeago.format(DateTime.parse(item["date_created"]), locale: lang.currentLanguage)}"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 8),
                          width: MediaQuery.of(context).size.width,
                          child: Text(item["review"]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
    }
  }
}

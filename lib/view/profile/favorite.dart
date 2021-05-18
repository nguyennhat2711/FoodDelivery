import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/custom_rating_bar.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/restaurant_details/restaurant_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Favorite extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  final _repository = Repository();
  bool isLoading = true;
  List list = [];
  String message;

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
    Map<String, dynamic> response = await _repository.getFavoriteList();
    isLoading = false;
    if (response.containsKey("success") && response["success"]) {
      list = response["details"]["data"];
    } else {
      message = response["msg"];
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.api("Favorites")),
      ),
      body: getListView(),
    );
  }

  Widget getListView() {
    if (isLoading) {
      return ListView.builder(
        itemCount: 4,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 120,
                      color: Colors.grey[500],
                      margin: EdgeInsets.all(4),
                    ),
                    Container(
                      height: 18,
                      width: MediaQuery.of(context).size.width / 2,
                      margin: EdgeInsets.all(4),
                      color: Colors.grey[500],
                    ),
                    Container(
                      height: 18,
                      width: MediaQuery.of(context).size.width / 3,
                      margin: EdgeInsets.all(4),
                      color: Colors.grey[500],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      if (list.length == 0) {
        return EmptyWidget(
          size: 128.0,
          message: message,
        );
      } else {
        return getList();
      }
    }
  }

  Widget getList() {
    return RefreshIndicator(
      onRefresh: () async {
        await init(true);
        return;
      },
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          var item = list[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return MerchantDetailsView(
                      merchantId: item["merchant_id"],
                    );
                  }),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: item["background_url"],
                      width: MediaQuery.of(context).size.width,
                      height: 120,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedNetworkImage(
                          imageUrl: item["logo"],
                          fit: BoxFit.cover,
                          width: 64,
                          height: 64,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${item["merchant_name"] ?? lang.api("Merchant deleted")}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              CustomRatingBar(
                                onChanged: (value) {},
                                numStars: 5,
                                rating: double.parse("${item.rating.ratings}") *
                                    1.0,
                                size: 14,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "${item["date_added"]}",
                                style: TextStyle(),
                              ),
                            ],
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

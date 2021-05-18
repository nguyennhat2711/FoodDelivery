import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/merchant/service_badge.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/helper/utils.dart';
import 'package:afandim/model/search_merchant.dart';
import 'package:afandim/view/home/home_widget/home_header_widget.dart';
import 'package:afandim/view/home/home_widget/services_list.dart';
import 'package:afandim/view/restaurant_details/restaurant_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../custom_rating_bar.dart';
import '../loading_widget.dart';

class SpecialOffers extends StatefulWidget {
  @override
  _SpecialOffersState createState() => _SpecialOffersState();
}

class _SpecialOffersState extends State<SpecialOffers> {
  final _repository = Repository();
  bool isLoading = true;
  List<SearchMerchantList> list = [];
  SearchMerchantDart searchMerchantDart;

  int paginateTotal = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  init() async {
    setState(() {
      isLoading = true;
      list = [];
    });
    bool forceRefresh = await PrefManager().get("forceRefresh", false);
    Map<String, dynamic> response = await _repository.searchMerchant({
      "with_distance": "10",
      "sort_by": "distance",
      "search_type": "special_Offers"
    });
    if (forceRefresh) {
      await PrefManager().set("forceRefresh", false);
    }
    isLoading = false;
    if (response.containsKey("success") && response["success"]) {
      searchMerchantDart = SearchMerchantDart.fromJson(response);

      list = searchMerchantDart.details.searchMerchantList;
      paginateTotal = searchMerchantDart.details.paginateTotal;
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
    return Container(
      child: list.isEmpty && !isLoading
          ? Container()
          : Column(
              children: <Widget>[
                HomeHeader(
                  title: lang.api("Special offers"),
                  subTitle: lang.api("Enjoy it before it's over"),
                  showViewAll: list.length != 0,
                  onViewAllTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return ServicesList(
                          title: lang.api("Special offers"),
                          list: list,
                          paginateTotal: paginateTotal,
                          searchType: "special_Offers",
                        );
                      }),
                    );
                  },
                ),
                getListView(),
              ],
            ),
    );
  }

  Widget getListView() {
    if (isLoading) {
      return LoadingWidget();
    } else {
      if (list.length == 0) {
        return Container();
      } else {
        return listView();
      }
    }
  }

  Widget listView() {
    return Container(
      height: 268,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          SearchMerchantList item = list[index];
          return Container(
            width: MediaQuery.of(context).size.width - 100,
            child: Card(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return MerchantDetailsView(
                        searchMerchantList: item,
                        merchantId: item.merchantId,
                      );
                    }),
                  );
                },
                child: Container(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: item.backgroundUrl,
                                width: MediaQuery.of(context).size.width,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                              item.openStatusRaw == "close"
                                  ? Container(
                                      color: Color(0x809E9E9E),
                                      height: 120,
                                      child: Center(
                                        child: Container(
                                          color: Colors.black45,
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            lang.api("Closed"),
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                          Positioned(
                            right: lang.isRtl() ? null : 0.0,
                            left: lang.isRtl() ? 0.0 : null,
                            child: item.openStatusRaw == "open"
                                ? Container(
                                    margin: EdgeInsets.all(8),
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  )
                                : Container(
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: Colors.red,
                                    ),
                                    width: 12,
                                    height: 12,
                                  ),
                          ),
                          item.openStatusRaw == "open" ||
                                  item.openStatusRaw == "close"
                              ? Container()
                              : Positioned(
                                  right: lang.isRtl() ? 0.0 : null,
                                  left: lang.isRtl() ? null : 0.0,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    child: Text(
                                      lang.api(item.openStatus),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 2.0),
                        child: Text(
                          item.restaurantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).primaryColor,
                                ),
                                Text(
                                  "${customRound(double.parse(item.distance), 1)} ${lang.api("KM")}",
                                ),
                              ],
                            ),
                            CustomRatingBar(
                              onChanged: (value) {},
                              numStars: 5,
                              isInt: false,
                              rating: double.parse("${item.rating.ratings}"),
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 2.0),
                        child: Text(
                          item.cuisine,
                          maxLines: 1,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 2.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Wrap(
                                children: [
                                  (item.deliveryEstimation ?? "").isEmpty ||
                                          [
                                            "Not Available",
                                            "غير متوفر",
                                            "Müsait değil",
                                            lang.api("not available")
                                          ].contains(item.deliveryEstimation)
                                      ? Container()
                                      : ServiceBadge(
                                          text:
                                              lang.api(item.deliveryEstimation),
                                          icon: Icon(
                                            Icons.access_time,
                                            size: 16,
                                          )),
                                  (item.deliveryFee ?? "").isEmpty
                                      ? ServiceBadge(
                                          icon: Icon(
                                            Icons.directions_car,
                                            size: 16,
                                          ),
                                          text: lang.api("Free Delivery"),
                                        )
                                      : ServiceBadge(
//                              ServiceBadge(
                                          icon: Icon(
                                            Icons.directions_car,
                                            size: 16,
                                          ), //
                                          text: lang.api(item.deliveryFee),
                                        ),
                                ]..addAll(getOffers(item)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> getOffers(SearchMerchantList item) {
    List<Widget> temp = [];
    item.offers.forEach((element) {
      temp.add(ServiceBadge(text: lang.api(element["raw"])));
    });
    return temp;
  }
}

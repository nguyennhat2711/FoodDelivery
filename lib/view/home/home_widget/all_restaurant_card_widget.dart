import 'package:afandim/custom_widget/custom_rating_bar.dart';
import 'package:afandim/custom_widget/merchant/service_badge.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/utils.dart';
import 'package:afandim/model/search_merchant.dart';
import 'package:afandim/view/restaurant_details/restaurant_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../helper/global_translations.dart';

class MerchantCard extends StatelessWidget {
  final SearchMerchantList item;

  final bool showOffers;
  const MerchantCard({Key key, @required this.item, this.showOffers = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item.restaurantName == "Hungry ") {}

    return Card(
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
          padding: EdgeInsets.all(11),
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Align(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: item.backgroundUrl,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          height: 125,
                          placeholder: (context, text) {
                            return Image(
                              image:
                                  AssetImage("assets/images/background-2.jpg"),
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                              height: 125,
                            );
                          },
                        ),
                        Container(
                          height: 125,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black54,
                                Colors.transparent,
                              ],
                              stops: [0.05, 0.7],
                            ),
                          ),
                        ),
                        item.openStatusRaw == "close"
                            ? Container(
                                color: Colors.black45, //Color(0xAA9E9E9E),
                                height: 125,
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      lang.api("Closed"),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
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
                        item.offers is List && item.offers.length > 0
                            ? Positioned(
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
                                    lang.api(item.offers[0]["raw"]),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              )
                            : Container(),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.white38,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Theme.of(context).primaryColor,
                                        size: 16,
                                      ),
                                      Text(
                                        "${customRound(double.parse("${item.distance}"), 1)} ${lang.api("KM")}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${item.rating.votes}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    CustomRatingBar(
                                      onChanged: (value) {},
                                      numStars: 1,
                                      rating: double.parse(
                                          "${item.rating.ratings}"),
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: item.logo,
                          placeholder: (context, text) {
                            return Image(
                              image: AssetImage(
                                  "assets/images/logo-placeholder.png"),
                              width: 46,
                              height: 46,
                            );
                          },
                          width: 46,
                          height: 46,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.api(item.restaurantName),
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                lang.api(item.cuisine),
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    !showOffers
                        ? Container()
                        : SingleChildScrollView(
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
                                            text: lang
                                                .api(item.deliveryEstimation),
                                            icon: Icon(Icons.access_time,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                    (item.deliveryFee ?? "").isEmpty
                                        ? ServiceBadge(
                                            icon: Icon(Icons.directions_car,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            text: lang.api("Free Delivery"),
                                          )
                                        : ServiceBadge(
                                            icon: Icon(Icons.directions_car,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .primaryColor), //
                                            text: lang.api(item.deliveryFee),
                                          ),
                                  ]..addAll(getOffers()),
                                ),
                              ],
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

  List<Widget> getOffers() {
    List<Widget> temp = [];
    item.offers.forEach((element) {
      temp.add(ServiceBadge(text: lang.api(element["raw"])));
    });
    return temp;
  }
}

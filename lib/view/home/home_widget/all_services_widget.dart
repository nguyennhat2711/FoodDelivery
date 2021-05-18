import 'package:afandim/core/utils/dimens.dart';
import 'package:afandim/custom_widget/merchant/service_badge.dart';
import 'package:afandim/helper/constance.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/utils.dart';
import 'package:afandim/model/search_merchant.dart';
import 'package:afandim/view/home/home_widget/home_header_widget.dart';
import 'package:afandim/view/home/home_widget/services_list.dart';
import 'package:afandim/view/restaurant_details/restaurant_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/home_viewmodel.dart';
import '../../../custom_widget/loading_widget.dart';

class AllServicesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, watch, Widget child) {
        final viewModel = watch(homeViewModel);
        return Container(
          child: viewModel.listAllMerchant.isEmpty &&
                  !viewModel.isLoadingGetAllMerchant
              ? Container()
              : Column(
                  children: <Widget>[
                    HomeHeader(
                      title: lang.api("All Restaurants"),
                      subTitle: lang.api("Choose what you wish"),
                      showViewAll: viewModel.listAllMerchant.length != 0,
                      onViewAllTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return ServicesList(
                              title: lang.api("All Restaurants"),
                              list: viewModel.listAllMerchant,
                              paginateTotal: viewModel.paginateTotalAllMerchant,
                              searchType: "allMerchant",
                            );
                          }),
                        );
                      },
                    ),
                    viewModel.isLoadingGetAllMerchant
                        ? LoadingWidget()
                        : viewModel.listAllMerchant.length == 0
                            ? Container()
                            : Container(
                                child: Column(
                                  children: <Widget>[
                                    ListView.builder(
                                      primary: false,
                                      shrinkWrap: true,
                                      itemCount:
                                          viewModel.listAllMerchant.length,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 8),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        SearchMerchantList item =
                                            viewModel.listAllMerchant[index];
                                        return MerchantCard2(
                                          item: item,
                                          showOffers: true,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                  ],
                ),
        );
      },
    );
  }
}

class MerchantCard2 extends StatelessWidget {
  final SearchMerchantList item;
  final bool showOffers;

  const MerchantCard2({Key key, @required this.item, this.showOffers = true})
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
          padding: EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: CachedNetworkImage(
                      imageUrl: item.logo,
                      width: 70,
                      fit: BoxFit.cover,
                      height: 70,
                      placeholder: (context, text) {
                        return Image(
                          image:
                              AssetImage("assets/images/background-2.jpg"),
                          width: 70,
                          fit: BoxFit.cover,
                          height: 70,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: offsetXSm,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Text(
                          "${item.rating.votes}",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.star_rate_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      )
                    ],
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: offsetBase),
                width: 1, height: 70,
                color: Colors.grey,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lang.api(item.restaurantName),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        item.isSponsored == "1"
                            ? Container(
                              padding: EdgeInsets.symmetric(horizontal: offsetSm, vertical: offsetSm),
                              decoration: BoxDecoration(
                                color: thirdColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(offsetSm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    lang.api("Promoted"),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : SizedBox(),
                      ],
                    ),
                    Text(
                      lang.api(item.cuisine),
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${customRound(double.parse("${item.distance}"), 1)} ${lang.api("KM")}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black45,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
//                         if (!showOffers) Expanded(
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: Row(
//                               children: [
//                                 Wrap(
//                                   children: [
//                                     (item.deliveryEstimation ?? "").isEmpty ||
//                                         [
//                                           "Not Available",
//                                           "غير متوفر",
//                                           "Müsait değil",
//                                           lang.api("not available")
//                                         ].contains(item.deliveryEstimation)
//                                         ? Container()
//                                         : ServiceBadge(
//                                         text: lang
//                                             .api(item.deliveryEstimation),
//                                         icon: Icon(Icons.access_time,
//                                             size: 16,
//                                             color: Theme.of(context)
//                                                 .primaryColor)),
//                                     (item.deliveryFee ?? "").isEmpty
//                                         ? ServiceBadge(
//                                       icon: Icon(Icons.directions_car,
//                                           size: 16,
//                                           color: Theme.of(context)
//                                               .primaryColor),
//                                       text: lang.api("Free Delivery"),
//                                     )
//                                         : ServiceBadge(
// //                              ServiceBadge(
//                                       icon: Icon(Icons.directions_car,
//                                           size: 16,
//                                           color: Theme.of(context)
//                                               .primaryColor), //
//                                       text: lang.api(item.deliveryFee),
//                                     ),
//                                   ]..addAll(getOffers()),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
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

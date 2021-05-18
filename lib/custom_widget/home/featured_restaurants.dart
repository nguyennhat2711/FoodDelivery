import 'package:afandim/core/services/repository.dart';
import 'package:afandim/core/services/string_services.dart';
import 'package:afandim/core/utils/dimens.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/model/search_merchant.dart';
import 'package:afandim/view/restaurant_details/restaurant_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Convert It to riverpod
class HomeController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxDouble scrollPosition = 0.0.obs;
}

class FeaturedRestaurants extends StatefulWidget {
  @override
  _FeaturedRestaurantsState createState() => _FeaturedRestaurantsState();
}

class _FeaturedRestaurantsState extends State<FeaturedRestaurants> {
  final _repository = Repository();
  bool isLoading = true;
  List<SearchMerchantList> list = [];
  SearchMerchantDart searchMerchantDart;
  int paginateTotal = 1;
  int currentIndex = 0;
  HomeController homeController = Get.put(HomeController());
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
      "with_distance": "1",
      "sort_by": "distance",
      "search_type": "featuredMerchant"
    });
    isLoading = false;
    if (forceRefresh) {
      await PrefManager().set("forceRefresh", false);
    }
    if (response.containsKey("success") && response["success"]) {
      searchMerchantDart = SearchMerchantDart.fromJson(response);
      list = searchMerchantDart.details.searchMerchantList;
      paginateTotal = int.parse("${searchMerchantDart.details.paginateTotal}");
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
                getListView(),
              ],
            ),
    );
  }

  Widget getListView() {
    if (isLoading) {
      return LoadingWidget();
      // return SpinKitThreeBounce(
      //   size: 42.0,
      //   color: Theme.of(context).primaryColor,
      // );
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
      margin: EdgeInsets.symmetric(vertical: offsetBase),
      height: 285.0,
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: offsetBase),
            child: Text(
              lang.api("Featured"),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              shrinkWrap: false,
              itemBuilder: (context, itemIndex) {
                SearchMerchantList item = list[itemIndex];
                return getItem(item);
              },
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }

  Widget getItem(SearchMerchantList item) {
    var cellWidth = 300.0;
    var cellLogoSize = 48.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: offsetSm, vertical: offsetXSm),
      width: cellWidth,
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
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(offsetSm),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(offsetSm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(offsetSm),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.backgroundUrl,
                        fit: BoxFit.fill,
                        height: 150,
                        width: double.infinity,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: EdgeInsets.only(top: offsetSm, right: offsetSm),
                          padding: EdgeInsets.symmetric(vertical: offsetXSm),
                          width: cellLogoSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(offsetXSm)),
                          ),
                          child: Row(
                            children: [
                              Spacer(),
                              Icon(Icons.star, color: Theme.of(context).primaryColor, size: 18,),
                              SizedBox(width: offsetXSm,),
                              Text(
                                "${item.rating.votes}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: offsetSm, left: offsetSm),
                        width: cellLogoSize, height: cellLogoSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(offsetSm)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(offsetSm),
                          child: CachedNetworkImage(
                            imageUrl: item.logo,
                            fit: BoxFit.cover,
                            width: cellLogoSize,
                            height: cellLogoSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(offsetBase),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.api(item.restaurantName),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          lang.api(item.cuisine),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            lang.api(item.deliveryEstimation),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ),
                          if (item.deliveryFee != null && item.deliveryFee.isNotEmpty) Text(
                            ' | ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ),
                          if (item.deliveryFee != null && item.deliveryFee.isNotEmpty) Text(
                            item.deliveryFee,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

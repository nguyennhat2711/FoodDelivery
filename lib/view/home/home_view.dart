import 'package:afandim/core/viewmodel/home_viewmodel.dart';
import 'package:afandim/custom_widget/home/favorites.dart';
import 'package:afandim/custom_widget/home/featured_restaurants.dart';
import 'package:afandim/custom_widget/home/special_offers.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/constance.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/model/banner_model.dart';
import 'package:afandim/view/home/home_widget/all_services_widget.dart';
import 'package:afandim/view/home/home_widget/categories_widget.dart';
import 'package:afandim/view/home/home_widget/home_banner_widget.dart';
import 'package:afandim/view/home/home_widget/home_near_by_widget.dart';
import 'package:afandim/view/home/home_widget/search_box_widget.dart';
import 'package:afandim/view/merchant/merchant_maps.dart';
import 'package:afandim/view/specific_merchant/specific_merchant_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read(homeViewModel).refreshAllPage();
          await Future.delayed(Duration(seconds: 2));
          return;
        },
        child: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: [
            /// -------------------App Bar Widget------------------
            getCustomSliverAppBar(),

            /// -------------------Banner------------------
            hide("mobile2_home_banner")
                ? SliverToBoxAdapter(child: Container())
                : Consumer(
                    builder: (BuildContext context, watch, Widget child) {
                      final viewModel = watch(homeViewModel);
                      return SliverToBoxAdapter(
                        child: viewModel.isLoadingBanner
                            ? LoadingWidget()
                            : HomeBannerWidget(
                                homeBannerModelList: viewModel.homeBannerModel,
                                onTap: (HomeBannerModel homeBannerModel) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return SpecificMerchantView(
                                        title: lang.api("Offers"),
                                        searchType: "ByTag",
                                        extraFields: {
                                          "banner_id": homeBannerModel.bannerId
                                        },
                                        homeBannerModel: homeBannerModel,
                                      );
                                    }),
                                  );
                                },
                              ),
                      );
                    },
                  ),

            /// -----------------Categories--------------------
            hide("mobile2_home_cuisine")
                ? SliverToBoxAdapter(child: Container())
                : SliverToBoxAdapter(child: CategoriesWidget()),

            /// -----------------Near By --------------------
            SliverToBoxAdapter(
              child: HomeNearByWidget(),
            ),

            /// -----------------Favorite Restaurant --------------------
            hide("mobile2_home_favorite_restaurant")
                ? SliverToBoxAdapter(child: Container())
                : SliverToBoxAdapter(
                    child: Consumer(
                      builder: (BuildContext context,
                          T Function<T>(ProviderBase<Object, T>) watch,
                          Widget child) {
                        final viewModel = watch(homeViewModel);

                        return !viewModel.isLogin ? Favorites() : Container();
                      },
                    ),
                  ),

            /// -----------------Home Offers--------------------
            hide("mobile2_home_offer")
                ? SliverToBoxAdapter(child: Container())
                : SliverToBoxAdapter(child: SpecialOffers()),

            hide("mobile2_home_featured")
                ? SliverToBoxAdapter(child: Container())
                : SliverToBoxAdapter(child: FeaturedRestaurants()),

            /// Get ALL Merchant
            hide("mobile2_home_all_restaurant")
                ? SliverToBoxAdapter(child: Container())
                : SliverToBoxAdapter(
                    child: AllServicesWidget(),
                  ),
          ],
        ),
      ),
      floatingActionButton: Consumer(
        builder: (BuildContext context, watch, Widget child) {
          final viewModel = watch(homeViewModel);
          return FloatingActionButton(
            onPressed: () => Get.to(
              MerchantMaps(list: viewModel.allMerchants),
            ),
            backgroundColor: Colors.white,
            child: Icon(
              Icons.map,
              color: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget getCustomSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: true,
      pinned: true,
      stretch: true,
      elevation: 0.0,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            color: Colors.grey[50],
            padding: EdgeInsets.only(bottom: 32),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  color: primaryColor,
                ),
                Positioned(
                  bottom: -20,
                  left: 16,
                  right: 16,
                  child: getSearchBox(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getSearchBox() {
    return Consumer(builder: (BuildContext context, watch, Widget child) {
      final viewModel = watch(homeViewModel);
      return SearchBox(
        normalText: "${lang.api("Delivery to")} ",
        title: viewModel.location["address"] ?? "",
        icon: Icon(
          Icons.location_on,
          color: Theme.of(context).primaryColor,
        ),
        onSearchClicked: () => viewModel.openAddressPicker(context),
      );
    });
  }

  bool hide(String key) {
    return lang.settings["home"][key] != "1";
  }
}

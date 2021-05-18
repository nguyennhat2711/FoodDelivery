import 'dart:convert';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/helper/consts.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/location_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/helper/utils.dart';
import 'package:afandim/model/banner_model.dart';
import 'package:afandim/model/category_model.dart';
import 'package:afandim/model/search_merchant.dart';
import 'package:afandim/view/control_view.dart';
import 'package:afandim/view/home/home_widget/home_location_selector.dart';
import 'package:afandim/view/home/home_widget/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

final homeViewModel = ChangeNotifierProvider<HomeViewModel>((ref) {
  final general = ref.watch(generalProvider);
  return HomeViewModel(general);
});

class HomeViewModel extends ChangeNotifier {
  /// Loading
  bool isLoadingCategory = true,
      isLoadingBanner = true,
      isLoadingNearBy = true,
      isLoadingGetAllMerchant = true;

  List<HomeBannerModel> homeBannerModel;
  GeneralProvider general;
  final _prefManager = PrefManager();
  final _repository = Repository();
  Map settings = {};
  Map location = {};
  String userName = "";
  List<SearchMerchantList> allMerchants = [];
  bool isLogin = false;

  List<SearchMerchantList> listNearBy = [];
  List<SearchMerchantList> listAllMerchant = [];
  String titleNearBy = "";
  int paginateTotalNearBy = 1;

  /// Category
  List<CategoryModelList> listCategory = [];
  CategoryModel categoryModel;

  /// All Merchant
  SearchMerchantDart searchMerchantDartNearBy;
  SearchMerchantDart searchMerchantDartAllMerchant;
  int paginateTotalAllMerchant = 1;

  HomeViewModel(GeneralProvider general) {
    this.general = general;
    saveLocation();
    getBannerHome();
    getCategoryHome();
    getNearByHome();
    getAllMerchant();
  }

  /// User Location
  saveLocation() async {
    await _prefManager.set("view_location_dialog", true);
    isLogin = await _prefManager.contains("token");
    if (await _prefManager.contains("location")) {
      location = json.decode(await _prefManager.get("location", "{}"));
      Map userData = json.decode(await _prefManager.get("user.data", "{}"));
      if (userData.isNotEmpty) {
        userName = userData["first_name"] ?? "";
      }

      notifyListeners();
    } else {
      Position locationData = await getCurrentLocation();
      if (locationData == null) {
        openLocationScreen();
      } else {
        location = {
          "lat": locationData.latitude,
          "lng": locationData.longitude,
          "address": "",
        };
        _prefManager.set("location", json.encode(location));
      }
    }
    notifyListeners();
  }

  /// Banner
  getBannerHome() async {
    isLoadingBanner = true;
    notifyListeners();
    if (lang.settings["home_banner"].length > 0) {
      print(lang.settingsModel.details.settings.homeBanner);
      homeBannerModel = lang.settingsModel.details.settings.homeBanner;
      isLoadingBanner = false;
      notifyListeners();
    }
  }

  getCategoryHome() async {
    isLoadingCategory = true;
    listCategory = [];
    Map<String, dynamic> response = await _repository.cuisineList();
    isLoadingCategory = false;
    notifyListeners();
    if (response.containsKey("success") && response["success"]) {
      categoryModel = CategoryModel.fromJson(response);
      listCategory = categoryModel.details.list;
    }
  }

  getNearByHome() async {
    titleNearBy = lang.api("loading");
    isLoadingNearBy = true;
    listNearBy = [];

    Map<String, dynamic> response = await _repository.searchMerchant({
      "with_distance": "1",
      "sort_by": "distance",
      "search_type": "byLatLong"
    });

    searchMerchantDartNearBy = SearchMerchantDart.fromJson(response);
    isLoadingNearBy = false;
    notifyListeners();
    if (response.containsKey("code") && response["code"] == 1) {
      titleNearBy = searchMerchantDartNearBy.msg;
      listNearBy = searchMerchantDartNearBy.details.searchMerchantList;
      paginateTotalNearBy = searchMerchantDartNearBy.details.paginateTotal;
    } else {
      titleNearBy = lang.api("0 Services");
    }
    if (listNearBy.length == 0 &&
        await PrefManager().contains("location") &&
        await PrefManager().get("view_location_dialog", true)) {
      await PrefManager().set("view_location_dialog", false);
      bool setLocation = await showCustomErrorDialog(
        lang.api("No service found"),
        lang.api(
            "Unfortunately; There are no services close to your location. Be sure to specify your location"),
        lang.api("Set Location"),
      );

      if (setLocation && openLocationScreen != null) {
        openLocationScreen();
      }
    }
  }

  /// Get All Merchant
  getAllMerchant() async {
    isLoadingGetAllMerchant = true;
    notifyListeners();
    // bool forceRefresh = await PrefManager().get("forceRefresh", false);
    Map<String, dynamic> response = await _repository.searchMerchant({
      "with_distance": "1",
      "sort_by": "distance",
      "search_type": "allMerchant"
    }
        // , forceRefresh
        );
    isLoadingGetAllMerchant = false;
    // if (forceRefresh) {
    //   await PrefManager().set("forceRefresh", false);
    // }
    if (response.containsKey("success") && response["success"]) {
      searchMerchantDartAllMerchant = SearchMerchantDart.fromJson(response);
      paginateTotalAllMerchant =
          int.parse("${searchMerchantDartAllMerchant.details.paginateTotal}");
      listAllMerchant =
          searchMerchantDartAllMerchant.details.searchMerchantList;
      isLoadingGetAllMerchant = false;
    }

    notifyListeners();
  }

  refreshAllPage() async {
    print("refreshAllPage here error ");
    // await _prefManager.set("forceRefresh", true);
  }

  openLocationScreen() async {
    print("openLocationScreen here error ");
    var result = await Get.to(HomeLocationSelector(locationData: location));

    if (result is bool && result) {
      await Get.off(ControlView(
        selectedIndex: 0,
      ));
    } else {
      if (!await _prefManager.contains("location")) {
        openLocationScreen();
      }
    }
  }

  openAddressPicker(context) async {
    if (general.addressList == null || general.addressList.isEmpty) {
      openLocationScreen();
    } else {
      var result = await showModalBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            // height: MediaQuery.of(context).size.height / 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        lang.api("Select location"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Consumer(
                      builder: (BuildContext context, watch, Widget child) {
                        final viewmodel = watch(generalProvider);
                        return ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: viewmodel.addressList.length,
                          itemBuilder: (context, index) {
                            var item = viewmodel.addressList[index];
                            var icon = Icons.home_outlined;
                            // print("item: $item");
                            for (int i = 0; i < staticLocations.length; i++) {
                              if (item["location_name"] ==
                                  staticLocations[i]["name"]) {
                                icon = staticLocations[i]["icon"];
                                break;
                              }
                            }
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop(item);
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Icon(icon, size: 32),
                                        padding: EdgeInsets.all(8),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["location_name"],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              item["address"],
                                              style: TextStyle(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    AlternativeButton(
                      label: lang.api("Add new location"),
                      onPressed: () {
                        openLocationScreen();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
      if (result != null) {
        showLoadingDialog();
        Map<String, dynamic> response =
            await _repository.getAddressBookById(result["id"]);
        Get.back();
        if (response.containsKey("code") && response["code"] == 1) {
          var data = response["details"]["data"];

          location = {
            "lat": double.parse("${data["latitude"]}"),
            "lng": double.parse("${data["longitude"]}"),
            "address": result["location_name"],
          };
          _prefManager.set("location", json.encode(location));
          refreshAllPage();
        } else {
          showToast(lang.text("Fail to get address details"));
        }
      }
    }
  }

  onSearchClicked() {
    print("onSearchClicked here error ");
    Get.to(SearchPage(
      title: lang.api("Search for restaurant, cuisine or food"),
      searchType: SearchType.MerchantFood,
    ));
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}

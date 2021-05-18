import 'package:afandim/core/services/api_services.dart';
import 'package:afandim/core/services/http_provider.dart';
import 'package:afandim/helper/config.dart';

import 'maps_provider.dart';

class Repository {
  final apiProvider = ApiServices();
  final provider = HttpProvider();
  final mapsProvider = MapsProvider();

  void close() {
    apiProvider.close();
    provider.close();
    mapsProvider.close();
  }

  Future<Map<String, dynamic>> callUrl(String url) => provider.callUrl(url);

  Future<Map<String, dynamic>> postUrl(
          String url, Map<String, dynamic> request) =>
      provider.postUrl(url, request);

  Future<List<int>> getBytes(String url) => provider.getBytes(url);

  Future<Map<String, dynamic>> geocode(String location) =>
      mapsProvider.geocode(location);

  Future<Map<String, dynamic>> getPlaces(String query) =>
      mapsProvider.getPlaces(query);

  Future<Map<String, dynamic>> getRoute(String pickup, String dropoff) =>
      mapsProvider.getRoute(pickup, dropoff);

  /// Get Settings From Api
  Future<Map<String, dynamic>> getSettings() {
    return apiProvider.getRequest("getSettings");
  }

  Future<Map<String, dynamic>> registerUsingFb(Map<String, dynamic> request) =>
      apiProvider.getRequest("registerUsingFb", request);

  Future<Map<String, dynamic>> googleLogin(Map<String, dynamic> request) =>
      apiProvider.getRequest("googleLogin", request);

  Future<Map<String, dynamic>> getNotifications() =>
      apiProvider.getRequest("GetNotifications", {});

  Future<Map<String, dynamic>> getHomeBanner({Map<String, dynamic> request}) =>
      apiProvider.getRequest("getHomebanner", request);

  Future<Map<String, dynamic>> cuisineList({Map<String, dynamic> request}) =>
      apiProvider.getRequest("cuisineList", request);

  Future<Map<String, dynamic>> customerLogin(String login, String password) =>
      apiProvider.customerLogin(login, password);

  Future<Map<String, dynamic>> searchMerchant(Map<String, dynamic> params) =>
      apiProvider.searchMerchant(params);

  Future<Map<String, dynamic>> getPointDetails(
    String pointType,
  ) =>
      apiProvider.getPointDetails(pointType);

  Future<Map<String, dynamic>> getCreditCartInfo(String ccId) =>
      apiProvider.getCreditCartInfo(ccId);

  Future<Map<String, dynamic>> getAddressBookById(String id) =>
      apiProvider.getAddressBookById(id);

  Future<Map<String, dynamic>> viewOrder(String orderId) =>
      apiProvider.viewOrder(orderId);

  Future<Map<String, dynamic>> getMerchantAbout(String merchantId) =>
      apiProvider.getMerchantData("GetMerchantAbout", merchantId);

  Future<Map<String, dynamic>> getGallery(String merchantId) =>
      apiProvider.getMerchantData("GetGallery", merchantId);

  Future<Map<String, dynamic>> getMerchantInformation(String merchantId) =>
      apiProvider.getMerchantData("GetMerchantInformation", merchantId);

  Future<Map<String, dynamic>> getMerchantPromo(String merchantId) =>
      apiProvider.getMerchantData("GetMerchantPromo", merchantId);

  Future<Map<String, dynamic>> getReviewList(String merchantId) =>
      apiProvider.getMerchantData("ReviewList", merchantId);

  Future<Map<String, dynamic>> getMerchantMenu(String merchantId) =>
      apiProvider.getMerchantData(
        "getMerchantMenu",
        merchantId,
      );

  Future<Map<String, dynamic>> getRestaurantInfo(String merchantId) =>
      apiProvider.getMerchantData(
        "getRestaurantInfo",
        merchantId,
      );

  Future<Map<String, dynamic>> getActiveMerchantCategory(String merchantId) =>
      apiProvider.getMerchantData("getActiveMerchantCategory", merchantId);

  Future<Map<String, dynamic>> addFavorite(String merchantId) =>
      apiProvider.getMerchantData("AddFavorite", merchantId);

  Future<Map<String, dynamic>> itemDetails(
          String merchantId, String itemId, String catId, String row,
          [bool = false]) =>
      apiProvider.itemDetails(
        merchantId,
        itemId,
        catId,
        row,
      );

  Future<Map<String, dynamic>> searchByMerchantName(String name) =>
      apiProvider.searchByMerchantName(name);

  Future<Map<String, dynamic>> addToCart(Map<String, dynamic> request) =>
      apiProvider.addToCart(request);

  Future<Map<String, dynamic>> getCartCount() => apiProvider.getCartCount();

  Future<Map<String, dynamic>> getOrderList(Map<String, dynamic> request,
          [bool]) =>
      apiProvider.getRequest("OrderList", request);

  Future<Map<String, dynamic>> reRegisterDevice(String deviceId) =>
      apiProvider.getRequest("reRegisterDevice", {
        "new_device_id": deviceId,
      });

  Future<Map<String, dynamic>> markAllNotifications() =>
      apiProvider.getRequest("markAllNotifications");

  Future<Map<String, dynamic>> readNotification(String id) =>
      apiProvider.getRequest("ReadNotification", {
        "id": id,
      });

  Future<Map<String, dynamic>> getBookingList() =>
      apiProvider.getRequest("BookingList", {});

  Future<Map<String, dynamic>> getFavoriteList() =>
      apiProvider.getRequest("FavoriteList", {});

  Future<Map<String, dynamic>> getCreditCartList() =>
      apiProvider.getRequest("CrediCartList");

  Future<Map<String, dynamic>> getCountryList() =>
      apiProvider.getRequest("getCountryList");

  Future<Map<String, dynamic>> getProfile() =>
      apiProvider.getRequest("GetProfile", {});

  Future<Map<String, dynamic>> getPointSummary() =>
      apiProvider.getRequest("GetPointSummary");

  Future<Map<String, dynamic>> getAddressBookList() =>
      apiProvider.getRequest("AddressBookList", {});

  Future<Map<String, dynamic>> getRecentSearch() =>
      apiProvider.getRequest("GetRecentSearch", {});

  Future<Map<String, dynamic>> clearRecentSearches() =>
      apiProvider.getRequest("clearRecentSearches", {});

  Future<Map<String, dynamic>> loadCart(Map<String, dynamic> request) =>
      apiProvider.getRequest("loadCart", request);

  Future<Map<String, dynamic>> clearCart() =>
      apiProvider.getRequest("clearCart", {});

  Future<Map<String, dynamic>> removeCartItem(Map<String, dynamic> request) =>
      apiProvider.getRequest("removeCartItem", request);

  Future<Map<String, dynamic>> applyVoucher(Map<String, dynamic> request) =>
      apiProvider.getRequest("applyVoucher", request);

  Future<Map<String, dynamic>> getAddressBookDropDown() =>
      apiProvider.getRequest("getAddressBookDropDown", {});

  Future<Map<String, dynamic>> deliveryTimeList() =>
      apiProvider.getRequest("deliveryTimeList");

  Future<Map<String, dynamic>> deliveryDateList() =>
      apiProvider.getRequest("deliveryDateList");

  Future<Map<String, dynamic>> servicesList() =>
      apiProvider.getRequest("servicesList");

  Future<Map<String, dynamic>> loadPaymentList(Map<String, dynamic> request) =>
      apiProvider.getRequest("loadPaymentList", request);

  Future<Map<String, dynamic>> setAddressBook(Map<String, dynamic> request) =>
      apiProvider.getRequest("setAddressBook", request);

  Future<Map<String, dynamic>> preCheckout(Map<String, dynamic> request) =>
      apiProvider.getRequest("preCheckout", request);

  Future<Map<String, dynamic>> payNow(Map<String, dynamic> request) =>
      apiProvider.getRequest("payNow", request);

  Future<Map<String, dynamic>> addReview(Map<String, dynamic> request) =>
      apiProvider.addReview(request);

  Future<Map<String, dynamic>> checkRunTrackHistory(String orderId) =>
      apiProvider.getRequest("checkRunTrackHistory", {"order_id": orderId});

  Future<Map<String, dynamic>> getItemByCategory(
          String merchantId, String catId) =>
      apiProvider.getRequest(
          "getItemByCategory", {"merchant_id": merchantId, "cat_id": catId});

  Future<Map<String, dynamic>> getOrderHistory(String orderId) =>
      apiProvider.getRequest("getOrderHistory", {"order_id": orderId});

  Future<Map<String, dynamic>> taskInformation(String orderId) =>
      apiProvider.getRequest("TaskInformation", {"order_id": orderId});

  Future<Map<String, dynamic>> trackDriver(String orderId, String driverId) =>
      apiProvider.getRequest(
          "TrackDriver", {"track_order_id": orderId, "driver_id": driverId});

  Future<Map<String, dynamic>> driverInformation(String driverId) =>
      apiProvider.getRequest("DriverInformation", {"driver_id": driverId});

  Future<Map<String, dynamic>> reOrder(String orderId) =>
      apiProvider.getRequest("ReOrder", {"order_id": orderId});

  Future<Map<String, dynamic>> getPushSettings() =>
      apiProvider.getRequest("getPushSettings", {});

  Future<Map<String, dynamic>> savePushSettings(String enabledPush) =>
      apiProvider.getRequest("savePushSettings", {"enabled_push": enabledPush});

  Future<Map<String, dynamic>> searchMerchantFood(String searchString) =>
      apiProvider.searchMerchantFood(searchString);

  Future<Map<String, dynamic>> registerDelivery(Map<String, dynamic> request) =>
      apiProvider.registerDelivery(request);

  Future<Map<String, dynamic>> createAccount(Map<String, dynamic> request) =>
      apiProvider.createAccount(request);

  Future<Map<String, dynamic>> loginCustomerOld(Map<String, dynamic> request) =>
      apiProvider.customerLoginOld(request);

  Future<Map<String, dynamic>> changePassword(Map<String, dynamic> request) =>
      apiProvider.postRequest("ChangePassword", request);

  Future<Map<String, dynamic>> searchFoodCategory(
          String merchantId, String item) =>
      apiProvider.getRequest(
          "searchFoodCategory", {"merchant_id": merchantId, "item_name": item});

  Future<Map<String, dynamic>> retrievePassword(Map<String, dynamic> request) =>
      apiProvider.getRequest("retrievePassword", request);

  Future<Map<String, dynamic>> setLocation(Map<String, dynamic> request) =>
      apiProvider.postRequest("SetLocation", request);

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> request) =>
      apiProvider.postRequest("UpdateProfile", request, true, false, true);

  Future<Map<String, dynamic>> saveAddressBook(Map<String, dynamic> request) =>
      apiProvider.postRequest("saveAddressBook", request, true, false, true);

  Future<Map<String, dynamic>> setDeliveryAddress(
          Map<String, dynamic> request) =>
      apiProvider.getRequest("setDeliveryAddress", request);

  Future<Map<String, dynamic>> deleteAddressBook(String id) =>
      apiProvider.getRequest("DeleteAddressBook", {"id": id});

  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getServerSettings() =>
      provider.callUrl("$mainServerUrl/mobile-app-settings/getAPIList");

  Future<Map<String, dynamic>> getUpdateSettings(
          Map<String, dynamic> request) =>
      provider.postUrl(
          "$mainServerUrl/mobile-app-settings/getAppUpdate", request);
}

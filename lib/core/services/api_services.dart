import 'dart:convert';
import 'dart:io';

import 'package:afandim/helper/config.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:package_info/package_info.dart';

enum Method { POST, GET, PATCH, DELETE }

class ApiServices {
  final int keepOnCache = 1;
  Dio dio = Dio();
  CancelToken cancelToken = CancelToken();
  var _prefManager = PrefManager();

  ApiServices() {
    initDioOptions();
  }

  initDioOptions() async {
    dio.options.connectTimeout = 50000; //50s
    dio.options.receiveTimeout = 50000; //50s
//    dio.options.contentType = "application/json";
    dio.options.headers = {
//      "Content-Type": "application/json",
    };
  }

  void close() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel("Close");
    }
    dio.close();
  }

  Future<Map<String, dynamic>> customerLogin(
      String login, String password) async {
    return _doRequest("customerLogin", Method.GET,
        {"user_mobile": login, "password": password});
  }

  Future<Map<String, dynamic>> customerLoginOld(
      Map<String, dynamic> request) async {
    return _doRequest("customerLogin", Method.POST, request, true, false, true);
  }

  Future<Map<String, dynamic>> searchMerchant(
      Map<String, dynamic> params) async {
    return _doRequest("searchMerchant", Method.GET, params);
  }

  Future<Map<String, dynamic>> getRequest(
    String action, [
    Map<String, dynamic> request,
  ]) async {
    return _doRequest(action, Method.GET, request ?? {});
  }

  Future<Map<String, dynamic>> searchMerchantFood(String searchString) async {
    return _doRequest("searchMerchantFood", Method.GET,
        {"search_string": searchString}, true, false);
  }

  Future<Map<String, dynamic>> searchByMerchantName(String name) async {
    return _doRequest("searchByMerchantName", Method.GET,
        {"merchant_name": name}, true, false);
  }

  Future<Map<String, dynamic>> getMerchantData(String action, String merchantId,
      [bool forceRefresh = false]) async {
    return _doRequest(
        action, Method.GET, {"merchant_id": merchantId}, forceRefresh, false);
  }

  Future<Map<String, dynamic>> getPointDetails(String pointType,
      {bool forceRefresh = false}) async {
    return _doRequest(
        "GetPointDetails", Method.GET, {"point_type": pointType}, forceRefresh);
  }

  Future<Map<String, dynamic>> getCreditCartInfo(String ccId) async {
    return _doRequest("getCedittCardInfo", Method.GET, {"cc_id": ccId}, false);
  }

  Future<Map<String, dynamic>> getAddressBookById(String id) async {
    return _doRequest("getAddressBookByID", Method.GET, {"id": id}, true);
  }

  Future<Map<String, dynamic>> viewOrder(String orderId) async {
    return _doRequest("ViewOrder", Method.GET, {"order_id": orderId}, false);
  }

// New APIs
  Future<Map<String, dynamic>> addToCart(Map<String, dynamic> request) async {
    if (true) {
      // serverUrl == "https://efendim.biz"
      // Work here efendim server.
      return _doRequest("addToCart", Method.POST, request, true, true, true);
    } else {
      // Work here afandim server. // "https://afandim.net"
      return _doRequest("addToCart", Method.POST, request, true, true);
    }
  }

  Future<Map<String, dynamic>> addReview(Map<String, dynamic> request) async {
    return _doRequest("addReview", Method.POST, request, true, true, true);
  }

  Future<Map<String, dynamic>> registerDelivery(
      Map<String, dynamic> request) async {
    return _doRequest("DriverSignup", Method.POST, request, false);
  }

  Future<Map<String, dynamic>> createAccount(
      Map<String, dynamic> request) async {
    return _doRequest("createAccount", Method.POST, request, true, false, true);
  }

  Future<Map<String, dynamic>> postRequest(String action,
      [Map<String, dynamic> request,
      bool forceRefresh = false,
      bool addMerchantData = false,
      bool addToBody = false]) async {
    return _doRequest(action, Method.POST, request ?? {}, forceRefresh,
        addMerchantData, addToBody);
  }

  Future<Map<String, dynamic>> getCartCount() async {
    Map<String, dynamic> request = {
      "temp": 1,
    };
    String merchantId = await PrefManager().get("active_merchant", "0");
    if (merchantId != "0") {
      request["merchant_id"] = merchantId;
    }

    return _doRequest("getCartCount", Method.POST, request, true, false, false);
  }

  Future<Map<String, dynamic>> itemDetails(
      String merchantId, String itemId, String catId, String row,
      [bool forceRefresh = false]) async {
    Map<String, dynamic> request = {
      "merchant_id": merchantId,
      "item_id": itemId,
      "cat_id": catId
    };
    if (row != null) {
      request["row"] = row;
    }
    return _doRequest("itemDetails", Method.GET, request, forceRefresh);
  }

  /// TODO : PHONE
  // Future<Map<String, dynamic>> getMobileCodeList() async {
  //   return _doRequest("getMobileCodeList", Method.GET, {}, false);
  // }

  Future<Map<String, dynamic>> getBasicRequest(
      String action, bool addMerchantData) async {
    String notificationToken =
        await _prefManager.get("firebase_notification_token", "");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String deviceId;
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      deviceId = androidDeviceInfo.androidId; // unique ID on Android
    }

//    String apiKey = await _prefManager.get("api_key", "");
    Map<String, String> basicRequest = {
      "device_id": notificationToken,
      "device_uiid": deviceId,
      "device_platform": Platform.isAndroid ? "android" : "ios",
      "code_version": packageInfo.version,
      "lang": lang.getLanguageText(),
      "api_key": apiKey,
    };
    String token = await _prefManager.get("token", "");
    if (token.isNotEmpty) {
      basicRequest["user_token"] = token;
    }
    if (addMerchantData) {
      String merchantId = await _prefManager.get("active_merchant", "0");
      if (merchantId != "0") {
        basicRequest["merchant_id"] = merchantId;
      }
    }
    List<String> list = [
      "setDeliveryAddress",
      "SetLocation",
      "StateList",
      "CityList",
      "AreaList",
      "saveAddressBook",
      "saveAddressBookLocation",
      "setDeliveryLocation",
      "mapboxgeocode"
    ];
    if (!list.contains(action)) {
      Map settings = lang.settings;
      if (settings != null) {
        if (settings["search_mode"] == "address") {
          Map location = json.decode(await _prefManager.get("location", "{}"));
          basicRequest["lat"] = "${location["lat"] ?? ""}";
          basicRequest["lng"] = "${location["lng"] ?? ""}";
        } else {
          Map location =
              json.decode(await _prefManager.get("location_data", "{}"));
          if ("${settings["location_mode"]}" == "1") {
            basicRequest["city_id"] = location["city_id"] ?? "";
            basicRequest["area_id"] = location["area_id"] ?? "";
          } else if ("${settings["location_mode"]}" == "2") {
            basicRequest["state_id"] = location["state_id"] ?? "";
            basicRequest["city_id"] = location["city_id"] ?? "";
          } else if ("${settings["location_mode"]}" == "3") {
            basicRequest["city_id"] = location["city_id"] ?? "";
            basicRequest["postal_code"] = location["postal_code"] ?? "";
          }
        }
      }
    }

    return basicRequest;
  }

  Future<Map<String, dynamic>> _doRequest(
    String path,
    Method method, [
    Map<String, dynamic> request,
    bool forceRefresh,
    bool addMerchantData = true,
    bool addToBody = false,
  ]) async {
    /// Get Base Url  https://efendim.biz/mobileappv2/api/
    String apiUrl = await _prefManager.get("api_url", "");
    dio.options.baseUrl = apiUrl;

    /// add a dio-http-cache interceptor in Dio :
    /// this is only for cash dio or cash request
    /// DioCacheManager(CacheConfig(baseUrl: apiUrl)).interceptor

    dio.interceptors
        .add(DioCacheManager(CacheConfig(baseUrl: apiUrl)).interceptor);

    /// Check network connection
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return {
        "success": false,
        "code": -1,
        "msg": lang.api("No internet connectivity")
      };
    }

    Map<String, dynamic> basicRequest =
        await getBasicRequest(path, addMerchantData);
    if (addToBody) {
      request.addAll(basicRequest);
      basicRequest = {};
    }
    if (path.contains("setAddressBook")) {}
//    fullUrl
    Response response;
    try {
      /// POST
      if (method == Method.POST) {
        path = fullUrl(path, basicRequest);

        response = await dio.post(path,
            data: FormData.fromMap(request), cancelToken: cancelToken);
      }

      /// PATCH
      else if (method == Method.PATCH) {
        path = fullUrl(path, basicRequest);

        response =
            await dio.patch(path, data: request, cancelToken: cancelToken);
      }

      /// DELETE

      else if (method == Method.DELETE) {
        path = fullUrl(path, basicRequest);
        print("path: $path");
        response =
            await dio.delete(path, data: request, cancelToken: cancelToken);
      }

      /// GET
      else if (method == Method.GET) {
        request.addAll(basicRequest);
        path = fullUrl(path, request);
        print("path: $path");
        if (forceRefresh != null) {
          response = await dio.get(
            path,
            options: buildCacheOptions(Duration(hours: keepOnCache),
                maxStale: Duration(hours: keepOnCache),
                forceRefresh: forceRefresh),
          );
        } else {
          response = await dio.get(path, cancelToken: cancelToken);
        }
      }
      if (response != null) {
        // log("path : ${path.toString()}");
        // log("pesa.response.statusCode: ${response.statusCode}");
        // log("pesa.response.body: ${response.data}");
        if (response.statusCode == 200) {
          var responseData = response.data;
          Map data;
          if (responseData is String) {
            data = json.decode(responseData);
          } else {
            data = responseData;
          }
          var unescape = new HtmlUnescape();
          data = json.decode(unescape.convert(json.encode(data)));

          if (data.containsKey("code") && data["code"] == 1) {
            data["success"] = true;
          } else {
            data["success"] = false;
          }
          return data;
        } else {
          return {
            "success": false,
            "code": -1,
            "error_code": response.statusCode, // 500
            "msg": response.statusCode == 500
                ? lang.api("Server error, every thing will get back soon.")
                : lang.api("No internet connectivity")
          };
        }
      }
    } on Exception catch (e) {
      print("Exception: $e");
      if (e is DioError) {
        // log("e.response.data: ${e.response.data}");
        if (e.response != null && e.response.statusCode == 500) {
          return {
            "success": false,
            "code": -1,
            "error_code": -1,
            "msg": lang.api("Server error, every thing will get back soon.")
          };
        }
      }
    }
    return {
      "success": false,
      "code": -1,
      "error_code": -1,
      "msg": lang.api("No internet connectivity")
    };
  }

  String fullUrl(String url, Map<String, dynamic> request) {
    url += "?";
    request.keys.toList().forEach((String key) {
      if (request[key] is List) {
        List value = request[key];
        value.forEach((element) {
          url += "$key[]=${Uri.encodeComponent(element)}&";
        });
      } else {
        String value = Uri.encodeComponent("${request[key]}");
        url += "$key=$value&";
      }
    });
    return url;
  }
}

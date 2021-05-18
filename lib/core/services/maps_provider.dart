import 'dart:convert';

import 'package:afandim/helper/global_translations.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class MapsProvider {
  static String _baseUrl = "https://maps.googleapis.com/maps/api";
  final String baseUrl = "$_baseUrl";

  Dio dio = Dio();

  MapsProvider() {
    initDioOptions();
  }

  initDioOptions() async {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = 20000; //20s
    dio.options.receiveTimeout = 20000; //20s
    dio.options.contentType = "application/json";
    dio.interceptors
        .add(DioCacheManager(CacheConfig(baseUrl: baseUrl)).interceptor);
    dio.options.headers = {
      "Content-Type": "application/json",
    };
  }

  void close() {
    dio.close();
  }

  Future<Map<String, dynamic>> geocode(String location) async {
    return _doRequest(
        "/geocode/json",
        {
          "key": lang.settings["map_provider"]["token"],
          "latlng": location,
          "language": lang.currentLanguage,
          "sensor": true
        },
        false);
  }

  Future<Map<String, dynamic>> getPlaces(String query) async {
    return _doRequest(
        "/place/textsearch/json",
        {
          "key": lang.settings["map_provider"]["token"],
          "query": query,
          "language": lang.currentLanguage
        },
        false);
  }

  Future<Map<String, dynamic>> getRoute(String pickup, String dropoff) async {
    return _doRequest(
        "/directions/json",
        {
          "key": lang.settings["map_provider"]["token"],
          "destination": dropoff,
          "origin": pickup,
          "mode": "driving",
          "language": lang.currentLanguage,
        },
        false);
  }

  Future<Map<String, dynamic>> _doRequest(String path,
      [Map<String, dynamic> request, bool forceRefresh]) async {
    // print("path: $path");
    // print("request: ${request.toString()}");

    try {
      Response response;
      if (forceRefresh != null) {
        response = await dio.get(
          path,
          queryParameters: request,
          options: buildCacheOptions(Duration(days: 90),
              maxStale: Duration(days: 90), forceRefresh: forceRefresh),
        );
      } else {
        response = await dio.get(path, queryParameters: request);
      }
      if (response != null) {
        // print("response.statusCode: ${response.statusCode}");
        // print("response.body: ${response.data}");
        if (response.statusCode == 200) {
          var responseData = response.data;
          Map data;
          if (responseData is String) {
            data = json.decode(responseData);
          } else {
            data = responseData;
          }
          return data;
        } else {
          return {
            "success": false,
            "error_code": response.statusCode, // 500
            "message": "Server Error"
          };
        }
      }
    } on Exception catch (e) {
      print("Exception: $e");
    }
    return {
      "success": false,
      "error_code": -1001,
      "message": "No internet connectivity"
    };
  }
}

import 'dart:convert';

import 'package:afandim/core/services/api_services.dart';
import 'package:afandim/helper/config.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class HttpProvider {
  Dio dio = Dio();

  HttpProvider() {
    initDioOptions();
  }

  initDioOptions() async {
    dio.options.connectTimeout = 20000; //50s
    dio.options.receiveTimeout = 20000; //50s
    dio.options.contentType = "application/json";
    dio.options.headers = {
      "Content-Type": "application/json",
      "x-api-key": xApiKey
    };
  }

  void close() {
    dio.close();
  }

  Future<List<int>> getBytes(String url) async {
    try {
      Response<List<int>> rs = await dio.get<List<int>>(
        url,
        options: buildCacheOptions(
          Duration(days: 1),
          maxStale: Duration(days: 1),
          forceRefresh: false,
          options: Options(
              responseType: ResponseType.bytes), // set responseType to `bytes`
        ),
      );
      return rs.data;
    } on Exception catch (e) {
      print("Exception: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> callUrl(String url) async {
    return _doRequest(url, Method.GET, {}, false);
  }

  Future<Map<String, dynamic>> postUrl(
      String url, Map<String, dynamic> request) async {
    return _doRequest(url, Method.POST, request);
  }

  Future<Map<String, dynamic>> _doRequest(String path, Method method,
      [Map<String, dynamic> request, bool forceRefresh]) async {
    try {
//      print("request: $request");
//      print("path: $path");
      Response response;
      if (method == Method.POST) {
        response = await dio.post(path, data: FormData.fromMap(request));
      } else {
        if (forceRefresh != null) {
          response = await dio.get(
            path,
            queryParameters: request,
            options: buildCacheOptions(Duration(days: 1),
                maxStale: Duration(days: 1), forceRefresh: forceRefresh),
          );
        } else {
          response = await dio.get(path, queryParameters: request);
        }
      }
//      print("response: $response");

      if (response != null) {
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
            "code": 0,
            "error_code": response.statusCode, // 500
            "msg": lang.api("Server error")
          };
        }
      }
    } on Exception catch (e) {
      print("Exception: $e");
    }
    return {
      "success": false,
      "code": 0,
      "error_code": -1001, // 500
      "msg": lang.api("No internet connectivity")
    };
  }
}

// To parse this JSON data, do
//
//     final favouriteModel = favouriteModelFromJson(jsonString);

import 'dart:convert';

FavouriteModel favouriteModelFromJson(String str) =>
    FavouriteModel.fromJson(json.decode(str));

String favouriteModelToJson(FavouriteModel data) => json.encode(data.toJson());

class FavouriteModel {
  FavouriteModel({
    this.code,
    this.msg,
    this.details,
    this.favouriteModelGet,
    this.post,
  });

  int code;
  String msg;
  Details details;
  GetFavouriteModel favouriteModelGet;
  List<dynamic> post;

  factory FavouriteModel.fromJson(Map<String, dynamic> json) => FavouriteModel(
        code: json["code"],
        msg: json["msg"],
        details: Details.fromJson(json["details"]),
        favouriteModelGet: GetFavouriteModel.fromJson(json["get"]),
        post: List<dynamic>.from(json["post"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "msg": msg,
        "details": details.toJson(),
        "get": favouriteModelGet.toJson(),
        "post": List<dynamic>.from(post.map((x) => x)),
      };
}

class Details {
  Details({
    this.pageAction,
    this.paginateTotal,
    this.data,
  });

  String pageAction;
  int paginateTotal;
  List<Datum> data;

  factory Details.fromJson(Map<String, dynamic> json) => Details(
        pageAction: json["page_action"],
        paginateTotal: json["paginate_total"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "page_action": pageAction,
        "paginate_total": paginateTotal,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    this.id,
    this.merchantId,
    this.clientId,
    this.dateCreated,
    this.merchantName,
    this.logo,
    this.dateAdded,
    this.rating,
    this.backgroundUrl,
  });

  String id;
  String merchantId;
  String clientId;
  DateTime dateCreated;
  String merchantName;
  String logo;
  String dateAdded;
  Rating rating;
  String backgroundUrl;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        merchantId: json["merchant_id"],
        clientId: json["client_id"],
        dateCreated: DateTime.parse(json["date_created"]),
        merchantName: json["merchant_name"],
        logo: json["logo"],
        dateAdded: json["date_added"],
        rating: Rating.fromJson(json["rating"]),
        backgroundUrl: json["background_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "merchant_id": merchantId,
        "client_id": clientId,
        "date_created": dateCreated.toIso8601String(),
        "merchant_name": merchantName,
        "logo": logo,
        "date_added": dateAdded,
        "rating": rating.toJson(),
        "background_url": backgroundUrl,
      };
}

class Rating {
  Rating({
    this.ratings,
    this.votes,
    this.reviewCount,
  });

  dynamic ratings;
  dynamic votes;
  String reviewCount;

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        ratings: json["ratings"],
        votes: json["votes"],
        reviewCount: json["review_count"],
      );

  Map<String, dynamic> toJson() => {
        "ratings": ratings,
        "votes": votes,
        "review_count": reviewCount,
      };
}

class GetFavouriteModel {
  GetFavouriteModel({
    this.deviceId,
    this.deviceUiid,
    this.devicePlatform,
    this.codeVersion,
    this.lang,
    this.apiKey,
    this.userToken,
    this.lat,
    this.lng,
  });

  String deviceId;
  String deviceUiid;
  String devicePlatform;
  String codeVersion;
  String lang;
  String apiKey;
  String userToken;
  String lat;
  String lng;

  factory GetFavouriteModel.fromJson(Map<String, dynamic> json) =>
      GetFavouriteModel(
        deviceId: json["device_id"],
        deviceUiid: json["device_uiid"],
        devicePlatform: json["device_platform"],
        codeVersion: json["code_version"],
        lang: json["lang"],
        apiKey: json["api_key"],
        userToken: json["user_token"],
        lat: json["lat"],
        lng: json["lng"],
      );

  Map<String, dynamic> toJson() => {
        "device_id": deviceId,
        "device_uiid": deviceUiid,
        "device_platform": devicePlatform,
        "code_version": codeVersion,
        "lang": lang,
        "api_key": apiKey,
        "user_token": userToken,
        "lat": lat,
        "lng": lng,
      };
}

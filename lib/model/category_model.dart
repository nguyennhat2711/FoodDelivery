import 'dart:convert';

CategoryModel categoryModelFromJson(String str) =>
    CategoryModel.fromJson(json.decode(str));

String categoryModelToJson(CategoryModel data) => json.encode(data.toJson());

class CategoryModel {
  CategoryModel({
    this.code,
    this.msg,
    this.details,
    this.categoryModelGet,
    this.post,
  });

  int code;
  String msg;
  Details details;
  GetCategoryModel categoryModelGet;
  List<dynamic> post;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        code: json["code"],
        msg: json["msg"],
        details: Details.fromJson(json["details"]),
        categoryModelGet: GetCategoryModel.fromJson(json["get"]),
        post: List<dynamic>.from(json["post"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "msg": msg,
        "details": details.toJson(),
        "get": categoryModelGet.toJson(),
        "post": List<dynamic>.from(post.map((x) => x)),
      };
}

class GetCategoryModel {
  GetCategoryModel({
    this.apiKey,
    this.lang,
    this.lng,
    this.lat,
    this.userToken,
    this.codeVersion,
    this.deviceUiid,
    this.devicePlatform,
    this.deviceId,
    this.sortBy,
    this.sortFields,
  });

  String apiKey;
  String lang;
  String lng;
  String lat;
  String userToken;
  String codeVersion;
  String deviceUiid;
  String devicePlatform;
  String deviceId;
  String sortBy;
  String sortFields;

  factory GetCategoryModel.fromJson(Map<String, dynamic> json) =>
      GetCategoryModel(
        apiKey: json["api_key"],
        lang: json["lang"],
        lng: json["lng"],
        lat: json["lat"],
        userToken: json["user_token"],
        codeVersion: json["code_version"],
        deviceUiid: json["device_uiid"],
        devicePlatform: json["device_platform"],
        deviceId: json["device_id"],
        sortBy: json["sort_by"],
        sortFields: json["sort_fields"],
      );

  Map<String, dynamic> toJson() => {
        "api_key": apiKey,
        "lang": lang,
        "lng": lng,
        "lat": lat,
        "user_token": userToken,
        "code_version": codeVersion,
        "device_uiid": deviceUiid,
        "device_platform": devicePlatform,
        "device_id": deviceId,
        "sort_by": sortBy,
        "sort_fields": sortFields,
      };
}

class Details {
  Details({
    this.total,
    this.sortbySelected,
    this.pageAction,
    this.list,
  });

  String total;
  String sortbySelected;
  String pageAction;
  List<CategoryModelList> list;

  factory Details.fromJson(Map<String, dynamic> json) => Details(
        total: json["total"],
        sortbySelected: json["sortby_selected"],
        pageAction: json["page_action"],
        list: List<CategoryModelList>.from(
            json["list"].map((x) => CategoryModelList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "sortby_selected": sortbySelected,
        "page_action": pageAction,
        "list": List<dynamic>.from(list.map((x) => x.toJson())),
      };
}

class CategoryModelList {
  CategoryModelList({
    this.id,
    this.name,
    this.featuredImage,
    this.totalMerchant,
  });

  String id;
  String name;
  String featuredImage;
  TotalMerchant totalMerchant;

  factory CategoryModelList.fromJson(Map<String, dynamic> json) =>
      CategoryModelList(
        id: json["id"],
        name: json["name"],
        featuredImage: json["featured_image"],
        totalMerchant: totalMerchantValues.map[json["total_merchant"]],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "featured_image": featuredImage,
        "total_merchant": totalMerchantValues.reverse[totalMerchant],
      };
}

enum TotalMerchant { THE_9, THE_2, THE_0, THE_1 }

final totalMerchantValues = EnumValues({
  "خدمات 0": TotalMerchant.THE_0,
  "خدمات 1": TotalMerchant.THE_1,
  "خدمات 2": TotalMerchant.THE_2,
  "خدمات 9": TotalMerchant.THE_9
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}

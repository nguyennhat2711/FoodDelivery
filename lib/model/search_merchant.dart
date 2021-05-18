import 'dart:convert';

SearchMerchantDart searchMerchantDartFromJson(String str) =>
    SearchMerchantDart.fromJson(json.decode(str));

String searchMerchantDartToJson(SearchMerchantDart data) =>
    json.encode(data.toJson());

class SearchMerchantDart {
  SearchMerchantDart({
    this.code,
    this.msg,
    this.details,
    this.searchMerchantDartGet,
    this.post,
  });

  int code;
  String msg;
  Details details;
  GetSearchMerchantDart searchMerchantDartGet;
  List<dynamic> post;

  factory SearchMerchantDart.fromJson(Map<String, dynamic> json) =>
      SearchMerchantDart(
        code: json["code"],
        msg: json["msg"],
        details: Details.fromJson(json["details"]),
        searchMerchantDartGet: GetSearchMerchantDart.fromJson(json["get"]),
        post: List<dynamic>.from(json["post"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "msg": msg,
        "details": details.toJson(),
        "get": searchMerchantDartGet.toJson(),
        "post": List<dynamic>.from(post.map((x) => x)),
      };
}

class Details {
  Details({
    this.searchType,
    this.totalRecords,
    this.sortbySelected,
    this.pageAction,
    this.paginateTotal,
    this.mapPage,
    this.refreshHome,
    this.searchMerchantList,
  });

  String searchType;
  String totalRecords;
  String sortbySelected;
  String pageAction;
  int paginateTotal;
  String mapPage;
  String refreshHome;
  List<SearchMerchantList> searchMerchantList;

  factory Details.fromJson(Map<String, dynamic> json) => Details(
        searchType: json["search_type"],
        totalRecords: json["total_records"],
        sortbySelected: json["sortby_selected"],
        pageAction: json["page_action"],
        paginateTotal: json["paginate_total"],
        mapPage: json["map_page"],
        refreshHome: json["refresh_home"],
        searchMerchantList: List<SearchMerchantList>.from(
            json["list"].map((x) => SearchMerchantList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "search_type": searchType,
        "total_records": totalRecords,
        "sortby_selected": sortbySelected,
        "page_action": pageAction,
        "paginate_total": paginateTotal,
        "map_page": mapPage,
        "refresh_home": refreshHome,
        "list": List<dynamic>.from(searchMerchantList.map((x) => x.toJson())),
      };
}

class SearchMerchantList {
  SearchMerchantList({
    this.merchantId,
    this.restaurantName,
    this.cuisine,
    this.logo,
    this.latitude,
    this.lontitude,
    this.isSponsored,
    this.deliveryCharges,
    this.service,
    this.status,
    this.isReady,
    this.minimumOrder,
    this.minimumOrderRaw,
    this.isFeatured,
    this.deliveryDistanceCovered,
    this.distanceUnit,
    this.deliveryEstimation,
    this.address,
    this.distance,
    this.merchantOpenStatus,
    this.openStatusRaw,
    this.openStatus,
    this.backgroundUrl,
    this.rating,
    this.deliveryDistance,
    this.offers,
    this.services,
    this.paymetMethodIcon,
    this.distancePlot,
    this.deliveryFee,
    this.sponsored,
  });

  String merchantId;
  String restaurantName;
  String cuisine;
  String logo;
  String latitude;
  String lontitude;
  String isSponsored;
  String deliveryCharges;
  String service;
  String status;
  String isReady;
  String minimumOrder;
  String minimumOrderRaw;
  String isFeatured;
  String deliveryDistanceCovered;
  String distanceUnit;
  String deliveryEstimation;
  String address;
  String distance;
  String merchantOpenStatus;
  String openStatusRaw;
  String openStatus;
  String backgroundUrl;
  Rating rating;
  String deliveryDistance;
  List<dynamic> offers;
  List<String> services;
  List<String> paymetMethodIcon;
  String distancePlot;
  String deliveryFee;
  String sponsored;

  factory SearchMerchantList.fromJson(Map<String, dynamic> json) =>
      SearchMerchantList(
        merchantId: json["merchant_id"],
        restaurantName: json["restaurant_name"],
        cuisine: json["cuisine"],
        logo: json["logo"],
        latitude: json["latitude"],
        lontitude: json["lontitude"],
        isSponsored: json["is_sponsored"],
        deliveryCharges: json["delivery_charges"],
        service: json["service"],
        status: json["status"],
        isReady: json["is_ready"],
        minimumOrder: json["minimum_order"],
        minimumOrderRaw: json["minimum_order_raw"],
        isFeatured: json["is_featured"],
        deliveryDistanceCovered: json["delivery_distance_covered"],
        distanceUnit: json["distance_unit"],
        deliveryEstimation: json["delivery_estimation"],
        address: json["address"],
        distance: json["distance"],
        merchantOpenStatus: json["merchant_open_status"],
        openStatusRaw: json["open_status_raw"],
        openStatus: json["open_status"],
        backgroundUrl: json["background_url"],
        rating: Rating.fromJson(json["rating"]),
        deliveryDistance: json["delivery_distance"],
        offers: List<dynamic>.from(json["offers"].map((x) => x)),
        services: List<String>.from(json["services"].map((x) => x)),
        paymetMethodIcon:
            List<String>.from(json["paymet_method_icon"].map((x) => x)),
        distancePlot: json["distance_plot"],
        deliveryFee: json["delivery_fee"] == null ? null : json["delivery_fee"],
        sponsored: json["sponsored"] == null ? null : json["sponsored"],
      );

  Map<String, dynamic> toJson() => {
        "merchant_id": merchantId,
        "restaurant_name": restaurantName,
        "cuisine": cuisine,
        "logo": logo,
        "latitude": latitude,
        "lontitude": lontitude,
        "is_sponsored": isSponsored,
        "delivery_charges": deliveryCharges,
        "service": service,
        "status": status,
        "is_ready": isReady,
        "minimum_order": minimumOrder,
        "minimum_order_raw": minimumOrderRaw,
        "is_featured": isFeatured,
        "delivery_distance_covered": deliveryDistanceCovered,
        "distance_unit": distanceUnit,
        "delivery_estimation": deliveryEstimation,
        "address": address,
        "distance": distance,
        "merchant_open_status": merchantOpenStatus,
        "open_status_raw": openStatusRaw,
        "open_status": openStatus,
        "background_url": backgroundUrl,
        "rating": rating.toJson(),
        "delivery_distance": deliveryDistance,
        "offers": List<dynamic>.from(offers.map((x) => x)),
        "services": List<dynamic>.from(services.map((x) => x)),
        "paymet_method_icon":
            List<dynamic>.from(paymetMethodIcon.map((x) => x)),
        "distance_plot": distancePlot,
        "delivery_fee": deliveryFee == null ? null : deliveryFee,
        "sponsored": sponsored == null ? null : sponsored,
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

class GetSearchMerchantDart {
  GetSearchMerchantDart({
    this.withDistance,
    this.sortBy,
    this.searchType,
    this.deviceId,
    this.deviceUiid,
    this.devicePlatform,
    this.codeVersion,
    this.lang,
    this.apiKey,
    this.lat,
    this.lng,
  });

  String withDistance;
  String sortBy;
  String searchType;
  String deviceId;
  String deviceUiid;
  String devicePlatform;
  String codeVersion;
  String lang;
  String apiKey;
  String lat;
  String lng;

  factory GetSearchMerchantDart.fromJson(Map<String, dynamic> json) =>
      GetSearchMerchantDart(
        withDistance: json["with_distance"],
        sortBy: json["sort_by"],
        searchType: json["search_type"],
        deviceId: json["device_id"],
        deviceUiid: json["device_uiid"],
        devicePlatform: json["device_platform"],
        codeVersion: json["code_version"],
        lang: json["lang"],
        apiKey: json["api_key"],
        lat: json["lat"],
        lng: json["lng"],
      );

  Map<String, dynamic> toJson() => {
        "with_distance": withDistance,
        "sort_by": sortBy,
        "search_type": searchType,
        "device_id": deviceId,
        "device_uiid": deviceUiid,
        "device_platform": devicePlatform,
        "code_version": codeVersion,
        "lang": lang,
        "api_key": apiKey,
        "lat": lat,
        "lng": lng,
      };
}

class RestaurantModel {
  List<OneRestaurant> restaurant;

  RestaurantModel({this.restaurant});

  RestaurantModel.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      restaurant = [];
      json['list'].forEach((v) {
        restaurant.add(new OneRestaurant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.restaurant != null) {
      data['list'] = this.restaurant.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OneRestaurant {
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
  List<Null> offers;
  List<String> services;
  List<String> paymetMethodIcon;
  String distancePlot;
  String deliveryFee;

  OneRestaurant(
      {this.merchantId,
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
      this.deliveryFee});

  OneRestaurant.fromJson(Map<String, dynamic> json) {
    merchantId = json['merchant_id'];
    restaurantName = json['restaurant_name'];
    cuisine = json['cuisine'];
    logo = json['logo'];
    latitude = json['latitude'];
    lontitude = json['lontitude'];
    isSponsored = json['is_sponsored'];
    deliveryCharges = json['delivery_charges'];
    service = json['service'];
    status = json['status'];
    isReady = json['is_ready'];
    minimumOrder = json['minimum_order'];
    minimumOrderRaw = json['minimum_order_raw'];
    isFeatured = json['is_featured'];
    deliveryDistanceCovered = json['delivery_distance_covered'];
    distanceUnit = json['distance_unit'];
    deliveryEstimation = json['delivery_estimation'];
    address = json['address'];
    distance = json['distance'];
    merchantOpenStatus = json['merchant_open_status'];
    openStatusRaw = json['open_status_raw'];
    openStatus = json['open_status'];
    backgroundUrl = json['background_url'];
    rating =
        json['rating'] != null ? new Rating.fromJson(json['rating']) : null;
    deliveryDistance = json['delivery_distance'];
    services = json['services'].cast<String>();
    paymetMethodIcon = json['paymet_method_icon'].cast<String>();
    distancePlot = json['distance_plot'];
    deliveryFee = json['delivery_fee'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['merchant_id'] = this.merchantId;
    data['restaurant_name'] = this.restaurantName;
    data['cuisine'] = this.cuisine;
    data['logo'] = this.logo;
    data['latitude'] = this.latitude;
    data['lontitude'] = this.lontitude;
    data['is_sponsored'] = this.isSponsored;
    data['delivery_charges'] = this.deliveryCharges;
    data['service'] = this.service;
    data['status'] = this.status;
    data['is_ready'] = this.isReady;
    data['minimum_order'] = this.minimumOrder;
    data['minimum_order_raw'] = this.minimumOrderRaw;
    data['is_featured'] = this.isFeatured;
    data['delivery_distance_covered'] = this.deliveryDistanceCovered;
    data['distance_unit'] = this.distanceUnit;
    data['delivery_estimation'] = this.deliveryEstimation;
    data['address'] = this.address;
    data['distance'] = this.distance;
    data['merchant_open_status'] = this.merchantOpenStatus;
    data['open_status_raw'] = this.openStatusRaw;
    data['open_status'] = this.openStatus;
    data['background_url'] = this.backgroundUrl;
    if (this.rating != null) {
      data['rating'] = this.rating.toJson();
    }
    data['delivery_distance'] = this.deliveryDistance;
    data['services'] = this.services;
    data['paymet_method_icon'] = this.paymetMethodIcon;
    data['distance_plot'] = this.distancePlot;
    data['delivery_fee'] = this.deliveryFee;
    return data;
  }
}

class Rating {
  String ratings;
  String votes;
  String reviewCount;

  Rating({this.ratings, this.votes, this.reviewCount});

  Rating.fromJson(Map<String, dynamic> json) {
    ratings = json['ratings'];
    votes = json['votes'];
    reviewCount = json['review_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ratings'] = this.ratings;
    data['votes'] = this.votes;
    data['review_count'] = this.reviewCount;
    return data;
  }
}

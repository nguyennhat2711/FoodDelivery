import 'dart:convert';

import 'package:afandim/model/banner_model.dart';

SettingsModel settingsModelFromJson(String str) =>
    SettingsModel.fromJson(json.decode(str));

String settingsModelToJson(SettingsModel data) => json.encode(data.toJson());

class SettingsModel {
  SettingsModel({
    this.code,
    this.msg,
    this.details,
    this.settingsModelGet,
    this.post,
  });

  int code;
  String msg;
  Details details;
  Get settingsModelGet;
  List<dynamic> post;

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        code: json["code"],
        msg: json["msg"],
        details: Details.fromJson(json["details"]),
        settingsModelGet: Get.fromJson(json["get"]),
        post: List<dynamic>.from(json["post"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "msg": msg,
        "details": details.toJson(),
        "get": settingsModelGet.toJson(),
        "post": List<dynamic>.from(post.map((x) => x)),
      };
}

class Details {
  Details({
    this.validToken,
    this.settings,
  });

  int validToken;
  Settings settings;

  factory Details.fromJson(Map<String, dynamic> json) => Details(
        validToken: json["valid_token"],
        settings: Settings.fromJson(json["settings"]),
      );

  Map<String, dynamic> toJson() => {
        "valid_token": validToken,
        "settings": settings.toJson(),
      };
}

class Settings {
  Settings({
    this.startup,
    this.searchMode,
    this.locationMode,
    this.mobilePrefix,
    this.cartTheme,
    this.futureOrderConfirm,
    this.mobileTurnoffPrefix,
    this.menuType,
    this.enabledDish,
    this.disabledImageMenu1,
    this.mobileapp2SelectMap,
    this.mobileapp2Language,
    this.mobile2EnabledFblogin,
    this.mobile2EnabledGooglogin,
    this.mobile2AnalyticsEnabled,
    this.mobile2AnalyticsId,
    this.mobile2LocationAccuracy,
    this.ageRestriction,
    this.ageRestrictionContent,
    this.registration,
    this.trackingTheme,
    this.trackingInterval,
    this.home,
    this.homeBanner,
    this.mobile2DisabledDefaultImage,
    this.mapProvider,
    this.mapCountry,
    this.mapAutoIdentityLocation,
    this.defaultMapLocation,
    this.websiteHideFoodprice,
    this.enabledMapSelectionDelivery,
    this.merchantTwoFlavorOption,
    this.images,
    this.icons,
    this.markerIcon,
    this.listType,
    this.addon,
    this.codChangeRequired,
    this.disabledWebsiteOrdering,
    this.mapboxAccessToken,
    this.mapboxDefaultZoom,
    this.disabledCcManagement,
    this.merchantTblBookDisabled,
    this.currencySymbol,
    this.currencyPosition,
    this.currencyDecimalPlace,
    this.currencySpace,
    this.currencyUseSeparators,
    this.currencyDecimalSeparator,
    this.currencyThousandSeparator,
    this.regCustom,
    this.validToken,
    this.subscribeTopic,
    this.sort,
    this.filters,
    this.customPages,
    this.customPagesLocation,
    this.orderTabs,
    this.bookingTabs,
    this.dict,
    this.signupSettings,
    this.enabledAddonDesc,
    this.geocompleteDefaultCountry,
    this.contactUs,
    this.removeContact,
    this.langRtl,
    this.customerForgotPasswordSms,
  });

  Startup startup;
  String searchMode;
  String locationMode;
  String mobilePrefix;
  String cartTheme;
  String futureOrderConfirm;
  String mobileTurnoffPrefix;
  String menuType;
  String enabledDish;
  String disabledImageMenu1;
  String mobileapp2SelectMap;
  String mobileapp2Language;
  String mobile2EnabledFblogin;
  String mobile2EnabledGooglogin;
  String mobile2AnalyticsEnabled;
  String mobile2AnalyticsId;
  String mobile2LocationAccuracy;
  String ageRestriction;
  String ageRestrictionContent;
  Registration registration;
  String trackingTheme;
  int trackingInterval;
  Home home;
  List<HomeBannerModel> homeBanner;
  String mobile2DisabledDefaultImage;
  MapProvider mapProvider;
  String mapCountry;
  bool mapAutoIdentityLocation;
  DefaultMapLocation defaultMapLocation;
  String websiteHideFoodprice;
  String enabledMapSelectionDelivery;
  String merchantTwoFlavorOption;
  Images images;
  Icons icons;
  List<String> markerIcon;
  String listType;
  Addon addon;
  String codChangeRequired;
  String disabledWebsiteOrdering;
  String mapboxAccessToken;
  String mapboxDefaultZoom;
  String disabledCcManagement;
  String merchantTblBookDisabled;
  String currencySymbol;
  String currencyPosition;
  String currencyDecimalPlace;
  String currencySpace;
  String currencyUseSeparators;
  String currencyDecimalSeparator;
  String currencyThousandSeparator;
  int regCustom;
  int validToken;
  dynamic subscribeTopic;
  Sort sort;
  Filters filters;
  bool customPages;
  String customPagesLocation;
  OrderTabs orderTabs;
  BookingTabs bookingTabs;
  Map<String, Dict> dict;
  SignupSettings signupSettings;
  String enabledAddonDesc;
  String geocompleteDefaultCountry;
  ContactUs contactUs;
  String removeContact;
  List<String> langRtl;
  String customerForgotPasswordSms;

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        startup: Startup.fromJson(json["startup"]),
        searchMode: json["search_mode"],
        locationMode: json["location_mode"],
        mobilePrefix: json["mobile_prefix"],
        cartTheme: json["cart_theme"],
        futureOrderConfirm: json["future_order_confirm"],
        mobileTurnoffPrefix: json["mobile_turnoff_prefix"],
        menuType: json["menu_type"],
        enabledDish: json["enabled_dish"],
        disabledImageMenu1: json["disabled_image_menu1"],
        mobileapp2SelectMap: json["mobileapp2_select_map"],
        mobileapp2Language: json["mobileapp2_language"],
        mobile2EnabledFblogin: json["mobile2_enabled_fblogin"],
        mobile2EnabledGooglogin: json["mobile2_enabled_googlogin"],
        mobile2AnalyticsEnabled: json["mobile2_analytics_enabled"],
        mobile2AnalyticsId: json["mobile2_analytics_id"],
        mobile2LocationAccuracy: json["mobile2_location_accuracy"],
        ageRestriction: json["age_restriction"],
        ageRestrictionContent: json["age_restriction_content"],
        registration: Registration.fromJson(json["registration"]),
        trackingTheme: json["tracking_theme"],
        trackingInterval: json["tracking_interval"],
        home: Home.fromJson(json["home"]),
        homeBanner: List<HomeBannerModel>.from(
            json["home_banner"].map((x) => HomeBannerModel.fromJson(x))),
        mobile2DisabledDefaultImage: json["mobile2_disabled_default_image"],
        mapProvider: MapProvider.fromJson(json["map_provider"]),
        mapCountry: json["map_country"],
        mapAutoIdentityLocation: json["map_auto_identity_location"],
        defaultMapLocation:
            DefaultMapLocation.fromJson(json["default_map_location"]),
        websiteHideFoodprice: json["website_hide_foodprice"],
        enabledMapSelectionDelivery: json["enabled_map_selection_delivery"],
        merchantTwoFlavorOption: json["merchant_two_flavor_option"],
        images: Images.fromJson(json["images"]),
        icons: Icons.fromJson(json["icons"]),
        markerIcon: List<String>.from(json["marker_icon"].map((x) => x)),
        listType: json["list_type"],
        addon: Addon.fromJson(json["addon"]),
        codChangeRequired: json["cod_change_required"],
        disabledWebsiteOrdering: json["disabled_website_ordering"],
        mapboxAccessToken: json["mapbox_access_token"],
        mapboxDefaultZoom: json["mapbox_default_zoom"],
        disabledCcManagement: json["disabled_cc_management"],
        merchantTblBookDisabled: json["merchant_tbl_book_disabled"],
        currencySymbol: json["currency_symbol"],
        currencyPosition: json["currency_position"],
        currencyDecimalPlace: json["currency_decimal_place"],
        currencySpace: json["currency_space"],
        currencyUseSeparators: json["currency_use_separators"],
        currencyDecimalSeparator: json["currency_decimal_separator"],
        currencyThousandSeparator: json["currency_thousand_separator"],
        regCustom: json["reg_custom"],
        validToken: json["valid_token"],
        subscribeTopic: json["subscribe_topic"],
        sort: Sort.fromJson(json["sort"]),
        filters: Filters.fromJson(json["filters"]),
        customPages: json["custom_pages"],
        customPagesLocation: json["custom_pages_location"],
        orderTabs: OrderTabs.fromJson(json["order_tabs"]),
        bookingTabs: BookingTabs.fromJson(json["booking_tabs"]),
        dict: Map.from(json["dict"])
            .map((k, v) => MapEntry<String, Dict>(k, Dict.fromJson(v))),
        signupSettings: SignupSettings.fromJson(json["signup_settings"]),
        enabledAddonDesc: json["enabled_addon_desc"],
        geocompleteDefaultCountry: json["geocomplete_default_country"],
        contactUs: ContactUs.fromJson(json["contact_us"]),
        removeContact: json["remove_contact"],
        langRtl: List<String>.from(json["lang_rtl"].map((x) => x)),
        customerForgotPasswordSms: json["customer_forgot_password_sms"],
      );

  Map<String, dynamic> toJson() => {
        "startup": startup.toJson(),
        "search_mode": searchMode,
        "location_mode": locationMode,
        "mobile_prefix": mobilePrefix,
        "cart_theme": cartTheme,
        "future_order_confirm": futureOrderConfirm,
        "mobile_turnoff_prefix": mobileTurnoffPrefix,
        "menu_type": menuType,
        "enabled_dish": enabledDish,
        "disabled_image_menu1": disabledImageMenu1,
        "mobileapp2_select_map": mobileapp2SelectMap,
        "mobileapp2_language": mobileapp2Language,
        "mobile2_enabled_fblogin": mobile2EnabledFblogin,
        "mobile2_enabled_googlogin": mobile2EnabledGooglogin,
        "mobile2_analytics_enabled": mobile2AnalyticsEnabled,
        "mobile2_analytics_id": mobile2AnalyticsId,
        "mobile2_location_accuracy": mobile2LocationAccuracy,
        "age_restriction": ageRestriction,
        "age_restriction_content": ageRestrictionContent,
        "registration": registration.toJson(),
        "tracking_theme": trackingTheme,
        "tracking_interval": trackingInterval,
        "home": home.toJson(),
        "home_banner": List<dynamic>.from(homeBanner.map((x) => x.toJson())),
        "mobile2_disabled_default_image": mobile2DisabledDefaultImage,
        "map_provider": mapProvider.toJson(),
        "map_country": mapCountry,
        "map_auto_identity_location": mapAutoIdentityLocation,
        "default_map_location": defaultMapLocation.toJson(),
        "website_hide_foodprice": websiteHideFoodprice,
        "enabled_map_selection_delivery": enabledMapSelectionDelivery,
        "merchant_two_flavor_option": merchantTwoFlavorOption,
        "images": images.toJson(),
        "icons": icons.toJson(),
        "marker_icon": List<dynamic>.from(markerIcon.map((x) => x)),
        "list_type": listType,
        "addon": addon.toJson(),
        "cod_change_required": codChangeRequired,
        "disabled_website_ordering": disabledWebsiteOrdering,
        "mapbox_access_token": mapboxAccessToken,
        "mapbox_default_zoom": mapboxDefaultZoom,
        "disabled_cc_management": disabledCcManagement,
        "merchant_tbl_book_disabled": merchantTblBookDisabled,
        "currency_symbol": currencySymbol,
        "currency_position": currencyPosition,
        "currency_decimal_place": currencyDecimalPlace,
        "currency_space": currencySpace,
        "currency_use_separators": currencyUseSeparators,
        "currency_decimal_separator": currencyDecimalSeparator,
        "currency_thousand_separator": currencyThousandSeparator,
        "reg_custom": regCustom,
        "valid_token": validToken,
        "subscribe_topic": subscribeTopic,
        "sort": sort.toJson(),
        "filters": filters.toJson(),
        "custom_pages": customPages,
        "custom_pages_location": customPagesLocation,
        "order_tabs": orderTabs.toJson(),
        "booking_tabs": bookingTabs.toJson(),
        "dict": Map.from(dict)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "signup_settings": signupSettings.toJson(),
        "enabled_addon_desc": enabledAddonDesc,
        "geocomplete_default_country": geocompleteDefaultCountry,
        "contact_us": contactUs.toJson(),
        "remove_contact": removeContact,
        "lang_rtl": List<dynamic>.from(langRtl.map((x) => x)),
        "customer_forgot_password_sms": customerForgotPasswordSms,
      };
}

class Addon {
  Addon({
    this.driver,
    this.driverTransport,
    this.points,
  });

  bool driver;
  DriverTransport driverTransport;
  bool points;

  factory Addon.fromJson(Map<String, dynamic> json) => Addon(
        driver: json["driver"],
        driverTransport: DriverTransport.fromJson(json["driver_transport"]),
        points: json["points"],
      );

  Map<String, dynamic> toJson() => {
        "driver": driver,
        "driver_transport": driverTransport.toJson(),
        "points": points,
      };
}

class DriverTransport {
  DriverTransport({
    this.the0,
    this.truck,
    this.car,
    this.bike,
    this.bicycle,
    this.scooter,
    this.walk,
  });

  String the0;
  String truck;
  String car;
  String bike;
  String bicycle;
  String scooter;
  String walk;

  factory DriverTransport.fromJson(Map<String, dynamic> json) =>
      DriverTransport(
        the0: json["0"],
        truck: json["truck"],
        car: json["car"],
        bike: json["bike"],
        bicycle: json["bicycle"],
        scooter: json["scooter"],
        walk: json["walk"],
      );

  Map<String, dynamic> toJson() => {
        "0": the0,
        "truck": truck,
        "car": car,
        "bike": bike,
        "bicycle": bicycle,
        "scooter": scooter,
        "walk": walk,
      };
}

class BookingTabs {
  BookingTabs({
    this.all,
    this.pending,
    this.approved,
    this.denied,
  });

  String all;
  String pending;
  String approved;
  String denied;

  factory BookingTabs.fromJson(Map<String, dynamic> json) => BookingTabs(
        all: json["all"],
        pending: json["pending"],
        approved: json["approved"],
        denied: json["denied"],
      );

  Map<String, dynamic> toJson() => {
        "all": all,
        "pending": pending,
        "approved": approved,
        "denied": denied,
      };
}

class ContactUs {
  ContactUs({
    this.contactContent,
    this.contactField,
    this.enabledContact,
  });

  String contactContent;
  List<String> contactField;
  String enabledContact;

  factory ContactUs.fromJson(Map<String, dynamic> json) => ContactUs(
        contactContent: json["contact_content"],
        contactField: List<String>.from(json["contact_field"].map((x) => x)),
        enabledContact: json["enabled_contact"],
      );

  Map<String, dynamic> toJson() => {
        "contact_content": contactContent,
        "contact_field": List<dynamic>.from(contactField.map((x) => x)),
        "enabled_contact": enabledContact,
      };
}

class DefaultMapLocation {
  DefaultMapLocation({
    this.lat,
    this.lng,
  });

  String lat;
  String lng;

  factory DefaultMapLocation.fromJson(Map<String, dynamic> json) =>
      DefaultMapLocation(
        lat: json["lat"],
        lng: json["lng"],
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}

class Dict {
  Dict({
    this.english,
    this.trke,
    this.empty,
  });

  String english;
  String trke;
  String empty;

  factory Dict.fromJson(Map<String, dynamic> json) => Dict(
        english: json["English"] == null ? null : json["English"],
        trke: json["Türkçe"] == null ? null : json["Türkçe"],
        empty: json["العربية"],
      );

  Map<String, dynamic> toJson() => {
        "English": english == null ? null : english,
        "Türkçe": trke == null ? null : trke,
        "العربية": empty,
      };
}

class Filters {
  Filters({
    this.deliveryFee,
    this.promos,
    this.services,
    this.dishesList,
    this.cuisine,
    this.minimumOrder,
  });

  DeliveryFee deliveryFee;
  Promos promos;
  Services services;
  List<DishesList> dishesList;
  List<Cuisine> cuisine;
  Map<String, String> minimumOrder;

  factory Filters.fromJson(Map<String, dynamic> json) => Filters(
        deliveryFee: DeliveryFee.fromJson(json["delivery_fee"]),
        promos: Promos.fromJson(json["promos"]),
        services: Services.fromJson(json["services"]),
        dishesList: List<DishesList>.from(
            json["dishes_list"].map((x) => DishesList.fromJson(x))),
        cuisine:
            List<Cuisine>.from(json["cuisine"].map((x) => Cuisine.fromJson(x))),
        minimumOrder: Map.from(json["minimum_order"])
            .map((k, v) => MapEntry<String, String>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "delivery_fee": deliveryFee.toJson(),
        "promos": promos.toJson(),
        "services": services.toJson(),
        "dishes_list": List<dynamic>.from(dishesList.map((x) => x.toJson())),
        "cuisine": List<dynamic>.from(cuisine.map((x) => x.toJson())),
        "minimum_order": Map.from(minimumOrder)
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}

class Cuisine {
  Cuisine({
    this.cuisineId,
    this.cuisineName,
    this.sequence,
    this.dateCreated,
    this.dateModified,
    this.ipAddress,
    this.cuisineNameTrans,
    this.status,
    this.featuredImage,
    this.slug,
  });

  String cuisineId;
  String cuisineName;
  String sequence;
  DateTime dateCreated;
  DateTime dateModified;
  IpAddress ipAddress;
  String cuisineNameTrans;
  Status status;
  String featuredImage;
  String slug;

  factory Cuisine.fromJson(Map<String, dynamic> json) => Cuisine(
        cuisineId: json["cuisine_id"],
        cuisineName: json["cuisine_name"],
        sequence: json["sequence"],
        dateCreated: DateTime.parse(json["date_created"]),
        dateModified: DateTime.parse(json["date_modified"]),
        ipAddress: ipAddressValues.map[json["ip_address"]],
        cuisineNameTrans: json["cuisine_name_trans"],
        status: statusValues.map[json["status"]],
        featuredImage: json["featured_image"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "cuisine_id": cuisineId,
        "cuisine_name": cuisineName,
        "sequence": sequence,
        "date_created": dateCreated.toIso8601String(),
        "date_modified": dateModified.toIso8601String(),
        "ip_address": ipAddressValues.reverse[ipAddress],
        "cuisine_name_trans": cuisineNameTrans,
        "status": statusValues.reverse[status],
        "featured_image": featuredImage,
        "slug": slug,
      };
}

enum IpAddress {
  THE_188114111168,
  THE_16215889214,
  THE_1621583035,
  THE_141101767
}

final ipAddressValues = EnumValues({
  "141.101.76.7": IpAddress.THE_141101767,
  "162.158.30.35": IpAddress.THE_1621583035,
  "162.158.89.214": IpAddress.THE_16215889214,
  "188.114.111.168": IpAddress.THE_188114111168
});

enum Status { PUBLISH }

final statusValues = EnumValues({"publish": Status.PUBLISH});

class DeliveryFee {
  DeliveryFee({
    this.deliveryFee,
  });

  String deliveryFee;

  factory DeliveryFee.fromJson(Map<String, dynamic> json) => DeliveryFee(
        deliveryFee: json["delivery_fee"],
      );

  Map<String, dynamic> toJson() => {
        "delivery_fee": deliveryFee,
      };
}

class DishesList {
  DishesList({
    this.dishId,
    this.dishName,
  });

  String dishId;
  String dishName;

  factory DishesList.fromJson(Map<String, dynamic> json) => DishesList(
        dishId: json["dish_id"],
        dishName: json["dish_name"],
      );

  Map<String, dynamic> toJson() => {
        "dish_id": dishId,
        "dish_name": dishName,
      };
}

class Promos {
  Promos({
    this.offer,
    this.voucher,
  });

  String offer;
  String voucher;

  factory Promos.fromJson(Map<String, dynamic> json) => Promos(
        offer: json["offer"],
        voucher: json["voucher"],
      );

  Map<String, dynamic> toJson() => {
        "offer": offer,
        "voucher": voucher,
      };
}

class Services {
  Services({
    this.delivery,
    this.pickup,
    this.dinein,
  });

  String delivery;
  String pickup;
  String dinein;

  factory Services.fromJson(Map<String, dynamic> json) => Services(
        delivery: json["delivery"],
        pickup: json["pickup"],
        dinein: json["dinein"],
      );

  Map<String, dynamic> toJson() => {
        "delivery": delivery,
        "pickup": pickup,
        "dinein": dinein,
      };
}

class Home {
  Home({
    this.mobile2HomeOffer,
    this.mobile2HomeFeatured,
    this.mobile2HomeCuisine,
    this.mobile2HomeAllRestaurant,
    this.mobile2HomeFavoriteRestaurant,
    this.mobile2HomeBanner,
    this.mobile2HomeBannerFull,
    this.mobile2HomeFoodDiscount,
    this.mobile2HomeBannerAutoScroll,
  });

  String mobile2HomeOffer;
  String mobile2HomeFeatured;
  String mobile2HomeCuisine;
  String mobile2HomeAllRestaurant;
  String mobile2HomeFavoriteRestaurant;
  String mobile2HomeBanner;
  String mobile2HomeBannerFull;
  String mobile2HomeFoodDiscount;
  String mobile2HomeBannerAutoScroll;

  factory Home.fromJson(Map<String, dynamic> json) => Home(
        mobile2HomeOffer: json["mobile2_home_offer"],
        mobile2HomeFeatured: json["mobile2_home_featured"],
        mobile2HomeCuisine: json["mobile2_home_cuisine"],
        mobile2HomeAllRestaurant: json["mobile2_home_all_restaurant"],
        mobile2HomeFavoriteRestaurant: json["mobile2_home_favorite_restaurant"],
        mobile2HomeBanner: json["mobile2_home_banner"],
        mobile2HomeBannerFull: json["mobile2_home_banner_full"],
        mobile2HomeFoodDiscount: json["mobile2_home_food_discount"],
        mobile2HomeBannerAutoScroll: json["mobile2_home_banner_auto_scroll"],
      );

  Map<String, dynamic> toJson() => {
        "mobile2_home_offer": mobile2HomeOffer,
        "mobile2_home_featured": mobile2HomeFeatured,
        "mobile2_home_cuisine": mobile2HomeCuisine,
        "mobile2_home_all_restaurant": mobile2HomeAllRestaurant,
        "mobile2_home_favorite_restaurant": mobile2HomeFavoriteRestaurant,
        "mobile2_home_banner": mobile2HomeBanner,
        "mobile2_home_banner_full": mobile2HomeBannerFull,
        "mobile2_home_food_discount": mobile2HomeFoodDiscount,
        "mobile2_home_banner_auto_scroll": mobile2HomeBannerAutoScroll,
      };
}

class Icons {
  Icons({
    this.marker1,
    this.marker2,
    this.marker3,
    this.bicycle,
    this.bike,
    this.car,
    this.scooter,
    this.truck,
    this.walk,
  });

  String marker1;
  String marker2;
  String marker3;
  String bicycle;
  String bike;
  String car;
  String scooter;
  String truck;
  String walk;

  factory Icons.fromJson(Map<String, dynamic> json) => Icons(
        marker1: json["marker1"],
        marker2: json["marker2"],
        marker3: json["marker3"],
        bicycle: json["bicycle"],
        bike: json["bike"],
        car: json["car"],
        scooter: json["scooter"],
        truck: json["truck"],
        walk: json["walk"],
      );

  Map<String, dynamic> toJson() => {
        "marker1": marker1,
        "marker2": marker2,
        "marker3": marker3,
        "bicycle": bicycle,
        "bike": bike,
        "car": car,
        "scooter": scooter,
        "truck": truck,
        "walk": walk,
      };
}

class Images {
  Images({
    this.image1,
    this.image2,
    this.image3,
  });

  String image1;
  String image2;
  String image3;

  factory Images.fromJson(Map<String, dynamic> json) => Images(
        image1: json["image1"],
        image2: json["image2"],
        image3: json["image3"],
      );

  Map<String, dynamic> toJson() => {
        "image1": image1,
        "image2": image2,
        "image3": image3,
      };
}

class MapProvider {
  MapProvider({
    this.provider,
    this.token,
    this.mapApi,
    this.mapDistanceResults,
    this.mode,
  });

  String provider;
  String token;
  String mapApi;
  int mapDistanceResults;
  String mode;

  factory MapProvider.fromJson(Map<String, dynamic> json) => MapProvider(
        provider: json["provider"],
        token: json["token"],
        mapApi: json["map_api"],
        mapDistanceResults: json["map_distance_results"],
        mode: json["mode"],
      );

  Map<String, dynamic> toJson() => {
        "provider": provider,
        "token": token,
        "map_api": mapApi,
        "map_distance_results": mapDistanceResults,
        "mode": mode,
      };
}

class OrderTabs {
  OrderTabs({
    this.all,
    this.processing,
    this.completed,
    this.cancelled,
  });

  String all;
  String processing;
  String completed;
  String cancelled;

  factory OrderTabs.fromJson(Map<String, dynamic> json) => OrderTabs(
        all: json["all"],
        processing: json["processing"],
        completed: json["completed"],
        cancelled: json["cancelled"],
      );

  Map<String, dynamic> toJson() => {
        "all": all,
        "processing": processing,
        "completed": completed,
        "cancelled": cancelled,
      };
}

class Registration {
  Registration({
    this.email,
    this.phone,
  });

  String email;
  String phone;

  factory Registration.fromJson(Map<String, dynamic> json) => Registration(
        email: json["email"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "phone": phone,
      };
}

class SignupSettings {
  SignupSettings({
    this.enabledTermsCondition,
    this.termsUrl,
  });

  int enabledTermsCondition;
  String termsUrl;

  factory SignupSettings.fromJson(Map<String, dynamic> json) => SignupSettings(
        enabledTermsCondition: json["enabled_terms_condition"],
        termsUrl: json["terms_url"],
      );

  Map<String, dynamic> toJson() => {
        "enabled_terms_condition": enabledTermsCondition,
        "terms_url": termsUrl,
      };
}

class Sort {
  Sort({
    this.restaurant,
    this.cusine,
    this.foodPromo,
  });

  Restaurant restaurant;
  Cusine cusine;
  FoodPromo foodPromo;

  factory Sort.fromJson(Map<String, dynamic> json) => Sort(
        restaurant: Restaurant.fromJson(json["restaurant"]),
        cusine: Cusine.fromJson(json["cusine"]),
        foodPromo: FoodPromo.fromJson(json["food_promo"]),
      );

  Map<String, dynamic> toJson() => {
        "restaurant": restaurant.toJson(),
        "cusine": cusine.toJson(),
        "food_promo": foodPromo.toJson(),
      };
}

class Cusine {
  Cusine({
    this.cuisineName,
    this.sequence,
  });

  String cuisineName;
  String sequence;

  factory Cusine.fromJson(Map<String, dynamic> json) => Cusine(
        cuisineName: json["cuisine_name"],
        sequence: json["sequence"],
      );

  Map<String, dynamic> toJson() => {
        "cuisine_name": cuisineName,
        "sequence": sequence,
      };
}

class FoodPromo {
  FoodPromo({
    this.discount,
    this.itemName,
  });

  String discount;
  String itemName;

  factory FoodPromo.fromJson(Map<String, dynamic> json) => FoodPromo(
        discount: json["discount"],
        itemName: json["item_name"],
      );

  Map<String, dynamic> toJson() => {
        "discount": discount,
        "item_name": itemName,
      };
}

class Restaurant {
  Restaurant({
    this.merchantOpenStatus,
    this.restaurantName,
    this.ratings,
    this.reviewCount,
    this.minimumOrder,
    this.distance,
  });

  String merchantOpenStatus;
  String restaurantName;
  String ratings;
  String reviewCount;
  String minimumOrder;
  String distance;

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        merchantOpenStatus: json["merchant_open_status"],
        restaurantName: json["restaurant_name"],
        ratings: json["ratings"],
        reviewCount: json["review_count"],
        minimumOrder: json["minimum_order"],
        distance: json["distance"],
      );

  Map<String, dynamic> toJson() => {
        "merchant_open_status": merchantOpenStatus,
        "restaurant_name": restaurantName,
        "ratings": ratings,
        "review_count": reviewCount,
        "minimum_order": minimumOrder,
        "distance": distance,
      };
}

class Startup {
  Startup({
    this.options,
    this.selectLanguage,
    this.banner,
    this.startupAutoScroll,
    this.startupInterval,
  });

  String options;
  String selectLanguage;
  List<String> banner;
  String startupAutoScroll;
  String startupInterval;

  factory Startup.fromJson(Map<String, dynamic> json) => Startup(
        options: json["options"],
        selectLanguage: json["select_language"],
        banner: List<String>.from(json["banner"].map((x) => x)),
        startupAutoScroll: json["startup_auto_scroll"],
        startupInterval: json["startup_interval"],
      );

  Map<String, dynamic> toJson() => {
        "options": options,
        "select_language": selectLanguage,
        "banner": List<dynamic>.from(banner.map((x) => x)),
        "startup_auto_scroll": startupAutoScroll,
        "startup_interval": startupInterval,
      };
}

class Get {
  Get({
    this.deviceId,
    this.deviceUiid,
    this.devicePlatform,
    this.codeVersion,
    this.lang,
    this.apiKey,
  });

  String deviceId;
  String deviceUiid;
  String devicePlatform;
  String codeVersion;
  String lang;
  String apiKey;

  factory Get.fromJson(Map<String, dynamic> json) => Get(
        deviceId: json["device_id"],
        deviceUiid: json["device_uiid"],
        devicePlatform: json["device_platform"],
        codeVersion: json["code_version"],
        lang: json["lang"],
        apiKey: json["api_key"],
      );

  Map<String, dynamic> toJson() => {
        "device_id": deviceId,
        "device_uiid": deviceUiid,
        "device_platform": devicePlatform,
        "code_version": codeVersion,
        "lang": lang,
        "api_key": apiKey,
      };
}

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

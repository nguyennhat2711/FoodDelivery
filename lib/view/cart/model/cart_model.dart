import 'dart:convert';

CartModel cartModelFromJson(String str) => CartModel.fromJson(json.decode(str));

String cartModelToJson(CartModel data) => json.encode(data.toJson());

class CartModel {
  CartModel({
    this.code,
    this.msg,
    this.details,
  });

  int code;
  String msg;
  CartModelDetails details;

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        code: json["code"],
        msg: json["msg"],
        details: CartModelDetails.fromJson(json["details"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "msg": msg,
        "details": details.toJson(),
      };
}

class CartModelDetails {
  CartModelDetails({
    this.merchant,
    this.isApplyTax,
    this.checkoutStats,
    this.hasAddressbook,
    this.services,
    this.transactionType,
    this.defaultDeliveryDate,
    this.defaultDeliveryDatePretty,
    this.requiredDeliveryTime,
    this.optContactDelivery,
    this.tipList,
    this.data,
    this.cartDetails,
    this.cartError,
    this.pointsEnabled,
    this.pointsEarn,
    this.ptsLabelEarn,
    this.availablePoints,
    this.availablePointsLabel,
    this.ptsDisabledRedeem,
    this.merchantSettings,
    this.paymentListCount,
    this.paymentList,
  });

  Merchant merchant;
  int isApplyTax;
  CheckoutStats checkoutStats;
  int hasAddressbook;
  Services services;
  String transactionType;
  DateTime defaultDeliveryDate;
  String defaultDeliveryDatePretty;
  String requiredDeliveryTime;
  String optContactDelivery;
  TipList tipList;
  Data data;
  CartDetails cartDetails;
  List<dynamic> cartError;
  String pointsEnabled;
  String pointsEarn;
  String ptsLabelEarn;
  int availablePoints;
  String availablePointsLabel;
  String ptsDisabledRedeem;
  MerchantSettings merchantSettings;
  int paymentListCount;
  List<dynamic> paymentList;

  factory CartModelDetails.fromJson(Map<String, dynamic> json) => CartModelDetails(
        merchant: Merchant.fromJson(json["merchant"]),
        isApplyTax: json["is_apply_tax"],
        checkoutStats: CheckoutStats.fromJson(json["checkout_stats"]),
        hasAddressbook: json["has_addressbook"],
        services: Services.fromJson(json["services"]),
        transactionType: json["transaction_type"],
        defaultDeliveryDate: DateTime.parse(json["default_delivery_date"]),
        defaultDeliveryDatePretty: json["default_delivery_date_pretty"],
        requiredDeliveryTime: json["required_delivery_time"],
        optContactDelivery: json["opt_contact_delivery"],
        tipList: TipList.fromJson(json["tip_list"]),
        data: Data.fromJson(json["data"]),
        cartDetails: CartDetails.fromJson(json["cart_details"]),
        cartError: List<dynamic>.from(json["cart_error"].map((x) => x)),
        pointsEnabled: json["points_enabled"],
        pointsEarn: json["points_earn"],
        ptsLabelEarn: json["pts_label_earn"],
        availablePoints: json["available_points"],
        availablePointsLabel: json["available_points_label"],
        ptsDisabledRedeem: json["pts_disabled_redeem"],
        merchantSettings: MerchantSettings.fromJson(json["merchant_settings"]),
        paymentListCount: json["payment_list_count"],
        paymentList: List<dynamic>.from(json["payment_list"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "merchant": merchant.toJson(),
        "is_apply_tax": isApplyTax,
        "checkout_stats": checkoutStats.toJson(),
        "has_addressbook": hasAddressbook,
        "services": services.toJson(),
        "transaction_type": transactionType,
        "default_delivery_date":
            "${defaultDeliveryDate.year.toString().padLeft(4, '0')}-${defaultDeliveryDate.month.toString().padLeft(2, '0')}-${defaultDeliveryDate.day.toString().padLeft(2, '0')}",
        "default_delivery_date_pretty": defaultDeliveryDatePretty,
        "required_delivery_time": requiredDeliveryTime,
        "opt_contact_delivery": optContactDelivery,
        "tip_list": tipList.toJson(),
        "data": data.toJson(),
        "cart_details": cartDetails.toJson(),
        "cart_error": List<dynamic>.from(cartError.map((x) => x)),
        "points_enabled": pointsEnabled,
        "points_earn": pointsEarn,
        "pts_label_earn": ptsLabelEarn,
        "available_points": availablePoints,
        "available_points_label": availablePointsLabel,
        "pts_disabled_redeem": ptsDisabledRedeem,
        "merchant_settings": merchantSettings.toJson(),
        "payment_list_count": paymentListCount,
        "payment_list": List<dynamic>.from(paymentList.map((x) => x)),
      };
}

class CartDetails {
  CartDetails({
    this.merchantId,
    this.devicePlatform,
    this.cartCount,
    this.voucherDetails,
    this.street,
    this.city,
    this.state,
    this.zipcode,
    this.deliveryInstruction,
    this.locationName,
    this.contactPhone,
    this.dateModified,
    this.tips,
    this.pointsEarn,
    this.pointsApply,
    this.pointsAmount,
    this.countryCode,
    this.deliveryFee,
    this.minDeliveryOrder,
    this.deliveryLat,
    this.deliveryLong,
    this.saveAddress,
    this.distance,
    this.distanceUnit,
    this.stateId,
    this.cityId,
    this.areaId,
    this.cartSubtotal,
    this.removeTip,
  });

  String merchantId;
  String devicePlatform;
  String cartCount;
  dynamic voucherDetails;
  String street;
  String city;
  String state;
  String zipcode;
  String deliveryInstruction;
  String locationName;
  String contactPhone;
  DateTime dateModified;
  String tips;
  String pointsEarn;
  String pointsApply;
  String pointsAmount;
  String countryCode;
  String deliveryFee;
  String minDeliveryOrder;
  String deliveryLat;
  String deliveryLong;
  String saveAddress;
  String distance;
  String distanceUnit;
  String stateId;
  String cityId;
  String areaId;
  String cartSubtotal;
  String removeTip;

  factory CartDetails.fromJson(Map<String, dynamic> json) => CartDetails(
        merchantId: json["merchant_id"],
        devicePlatform: json["device_platform"],
        cartCount: json["cart_count"],
        voucherDetails: json["voucher_details"],
        street: json["street"],
        city: json["city"],
        state: json["state"],
        zipcode: json["zipcode"],
        deliveryInstruction: json["delivery_instruction"],
        locationName: json["location_name"],
        contactPhone: json["contact_phone"],
        dateModified: DateTime.parse(json["date_modified"]),
        tips: json["tips"],
        pointsEarn: json["points_earn"],
        pointsApply: json["points_apply"],
        pointsAmount: json["points_amount"],
        countryCode: json["country_code"],
        deliveryFee: json["delivery_fee"],
        minDeliveryOrder: json["min_delivery_order"],
        deliveryLat: json["delivery_lat"],
        deliveryLong: json["delivery_long"],
        saveAddress: json["save_address"],
        distance: json["distance"],
        distanceUnit: json["distance_unit"],
        stateId: json["state_id"],
        cityId: json["city_id"],
        areaId: json["area_id"],
        cartSubtotal: json["cart_subtotal"],
        removeTip: json["remove_tip"],
      );

  Map<String, dynamic> toJson() => {
        "merchant_id": merchantId,
        "device_platform": devicePlatform,
        "cart_count": cartCount,
        "voucher_details": voucherDetails,
        "street": street,
        "city": city,
        "state": state,
        "zipcode": zipcode,
        "delivery_instruction": deliveryInstruction,
        "location_name": locationName,
        "contact_phone": contactPhone,
        "date_modified": dateModified.toIso8601String(),
        "tips": tips,
        "points_earn": pointsEarn,
        "points_apply": pointsApply,
        "points_amount": pointsAmount,
        "country_code": countryCode,
        "delivery_fee": deliveryFee,
        "min_delivery_order": minDeliveryOrder,
        "delivery_lat": deliveryLat,
        "delivery_long": deliveryLong,
        "save_address": saveAddress,
        "distance": distance,
        "distance_unit": distanceUnit,
        "state_id": stateId,
        "city_id": cityId,
        "area_id": areaId,
        "cart_subtotal": cartSubtotal,
        "remove_tip": removeTip,
      };
}

class CheckoutStats {
  CheckoutStats({
    this.code,
    this.msg,
    this.button,
    this.holiday,
    this.isPreOrder,
  });

  int code;
  String msg;
  String button;
  int holiday;
  int isPreOrder;

  factory CheckoutStats.fromJson(Map<String, dynamic> json) => CheckoutStats(
        code: json["code"],
        msg: json["msg"],
        button: json["button"],
        holiday: json["holiday"],
        isPreOrder: json["is_pre_order"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "msg": msg,
        "button": button,
        "holiday": holiday,
        "is_pre_order": isPreOrder,
      };
}

class Data {
  Data({
    this.item,
    this.total,
  });

  List<CartItemList> item;
  CartTotal total;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        item: List<CartItemList>.from(
            json["item"].map((x) => CartItemList.fromJson(x))),
        total: CartTotal.fromJson(json["total"]),
      );

  Map<String, dynamic> toJson() => {
        "item": List<dynamic>.from(item.map((x) => x.toJson())),
        "total": total.toJson(),
      };
}

class CartItemList {
  CartItemList({
    this.itemId,
    this.itemName,
    this.sizeWords,
    this.sizeId,
    this.qty,
    this.normalPrice,
    this.discountedPrice,
    this.discount,
    this.orderNotes,
    this.cookingRef,
    this.ingredients,
    this.nonTaxable,
    this.categoryId,
    this.categoryName,
    this.categoryNameTrans,
    this.itemNameTrans,
    this.sizeNameTrans,
    this.cookingNameTrans,
  });

  String itemId;
  String itemName;
  String sizeWords;
  int sizeId;
  int qty;
  String normalPrice;
  String discountedPrice;
  String discount;
  String orderNotes;
  String cookingRef;
  String ingredients;
  String nonTaxable;
  String categoryId;
  String categoryName;
  CategoryNameTrans categoryNameTrans;
  ItemNameTrans itemNameTrans;
  String sizeNameTrans;
  String cookingNameTrans;

  factory CartItemList.fromJson(Map<String, dynamic> json) => CartItemList(
        itemId: json["item_id"],
        itemName: json["item_name"],
        sizeWords: json["size_words"],
        sizeId: json["size_id"],
        qty: json["qty"],
        normalPrice: json["normal_price"],
        discountedPrice: json["discounted_price"],
        discount: json["discount"],
        orderNotes: json["order_notes"],
        cookingRef: json["cooking_ref"],
        ingredients: json["ingredients"],
        nonTaxable: json["non_taxable"],
        categoryId: json["category_id"],
        categoryName: json["category_name"],
        categoryNameTrans:
            CategoryNameTrans.fromJson(json["category_name_trans"]),
        itemNameTrans: ItemNameTrans.fromJson(json["item_name_trans"]),
        sizeNameTrans: json["size_name_trans"],
        cookingNameTrans: json["cooking_name_trans"],
      );

  Map<String, dynamic> toJson() => {
        "item_id": itemId,
        "item_name": itemName,
        "size_words": sizeWords,
        "size_id": sizeId,
        "qty": qty,
        "normal_price": normalPrice,
        "discounted_price": discountedPrice,
        "discount": discount,
        "order_notes": orderNotes,
        "cooking_ref": cookingRef,
        "ingredients": ingredients,
        "non_taxable": nonTaxable,
        "category_id": categoryId,
        "category_name": categoryName,
        "category_name_trans": categoryNameTrans.toJson(),
        "item_name_trans": itemNameTrans.toJson(),
        "size_name_trans": sizeNameTrans,
        "cooking_name_trans": cookingNameTrans,
      };
}

class CategoryNameTrans {
  CategoryNameTrans({
    this.categoryNameTrans,
  });

  NameTrans categoryNameTrans;

  factory CategoryNameTrans.fromJson(Map<String, dynamic> json) =>
      CategoryNameTrans(
        categoryNameTrans: NameTrans.fromJson(json["category_name_trans"]),
      );

  Map<String, dynamic> toJson() => {
        "category_name_trans": categoryNameTrans.toJson(),
      };
}

class NameTrans {
  NameTrans({
    this.english,
    this.trke,
    this.empty,
  });

  String english;
  String trke;
  String empty;

  factory NameTrans.fromJson(Map<String, dynamic> json) => NameTrans(
        english: json["English"],
        trke: json["Türkçe"],
        empty: json["العربية"],
      );

  Map<String, dynamic> toJson() => {
        "English": english,
        "Türkçe": trke,
        "العربية": empty,
      };
}

class ItemNameTrans {
  ItemNameTrans({
    this.itemNameTrans,
  });

  NameTrans itemNameTrans;

  factory ItemNameTrans.fromJson(Map<String, dynamic> json) => ItemNameTrans(
        itemNameTrans: NameTrans.fromJson(json["item_name_trans"]),
      );

  Map<String, dynamic> toJson() => {
        "item_name_trans": itemNameTrans.toJson(),
      };
}

class CartTotal {
  CartTotal({
    this.subtotal,
    this.taxableTotal,
    this.deliveryCharges,
    this.total,
    this.tax,
    this.taxAmt,
    this.curr,
    this.mid,
    this.discountedAmount,
    this.merchantDiscountAmount,
    this.merchantPackagingCharge,
    this.lessVoucher,
    this.voucherType,
    this.tips,
    this.tipsPercent,
    this.cartTipPercentage,
    this.ptsRedeemAmt,
    this.voucherValue,
    this.voucherTypes,
    this.calculationMethod,
    this.ptsRedeemAmtOrig,
    this.lessVoucherOrig,
  });

  int subtotal;
  int taxableTotal;
  int deliveryCharges;
  int total;
  String tax;
  String taxAmt;
  String curr;
  String mid;
  int discountedAmount;
  int merchantDiscountAmount;
  String merchantPackagingCharge;
  int lessVoucher;
  String voucherType;
  String tips;
  String tipsPercent;
  String cartTipPercentage;
  int ptsRedeemAmt;
  String voucherValue;
  String voucherTypes;
  int calculationMethod;
  int ptsRedeemAmtOrig;
  int lessVoucherOrig;

  factory CartTotal.fromJson(Map<String, dynamic> json) => CartTotal(
        subtotal: json["subtotal"],
        taxableTotal: json["taxable_total"],
        deliveryCharges: json["delivery_charges"],
        total: json["total"],
        tax: json["tax"],
        taxAmt: json["tax_amt"],
        curr: json["curr"],
        mid: json["mid"],
        discountedAmount: json["discounted_amount"],
        merchantDiscountAmount: json["merchant_discount_amount"],
        merchantPackagingCharge: json["merchant_packaging_charge"],
        lessVoucher: json["less_voucher"],
        voucherType: json["voucher_type"],
        tips: json["tips"],
        tipsPercent: json["tips_percent"],
        cartTipPercentage: json["cart_tip_percentage"],
        ptsRedeemAmt: json["pts_redeem_amt"],
        voucherValue: json["voucher_value"],
        voucherTypes: json["voucher_types"],
        calculationMethod: json["calculation_method"],
        ptsRedeemAmtOrig: json["pts_redeem_amt_orig"],
        lessVoucherOrig: json["less_voucher_orig"],
      );

  Map<String, dynamic> toJson() => {
        "subtotal": subtotal,
        "taxable_total": taxableTotal,
        "delivery_charges": deliveryCharges,
        "total": total,
        "tax": tax,
        "tax_amt": taxAmt,
        "curr": curr,
        "mid": mid,
        "discounted_amount": discountedAmount,
        "merchant_discount_amount": merchantDiscountAmount,
        "merchant_packaging_charge": merchantPackagingCharge,
        "less_voucher": lessVoucher,
        "voucher_type": voucherType,
        "tips": tips,
        "tips_percent": tipsPercent,
        "cart_tip_percentage": cartTipPercentage,
        "pts_redeem_amt": ptsRedeemAmt,
        "voucher_value": voucherValue,
        "voucher_types": voucherTypes,
        "calculation_method": calculationMethod,
        "pts_redeem_amt_orig": ptsRedeemAmtOrig,
        "less_voucher_orig": lessVoucherOrig,
      };
}

class Merchant {
  Merchant({
    this.restaurantName,
    this.rating,
    this.backgroundUrl,
  });

  String restaurantName;
  int rating;
  String backgroundUrl;

  factory Merchant.fromJson(Map<String, dynamic> json) => Merchant(
        restaurantName: json["restaurant_name"],
        rating: json["rating"],
        backgroundUrl: json["background_url"],
      );

  Map<String, dynamic> toJson() => {
        "restaurant_name": restaurantName,
        "rating": rating,
        "background_url": backgroundUrl,
      };
}

class MerchantSettings {
  MerchantSettings({
    this.orderVerification,
    this.enabledVoucher,
    this.enabledTip,
    this.tipDefault,
  });

  String orderVerification;
  String enabledVoucher;
  String enabledTip;
  String tipDefault;

  factory MerchantSettings.fromJson(Map<String, dynamic> json) =>
      MerchantSettings(
        orderVerification: json["order_verification"],
        enabledVoucher: json["enabled_voucher"],
        enabledTip: json["enabled_tip"],
        tipDefault: json["tip_default"],
      );

  Map<String, dynamic> toJson() => {
        "order_verification": orderVerification,
        "enabled_voucher": enabledVoucher,
        "enabled_tip": enabledTip,
        "tip_default": tipDefault,
      };
}

class Services {
  Services({
    this.delivery,
    this.pickup,
  });

  String delivery;
  String pickup;

  factory Services.fromJson(Map<String, dynamic> json) => Services(
        delivery: json["delivery"],
        pickup: json["pickup"],
      );

  Map<String, dynamic> toJson() => {
        "delivery": delivery,
        "pickup": pickup,
      };
}

class TipList {
  TipList({
    this.the01,
    this.the015,
    this.the02,
    this.the025,
  });

  String the01;
  String the015;
  String the02;
  String the025;

  factory TipList.fromJson(Map<String, dynamic> json) => TipList(
        the01: json["0.1"],
        the015: json["0.15"],
        the02: json["0.2"],
        the025: json["0.25"],
      );

  Map<String, dynamic> toJson() => {
        "0.1": the01,
        "0.15": the015,
        "0.2": the02,
        "0.25": the025,
      };
}

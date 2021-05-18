import 'dart:convert';

import 'package:afandim/custom_widget/help/checkbox_list.dart';
import 'package:afandim/custom_widget/help/radio_list.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/utils.dart';
import 'package:flutter/material.dart';

class FilterBy extends StatefulWidget {
  final Map filterData;
  final bool isfromService;

  FilterBy({Key key, this.filterData, this.isfromService = false})
      : super(key: key);

  @override
  _FilterByState createState() => _FilterByState();
}

class _FilterByState extends State<FilterBy> {
  List<Map<String, dynamic>> deliveryFee = [];
  List<Map<String, dynamic>> promos = [];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> minimumOrder = [];
  List<Map<String, dynamic>> cuisine = [];

  String deliveryFeeValue = "";
  String promosValue = "";
  String minimumOrderValue = "";
  Map<String, bool> selectedServices = {};
  Map<String, bool> selectedCuisine = {};

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    List temp = lang.settings["filters"]["cuisine"];
    temp.forEach((element) {
      String name =
          json.decode(element["cuisine_name_trans"])[lang.getLanguageText()];
      if (name.isNotEmpty) {
        element["cuisine_name"] = name;
      }
      cuisine.add(element);
    });

    if (widget.filterData != null && widget.filterData.isNotEmpty) {
      deliveryFeeValue = widget.filterData["delivery_fee"];
      promosValue = widget.filterData["promos"];
      minimumOrderValue = widget.filterData["minimum_order"];
      selectedServices = widget.filterData["selected_services"];
      selectedCuisine = widget.filterData["selected_cuisine"];
    }
    setState(() {
      deliveryFee = getListFromMap(lang.settings["filters"]["delivery_fee"]);
      promos = getListFromMap(lang.settings["filters"]["promos"]);
      services = getListFromMap(lang.settings["filters"]["services"]);
      minimumOrder = getListFromMap(lang.settings["filters"]["minimum_order"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.api("Filter By")),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return buildBody();
  }

  Widget getTop() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            lang.api("Filter By"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 16),
          InkWell(
            child: Container(
              child: Text(
                lang.api("CLEAR"),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
  }

  Widget getBottom() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop({
          "delivery_fee": deliveryFeeValue,
          "promos": promosValue,
          "minimum_order": minimumOrderValue,
          "selected_services": selectedServices,
          "selected_cuisine": selectedCuisine
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.all(16),
        child: Text(
          lang.api("Confirm"),
          style: TextStyle(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: Container(
            child: ListView(
              children: [
                getTop(),
                getTitleWidget(lang.api("Delivery Fee")),
                getDeliveryFeeList(),
                getTitleWidget(lang.api("PROMOS")),
                getPromos(),
                getTitleWidget(lang.api("By Services")),
                getServices(),
                widget.isfromService
                    ? Container()
                    : getTitleWidget(lang.api("By Cuisine")),
                widget.isfromService ? Container() : getCuisine(),
                getTitleWidget(lang.api("Minimum order")),
                getMinimumOrder(),
              ],
            ),
          ),
        ),
        Container(
          child: getBottom(),
        ),
      ],
    );
  }

  Widget getTitleWidget(String title) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget getCuisine() {
    return CheckboxList(
      list: cuisine,
      selectedValues: selectedCuisine,
      idKey: "cuisine_id",
      labelKey: "cuisine_name",
      onSelect: (selectedValues) {
        selectedCuisine = selectedValues;
      },
    );
  }

  Widget getMinimumOrder() {
    return RadioList(
      list: minimumOrder,
      selectedValue: minimumOrderValue,
      onSelect: (item) {
        minimumOrderValue = item["id"];
      },
    );
  }

  Widget getServices() {
    return CheckboxList(
      list: services,
      selectedValues: selectedServices,
      onSelect: (selectedValues) {
        selectedServices = selectedValues;
      },
    );
  }

  Widget getPromos() {
    return RadioList(
      list: promos,
      selectedValue: promosValue,
      onSelect: (item) {
        promosValue = item["id"];
      },
    );
  }

  Widget getDeliveryFeeList() {
    return RadioList(
      list: deliveryFee,
      selectedValue: deliveryFeeValue,
      onSelect: (item) {
        deliveryFeeValue = item["id"];
      },
    );
  }
}

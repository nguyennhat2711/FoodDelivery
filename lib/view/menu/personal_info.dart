import 'dart:convert';

import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_dropdown_list.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/help/checkbox_list.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/auth/login/phone_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonalInfo extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Map<String, dynamic> request;

  PersonalInfo({Key key, @required this.onComplete, this.request})
      : super(key: key);

  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final restaurantNameController = TextEditingController();
  final restaurantPhoneController = TextEditingController();
  final contactNameController = TextEditingController();
  final contactEmailController = TextEditingController();

  final restaurantNameFocusNode = new FocusNode();
  final restaurantPhoneFocusNode = new FocusNode();
  final contactNameFocusNode = new FocusNode();
  final contactEmailFocusNode = new FocusNode();

  String errorMessage = "";
  String countryCode = "1";

  Map<String, bool> selectedCuisine = {};
  Map serviceController;
  List<Map<String, dynamic>> cuisines = [];
  List services = [
    {"id": "1", "name": lang.api("Delivery & Pick Up")},
    {"id": "2", "name": lang.api("Delivery only")},
    {"id": "3", "name": lang.api("Pick Up only")},
    {
      "id": "4",
      "name": lang.api("Delivery / Pickup / Serve at Business Location")
    },
    {"id": "5", "name": lang.api("Delivery & Serve at Business Location")},
    {"id": "6", "name": lang.api("Pickup & Serve at Business Location")},
    {"id": "7", "name": lang.api("Serve at Business Location only")},
  ];

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  init() async {
    List temp = lang.settings["filters"]["cuisine"];
    temp.forEach((element) {
      String name =
          json.decode(element["cuisine_name_trans"])[lang.getLanguageText()];
      if (name.isNotEmpty) {
        element["cuisine_name"] = name;
      }
      cuisines.add(element);
    });

    serviceController = services[0];
    setState(() {
      countryCode =
          lang.settings["mobile_prefix"].toString().replaceAll("+", "");
    });
    if (widget.request != null) {
      restaurantNameController.text = widget.request["restaurant_name"] ?? "";
      restaurantPhoneController.text = widget.request["restaurant_phone"] ?? "";
      contactNameController.text = widget.request["contact_name"] ?? "";
      contactEmailController.text = widget.request["contact_email"] ?? "";
//
//
      if (restaurantPhoneController.text.isNotEmpty) {
        countryCode = widget.request["restaurant_code"] ?? "";
        restaurantPhoneController.text =
            restaurantPhoneController.text.replaceFirst(countryCode, "");
      }
      services.forEach((element) {
        if (element["id"] == widget.request["service"]) {
          serviceController = element;
        }
      });
      selectedCuisine = widget.request["cuisine"] ?? {};
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, right: 16, left: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AlternativeTextField(
              focusNode: restaurantNameFocusNode,
              controller: restaurantNameController,
              textInputAction: TextInputAction.done,
              hint: lang.api("Business Name"),
              prefix: SvgPicture.asset(
                "assets/icons/user.svg",
                color: Colors.grey,
                width: 24,
              ),
            ),
            GestureDetector(
              onTap: () async {
                var result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return PhoneSelector(
                      countryCode: countryCode,
                      phone: restaurantPhoneController.text,
                    );
                  }),
                );
                if (result != null && result is Map) {
                  setState(() {
                    restaurantPhoneController.text = result["phone"];
                    countryCode = result["countryCode"];
                  });
                }
              },
              child: AlternativeTextField(
                controller: restaurantPhoneController,
                enabled: false,
                hint: lang.api("Business Phone"),
                keyboardType: TextInputType.phone,
                isPhoneNumber: true,
                prefix: SvgPicture.asset(
                  "assets/icons/mobile.svg",
                  color: Colors.grey,
                  width: 24,
                ),
              ),
            ),
            AlternativeTextField(
              controller: contactNameController,
              focusNode: contactNameFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (text) {
                FocusScope.of(context).requestFocus(contactEmailFocusNode);
              },
              hint: lang.api("Contact Name"),
              prefix: SvgPicture.asset(
                "assets/icons/user.svg",
                color: Colors.grey,
                width: 24,
              ),
            ),
            AlternativeTextField(
              controller: contactEmailController,
              focusNode: contactEmailFocusNode,
              textInputAction: TextInputAction.done,
              hint: lang.api("Contact Email"),
              keyboardType: TextInputType.emailAddress,
              prefix: SvgPicture.asset(
                "assets/icons/mail.svg",
                color: Colors.grey,
                width: 24,
              ),
            ),
            AlternativeDropdownList(
              key: Key("service"),
              displayLabel: "name",
              selectedKey: "id",
              selectedId: serviceController == null
                  ? services[0]["id"]
                  : serviceController["id"],
              labels: services,
              onChange: (item) {
//                print("Selected : 0000 $item");
                setState(() {
                  serviceController = item;
                });
              },
            ),
            SizedBox(height: 8),
            Text(
              lang.api("Service Category"),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            CheckboxList(
              list: cuisines,
              selectedValues: selectedCuisine,
              idKey: "cuisine_id",
              labelKey: "cuisine_name",
              twoColumns: true,
              onSelect: (selectedValues) {
                selectedCuisine = selectedValues;
              },
            ),
            errorMessage.isEmpty
                ? Container()
                : Row(
                    children: <Widget>[
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
            AlternativeButton(
              label: lang.api("Submit"),
              onPressed: () {
                if (restaurantNameController.text.isEmpty) {
                  errorMessage = lang.api("Business name is required");
//                } else if(restaurantPhoneController.text.isEmpty){
//                  errorMessage = lang.api("Business phone is required");

                } else if (contactNameController.text.isEmpty) {
                  errorMessage = lang.api("Contact name is required");
                } else if (selectedCuisine.isEmpty) {
                  errorMessage =
                      lang.api("Select at lease one Service Category");
                } else {
                  Map<String, dynamic> request = {
                    "restaurant_name": restaurantNameController.text,
                    "restaurant_code": countryCode,
                    "restaurant_phone":
                        "+$countryCode" + restaurantPhoneController.text,
                    "contact_name": contactNameController.text,
                    "contact_email": contactEmailController.text,
                    "country_code": "TR",
                    "contact_phone":
                        "+$countryCode${restaurantPhoneController.text}",
                    "contact_code": "$countryCode",
                    "service": serviceController["id"],
                  };
                  if (selectedCuisine.isNotEmpty) {
                    List temp = [];
                    selectedCuisine.keys.toList().forEach((key) {
                      bool selected = selectedCuisine[key];
                      if (selected) {
                        temp.add(key);
                      }
                    });
                    request["cuisine"] = temp;
                  }

                  widget.onComplete(request);
                  return;
                }
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

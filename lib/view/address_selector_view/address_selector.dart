import 'dart:convert';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_dropdown_list.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/divider_middle_text.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/auth/login/phone_selector.dart';
import 'package:afandim/view/profile/address_directory/add.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddressSelector extends StatefulWidget {
  @override
  _AddressSelectorState createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  final _repo = Repository();
  final _prefManager = PrefManager();
  final phoneController = TextEditingController();
  final deliveryController = TextEditingController();
  Map address = {"id": "0"};
  String countryCode = "";
  bool isLoading = true;
  List list = [];
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      isLoading = true;
      list = [
        {"address": lang.api("loading"), "id": "0"}
      ];
      countryCode =
          lang.settings["mobile_prefix"].toString().replaceAll("+", "");
    });
    String x = await _prefManager.get("countryCode", "");
    if (x.isNotEmpty) {
      countryCode = x;
    }
    var phone = await _prefManager.get("phone", "");
    if (await _prefManager.contains("user.data")) {
      Map userData = json.decode(await _prefManager.get("user.data", "{}"));
      countryCode = userData["contact_phone"].toString().substring(1, 3);
      phone = userData["contact_phone"].toString().substring(3);
    }
    phoneController.text = phone;

    Map<String, dynamic> response = await _repo.getAddressBookDropDown();
    isLoading = false;
    if (response.containsKey("code") && response["code"] == 1) {
      list = response["details"]["data"];
      address = list[0];
    }
    setState(() {});
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      scaffoldKey: _scaffoldKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Card(
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text(
                    lang.api("Delivery Address"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    lang.api("What address would you like to receive?"),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  AlternativeDropdownList(
                    key: UniqueKey(),
                    prefix: SvgPicture.asset(
                      "assets/icons/home.svg",
                      color: Colors.grey,
                      width: 24,
                    ),
                    displayLabel: "location_name",
                    selectedKey: "id",
                    selectedId: address["id"],
                    labels: list,
                    onChange: (item) {
                      print(item);
                      setState(() {
                        address = item;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () async {
                      var result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return PhoneSelector(
                            countryCode: countryCode,
                            phone: "",
                          );
                        }),
                      );
                      if (result != null && result is Map) {
                        setState(() {
                          phoneController.text = result["phone"];
                          countryCode = result["countryCode"];
                        });
                      }
                    },
                    child: AlternativeTextField(
                      controller: phoneController,
                      enabled: false,
                      hint: lang.api("Mobile"),
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
                    hint: lang.api("Delivery instructions"),
                    controller: deliveryController,
                    textInputAction: TextInputAction.done,
                    prefix: SvgPicture.asset(
                      "assets/icons/car.svg",
                      color: Colors.grey,
                      width: 24,
                    ),
                  ),
                  AlternativeButton(
                    label: lang.api("Submit"),
                    onPressed: () async {
                      if (address["id"] == "0") {
                        showError(lang.api("Select address please"));
//                      } else if(deliveryController.text.isEmpty){
//                        showError(lang.api("Delivery instructions required"));
                      } else if (phoneController.text.isEmpty) {
                        showError(lang.api("Phone number required"));
                      } else {
                        showLoadingDialog();
                        await _prefManager.set("countryCode", countryCode);
                        await _prefManager.set("phone", phoneController.text);
                        Map<String, dynamic> response =
                            await _repo.setAddressBook({
                          "delivery_instruction": deliveryController.text,
                          "contact_phone":
                              "+$countryCode" + phoneController.text,
                          "addressbook_id": address["id"],
                        });
                        Navigator.of(context).pop();
                        if (response.containsKey("code") &&
                            response["code"] == 1) {
                          Navigator.of(context).pop(true);
                        } else {
                          showError(response["msg"]);
                        }
                      }
                    },
                  ),
                  DividerMiddleText(
                    text: lang.api("Or"),
                  ),
                  AlternativeButton(
                    label: lang.api("Add New Address"),
                    color: Colors.grey,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return AddAddressDirectory(
                            fromOrder: true,
                          );
                        }),
                      );
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  showError(message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

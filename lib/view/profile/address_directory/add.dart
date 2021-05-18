import 'package:afandim/core/services/repository.dart';
import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/auth/login/phone_selector.dart';
import 'package:afandim/view/helper/maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddAddressDirectory extends StatefulWidget {
  final bool fromOrder;

  AddAddressDirectory({
    Key key,
    this.fromOrder = false,
  }) : super(key: key);

  @override
  _AddAddressDirectoryState createState() => _AddAddressDirectoryState();
}

class _AddAddressDirectoryState extends State<AddAddressDirectory> {
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _locationController = TextEditingController();
  Map locationMap;
  final _repo = Repository();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String countryCode = "1";
  bool check = false;
  final _prefManager = PrefManager();

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    setState(() {
      countryCode =
          lang.settings["mobile_prefix"].toString().replaceAll("+", "");
    });
    String x = await _prefManager.get("countryCode", "");
    if (x.isNotEmpty) {
      countryCode = x;
    }
    _contactPhoneController.text = await _prefManager.get("phone", "");
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
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text(
                    lang.api("Add New Address"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () async {
                      var result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return Maps(
                            currentLocation: locationMap,
                          );
                        }),
                      );
                      if (result != null) {
                        _locationController.text = result["result"]["name"];
                        _cityController.text = result["result"]["city"];
                        _stateController.text = result["result"]["state"];
                        _streetController.text = result["result"]["street"];
                        locationMap = result["location"];
                      }
                    },
                    child: AlternativeTextField(
                      controller: _locationController,
                      enabled: false,
                      prefix: Icon(
                        Icons.map,
                        color: Theme.of(context).primaryColor,
                      ),
                      fontColor: Colors.grey,
                      hint: lang.api("Location on Map"),
                    ),
                  ),
                  AlternativeTextField(
                    controller: _streetController,
                    hint: lang.api("Street"),
                  ),
                  AlternativeTextField(
                    controller: _stateController,
                    hint: lang.api("Building no"),
                  ),
                  AlternativeTextField(
                    controller: _cityController,
                    hint: lang.api("Floor"),
                  ),
                  widget.fromOrder
                      ? AlternativeTextField(
                          controller: _deliveryController,
                          hint: lang.api("Delivery instructions"),
                        )
                      : Container(),
                  widget.fromOrder
                      ? Row(
                          children: <Widget>[
                            Checkbox(
                              value: check,
                              onChanged: (value) {
                                setState(() {
                                  check = !check;
                                });
                              },
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    check = !check;
                                  });
                                },
                                child: Text(
                                  lang.api("Save to my address book"),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  widget.fromOrder
                      ? GestureDetector(
                          onTap: () async {
                            var result = await Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return PhoneSelector(
                                  countryCode: countryCode,
                                  phone: _contactPhoneController.text,
                                );
                              }),
                            );
                            if (result != null && result is Map) {
                              setState(() {
                                _contactPhoneController.text = result["phone"];
                                countryCode = result["countryCode"];
                              });
                              await _prefManager.set(
                                  "countryCode", countryCode);
                              await _prefManager.set(
                                  "phone", _contactPhoneController.text);
                            }
                          },
                          child: AlternativeTextField(
                            controller: _contactPhoneController,
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
                        )
                      : Container(),
                  AlternativeButton(
                    label: lang.api("Save"),
                    onPressed: () async {
                      showLoadingDialog();
                      Map<String, dynamic> response = {};
                      String cCode = "JO";
                      final provider = context.read(generalProvider);
                      if (provider.apiUrl.contains("tr.efendim.biz")) {
                        cCode = "TR";
                      }
                      if (widget.fromOrder) {
                        response = await _repo.setDeliveryAddress({
                          "street": _streetController.text,
                          "city": _cityController.text,
                          "state": _stateController.text,
                          "save_address": check ? 1 : 0,
                          "contact_phone":
                              "+$countryCode" + _contactPhoneController.text,
                          "delivery_instruction": _deliveryController.text,
                          "zipcode": _zipCodeController.text,
                          "country_code": cCode,
                          "lat": locationMap["latitude"],
                          "lng": locationMap["longitude"],
                          "location_name": _locationController.text
                        });
                      } else {
                        response = await _repo.saveAddressBook({
                          "street": _streetController.text,
                          "city": _cityController.text,
                          "state": _stateController.text,
                          "zipcode": _zipCodeController.text,
                          "country_code": cCode,
                          "lat": locationMap["latitude"],
                          "lng": locationMap["longitude"],
                          "location_name": _locationController.text
                        });
                      }
                      Navigator.of(context).pop();
                      if (response.containsKey("code") &&
                          response["code"] == 1) {
                        Navigator.of(context).pop();
                      } else {
                        showError(_scaffoldKey, response["msg"]);
                      }
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
}

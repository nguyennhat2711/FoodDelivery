import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_dropdown_list.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/helper/config.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/utils.dart';
import 'package:afandim/view/auth/login/phone_selector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterDelivery extends StatefulWidget {
  @override
  _RegisterDeliveryState createState() => _RegisterDeliveryState();
}

class _RegisterDeliveryState extends State<RegisterDelivery> {
  final _repository = Repository();
  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final transportDescriptionController = TextEditingController();
  final licensePlateController = TextEditingController();
  final colorController = TextEditingController();
  Map typeController = {"id": ""};
  List labels;
  String countryCode = "1";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  init() async {
    labels = [];
    lang.settings["addon"]["driver_transport"].forEach((key, value) {
      labels.add({
        "id": key,
        "name": lang.api(value),
        "icon": lang.settings["icons"][key] != null
            ? CachedNetworkImage(
                imageUrl: lang.settings["icons"][key],
                fit: BoxFit.contain,
                width: 24,
                height: 24,
              )
            : null,
      });
    });
    setState(() {
      countryCode =
          lang.settings["mobile_prefix"].toString().replaceAll("+", "");
    });
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    "assets/images/logo-delivary.png",
                    scale: 2,
                    width: 120,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    lang.api("Be a deliveyman"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    lang.api("Start earning today"),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16.0),
                  AlternativeTextField(
                    controller: firstNameController,
                    hint: lang.api("First Name"),
                    prefix: SvgPicture.asset(
                      "assets/icons/user.svg",
                      color: Colors.grey,
                      width: 24,
                    ),
                  ),
                  AlternativeTextField(
                    controller: lastNameController,
                    hint: lang.api("Last Name"),
                    prefix: SvgPicture.asset(
                      "assets/icons/user.svg",
                      color: Colors.grey,
                      width: 24,
                    ),
                  ),
                  AlternativeTextField(
                    controller: emailController,
                    hint: lang.api("Email"),
                    keyboardType: TextInputType.emailAddress,
                    prefix: SvgPicture.asset(
                      "assets/icons/mail.svg",
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
                            phone: phoneController.text,
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
                  labels == null
                      ? Container()
                      : AlternativeDropdownList(
                          key: UniqueKey(),
                          prefix: typeController["icon"] == null
                              ? SvgPicture.asset(
                                  "assets/icons/dot.svg",
                                  color: Colors.grey,
                                  width: 24,
                                )
                              : Container(),
                          displayLabel: "name",
                          selectedKey: "id",
                          selectedId: typeController["id"],
                          labels: labels,
                          onChange: (item) {
                            setState(() {
                              typeController = item;
                            });
                          },
                        ),
                  AlternativeTextField(
                    controller: usernameController,
                    hint: lang.api("Username"),
                    prefix: SvgPicture.asset(
                      "assets/icons/user.svg",
                      color: Colors.grey,
                      width: 24,
                    ),
                  ),
                  AlternativeTextField(
                    controller: passwordController,
                    hint: lang.api("Password"),
                    isPassword: true,
                    prefix: SvgPicture.asset(
                      "assets/icons/lock.svg",
                      color: Colors.grey,
                      width: 24,
                    ),
                  ),
                  AlternativeTextField(
                    controller: transportDescriptionController,
                    hint: lang.api("Transport Description (Year,Model)"),
                    prefix: SvgPicture.asset(
                      "assets/icons/car.svg",
                      color: Colors.grey,
                      width: 24,
                    ),
                  ),
                  AlternativeTextField(
                    controller: licensePlateController,
                    hint: lang.api("License Plate"),
                    prefix: SvgPicture.asset(
                      "assets/icons/license.svg",
                      color: Colors.grey,
                      width: 24,
                    ),
                  ),
                  AlternativeTextField(
                    controller: colorController,
                    hint: lang.api("Color"),
                    prefix: SvgPicture.asset(
                      "assets/icons/color.svg",
                      color: Colors.grey,
                      width: 24,
                    ),
                  ),
                  AlternativeButton(
                    label: lang.api("Submit"),
                    onPressed: () async {
                      if (validateName(firstNameController.text) != null) {
                        showError(_scaffoldKey,
                            validateName(firstNameController.text));
                      } else if (validateLastName(lastNameController.text) !=
                          null) {
                        showError(_scaffoldKey,
                            validateLastName(lastNameController.text));
                      } else if (validateEmail(emailController.text) != null) {
                        showError(
                            _scaffoldKey, validateEmail(emailController.text));
                      } else if (validateName(phoneController.text) != null) {
                        showError(
                            _scaffoldKey, validateMobile(phoneController.text));
                      } else if (validateUserNAme(usernameController.text) !=
                          null) {
                        showError(_scaffoldKey,
                            validateUserNAme(usernameController.text));
                      } else if (validateTransportDesc(
                              transportDescriptionController.text) !=
                          null) {
                        showError(
                            _scaffoldKey,
                            validateTransportDesc(
                                transportDescriptionController.text));
                      } else if (validateLicence(licensePlateController.text) !=
                          null) {
                        showError(_scaffoldKey,
                            validateLicence(licensePlateController.text));
                      } else if (validateColor(colorController.text) != null) {
                        showError(
                            _scaffoldKey, validateColor(colorController.text));
                      } else if (typeController["id"].length == 0) {
                        showError(_scaffoldKey, 'Kindly select vehicle type');
                      } else {
                        Map<String, dynamic> request = {
                          "first_name": firstNameController.text,
                          "last_name": lastNameController.text,
                          "email": emailController.text,
                          "phone": "$countryCode${phoneController.text}",
                          "transport_type_id": typeController["id"],
                          "username": usernameController.text,
                          "password": passwordController.text,
                          "cpassword": passwordController.text,
                          "transport_description":
                              transportDescriptionController.text,
                          "licence_plate": licensePlateController.text,
                          "color": colorController.text,
                        };
                        showLoadingDialog(lang.api("loading"));
                        Map<String, dynamic> response =
                            await _repository.registerDelivery(request);
                        if (response.containsKey("code") &&
                            response["code"] == 1) {
                          Navigator.of(context).pop();
                          bool contact = await showCustomSuccessDialog(context,
                              title: lang.api("successful"),
                              subtitle: lang
                                  .api("Registration Completed successfully"),
                              isDismissible: false,
                              negative: lang.api("OK"),
                              positive: lang.api("Contact Us"));
                          if (contact) {
                            String url = contactUsRegisterDelivery;
                            if (await canLaunch(url)) {
                              await launch(url);
                            }
                          } else {}
                        } else {
                          Navigator.of(context).pop();
                          showError(_scaffoldKey, response["msg"]);
                        }
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

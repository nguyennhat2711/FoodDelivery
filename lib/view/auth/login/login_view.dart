import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/helper/constance.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/auth/login/login_viewmodel.dart';
import 'package:afandim/view/control_view.dart';
import 'package:afandim/view/profile/language_selector_view.dart';
import 'package:afandim/view/support_chat/support_chat.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPhone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.translate,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        lang.api("Language"),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => LanguageSelector());
                  },
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                ),
                onPressed: () {
                  Get.offAll(() => ControlView());
                },
                child: Text(
                  lang.api("Skip"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/images/logo-sm.png",
                    scale: 2,
                    fit: BoxFit.fitWidth,
                    width: 160,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    lang.api("Sign In"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    lang.api("Log in using your mobile number"),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16.0),
                  Consumer(
                      builder: (BuildContext context, watch, Widget child) {
                    final viewmodel = watch(loginViewModel);
                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              String phone = viewmodel.phoneController.text
                                  .replaceAll(" ", "");
                              if (phone.startsWith("0")) {
                                phone = phone.substring(1);
                              }
                            },
                            child: AlternativeTextField(
                              controller: viewmodel.phoneController,
                              hint: lang.api("Mobile"),
                              keyboardType: TextInputType.phone,
                              isPhoneNumber: true,
                              prefix: CountryCodePicker(
                                onChanged: (country) {
                                  viewmodel.setCode(code: country.toString());
                                },
                                initialSelection: 'TR',
                                favorite: ['+90', 'TR'],
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                padding: EdgeInsets.all(0),
                                flagWidth: 20,
                              ),
                              autoFill: () async {
                                viewmodel.phoneController.text =
                                    await viewmodel.autoFill.hint;
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  Consumer(
                    builder: (context, watch, child) {
                      final viewmodel = watch(loginViewModel);
                      return Column(
                        children: [
                          lang.settings["signup_settings"]
                                      ["enabled_terms_condition"] ==
                                  1
                              ? Row(
                                  children: <Widget>[
                                    Checkbox(
                                      value: viewmodel.agree,
                                      onChanged: (value) {
                                        viewmodel.changeAgreeCondition(
                                            value: value);
                                      },
                                    ),
                                    Row(
                                      children: [
                                        Wrap(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                viewmodel.phoneAddressFocus
                                                    .unfocus();
                                                viewmodel.changeAgreeCondition(
                                                    value: !viewmodel.agree);
                                              },
                                              child: Text(
                                                lang.api("Agree to the"),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                String url = lang.settings[
                                                        "signup_settings"]
                                                    ["terms_url"];
                                                if (await canLaunch(url)) {
                                                  await launch(url);
                                                }
                                              },
                                              child: Text(
                                                lang.api(
                                                    "Terms and conditions"),
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Container(),
                          AlternativeButton(
                            label: lang.api("Continue"),
                            onPressed: viewmodel.handleLogin,
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              /// GO TO SUPPORT CHATTING
              Get.to(() => SupportChat());
            },
            child: Text(
              'Contact Us',
              style: TextStyle(
                  color: primaryColor,
                  decoration: TextDecoration.underline,
                  fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

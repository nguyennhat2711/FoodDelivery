import 'dart:io';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/profile/language_selector_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _repo = Repository();
  final _prefManager = PrefManager();
  String version = "";
  bool enableNotifications;
  bool isLogin = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    isLogin = await _prefManager.contains("token");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });

    if (isLogin) {
      Map<String, dynamic> response = await _repo.getPushSettings();
      if (response.containsKey("code") && response["code"] == 1) {
        setState(() {
          enableNotifications =
              response["details"]["push_enabled"].toString() == "1";
        });
      }
    }
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
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    lang.api("Settings"),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    lang.api("Change language and app's info"),
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16.0),
                  ListTile(
                    leading: Icon(
                      Icons.translate,
                    ),
                    trailing: Icon(Icons.chevron_right),
//                              dense: true,
                    title: Text(lang.api("Language")),
                    subtitle: Text(lang.getLanguageText()),
                    onTap: () {
                      Get.to(() => LanguageSelector());
                    },
                  ),
                  ListTile(
//                              dense: true,
                    leading: SvgPicture.asset(
                      "assets/icons/mobile.svg",
                      color: Colors.grey,
                      width: 24,
                    ),
                    title: Text(lang.api("App version")),
                    subtitle: Text(lang.api("Device Information")),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(version),
                    ),
                  ),
                  !isLogin
                      ? Container()
                      : ListTile(
                          leading: SvgPicture.asset(
                            "assets/icons/notification.svg",
                            color: Colors.grey,
                            width: 24,
                          ),
                          title: Text(lang.api("Notifications")),
//                              subtitle: Text(lang.api("RECEIVE PUSH NOTIFICATION")),
                          trailing: enableNotifications == null
                              ? Container(
                                  child: CircularProgressIndicator(),
                                )
                              : Platform.isAndroid
                                  ? Switch(
                                      activeColor: Colors.green,
                                      value: enableNotifications ?? false,
                                      onChanged: onChange,
                                    )
                                  : CupertinoSwitch(
                                      activeColor: Colors.green,
                                      value: enableNotifications ?? false,
                                      onChanged: onChange,
                                    ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  onChange(newVal) async {
    setState(() {
      enableNotifications = newVal;
    });
    showLoadingDialog();
    Map<String, dynamic> response =
        await _repo.savePushSettings(enableNotifications ? "1" : "0");
    Navigator.of(context).pop();
    showError(_scaffoldKey, response["msg"]);
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/helper/app_builder.dart';
import 'package:afandim/helper/config.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/firebase_notification_handler.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/helper/routes.dart';
import 'package:afandim/model/setting_model.dart';
import 'package:afandim/model/update_model.dart';
import 'package:afandim/view/onBoarding/onBoarding_view.dart';
import 'package:afandim/view/profile/language_selector_view.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../control_view.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final _repository = Repository();
  final _prefManager = PrefManager();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String message = "";
  int errorCode = 0;

  static DioCacheManager _manager;

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  static DioCacheManager getCacheManager(String baseUrl) {
    if (null == _manager) {
      _manager = DioCacheManager(CacheConfig(baseUrl: baseUrl));
    }
    return _manager;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Stack(
          children: [
            Image.asset(
              'assets/images/app_splash_anim.gif',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  selectCountry(String url, String apiKey) async {
    final provider = context.read(generalProvider);
    String domain = "$url/mobileappv2/api/";
    provider.currentCountry = {"domain": url};
    provider.apiBaseUrl = url;
    provider.apiUrl = domain;
    provider.apiKey = apiKey;
    await _prefManager.set("api_base_url", url);
    await _prefManager.set("api_url", domain);
    await _prefManager.set("api_key", apiKey);
  }

  Future<bool> getServerSetting() async {
    Map<String, dynamic> response = await _repository.getServerSettings();

    if (response != null) {
      ServerSettingModel serverSettingModel =
          ServerSettingModel.fromJson(response);
      if (serverSettingModel.settings.isEnable == '1') {
        selectCountry(mainServerUrl, apiKey);
        return false;
      } else {
        return true;
      }
    } else {
      selectCountry(mainServerUrl, apiKey);
      return false;
    }
  }

  Future<bool> appUpdateCheck() async {
    Map<String, dynamic> response = await _repository
        .getUpdateSettings({"unit": "user", "platform": "android"});

    if (response != null) {
      UpdateModel updateModel = UpdateModel.fromJson(response);
      if (updateModel != null &&
          updateModel.required != null &&
          updateModel.required == '1') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  init() async {
    bool serverSetting = await getServerSetting();

    if (serverSetting) {
      await Navigator.of(context).pushNamed(countryServerRoute);
    }

    bool update = await appUpdateCheck();
    if (update) {
      await _prefManager.clear();
      String baseUrl = await _prefManager.get("api_base_url", '');
      if (baseUrl != null && baseUrl.contains('http'))
        await getCacheManager(baseUrl).clearAll();

      Navigator.of(context).pushReplacementNamed(
        updateRequired,
      );
    }

    await lang.init();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    AppBuilder.of(context).rebuild();
    FirebaseNotifications(
        context: context,
        getToken: (String notificationToken) async {
          String oldDeviceId =
              await _prefManager.get("firebase_notification_token", "");

          if (oldDeviceId != notificationToken && oldDeviceId.isNotEmpty) {
            await _repository.reRegisterDevice(notificationToken);
          }
          _prefManager.set("firebase_notification_token", notificationToken);
          new Timer(new Duration(milliseconds: 200), () {
            loadSettings();
          });
          // loadSettings();
        }).setUpFirebase();
  }

  loadSettings() async {
    // GeneralProvider
    Map<String, dynamic> response = await _repository.getSettings();
    if (response.containsKey("code") && response["code"] == 1) {
      await _prefManager.set(
          "app.settings", json.encode(response["details"]["settings"]));
      await _prefManager.set("settingsModel", json.encode(response));
      lang.loadApiLang();
      bool value = await _prefManager.get('intro', false);
      if (!lang.isLanguageSet) {
        Get.to(() => LanguageSelector());
        if (!value) {
          Get.off(OnBoardingView());
        } else
          finalStep(response);
      } else if (!value) {
        Get.off(OnBoardingView());
      } else {
        finalStep(response);
      }
    } else {
      if (response["code"] == -1) {
        showNoInternetDialog();
        errorCode = -1;
        message = response["msg"];
      } else {
        message = lang.api("Fail to load settings");
      }
      showError(_scaffoldKey, message);
      setState(() {});
    }
  }

  finalStep(Map<String, dynamic> response) async {
    Map<String, dynamic> addressListResponse =
        await _repository.getAddressBookDropDown();
    if (addressListResponse.containsKey("success") &&
        addressListResponse["success"]) {
      List list = addressListResponse["details"]["data"];
      final provider = context.read(generalProvider);
      provider.addressList = list;
    }
    String signIn = await _prefManager.get("sign_in", "");
    switch (signIn) {
      case "login":
        String login = await _prefManager.get("login", "");
        String password = await _prefManager.get("password", "");
        if (login.isNotEmpty) {
          Map<String, dynamic> loginResponse =
              await _repository.customerLogin(login, password);
          if (loginResponse.containsKey("code") &&
              (loginResponse["code"] == 1)) {
            _prefManager.set("user.data",
                json.encode(loginResponse["details"]["client_info"]));
            _prefManager.set(
                "token", loginResponse["details"]["client_info"]["token"]);
            Get.offAll(() => ControlView());
            return;
          }
        }
        _prefManager.remove("login");
        _prefManager.remove("password");
        break;
      case "facebook":
        Map<String, dynamic> facebookRequest =
            json.decode(await _prefManager.get("facebook_request", "{}"));
        if (facebookRequest.containsKey("first_name")) {
          Map<String, dynamic> loginResponse =
              await _repository.registerUsingFb(facebookRequest);
          if (loginResponse.containsKey("code") &&
              (loginResponse["code"] == 1)) {
            _prefManager.set("sign_in", "facebook");
            _prefManager.set("token", response["details"]["customer_token"]);
            _prefManager.set(
                "user.data",
                json.encode({
                  "first_name": facebookRequest["first_name"],
                  "last_name": facebookRequest["last_name"],
                  "email_address": facebookRequest["email_address"],
                  "status": "active",
                }));
            Get.offAll(() => ControlView());

            return;
          }
        }
        break;
      case "google":
        Map<String, dynamic> googleRequest =
            json.decode(await _prefManager.get("google_request", "{}"));
        if (googleRequest.containsKey("first_name")) {
          Map<String, dynamic> loginResponse =
              await _repository.googleLogin(googleRequest);
          if (loginResponse.containsKey("code") &&
              (loginResponse["code"] == 1)) {
            _prefManager.set("sign_in", "google");
            _prefManager.set("token", response["details"]["customer_token"]);
            _prefManager.set(
                "user.data",
                json.encode({
                  "first_name": googleRequest["first_name"],
                  "last_name": googleRequest["last_name"],
                  "email_address": googleRequest["email_address"],
                  "status": "active",
                }));
            Get.offAll(() => ControlView());

            return;
          }
        }
        break;
    }
    Get.offAll(() => ControlView());
  }
}

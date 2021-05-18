import 'dart:ui';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/app_builder.dart';
import 'package:afandim/helper/closable.dart';
import 'package:afandim/helper/config.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/helper/routes.dart';
import 'package:afandim/model/setting_model.dart';
import 'package:afandim/view/profile/language_selector_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class CountryPicker extends StatefulWidget {
  @override
  _CountryPickerState createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  var _prefManager = PrefManager();
  final _repo = Repository();
  List<Data> servers = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    initLang();
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  initLang() async {
    await lang.init();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    AppBuilder.of(context).rebuild();
    final provider = context.read(generalProvider);
    if (await _prefManager.contains("api_url") &&
        await _prefManager.contains("api_key") &&
        await _prefManager.contains("api_base_url")) {
      provider.apiUrl = await _prefManager.get("api_url", "");
      provider.apiBaseUrl = await _prefManager.get("api_base_url", "");
      provider.apiKey = await _prefManager.get("api_key", "");

      Navigator.of(context)
          .pushNamedAndRemoveUntil(splashRoute, (route) => false);
      return;
    } else {
      // selectCountry({"domain": mainServerUrl}, mainServerUrl);
      Map<String, dynamic> response = await _repo.getServerSettings();

      ServerSettingModel serverSettingModel =
          ServerSettingModel.fromJson(response);
      if (serverSettingModel != null) {
        servers = serverSettingModel.data;

        if (serverSettingModel.settings.isEnable == '1') {
          selectCountry(mainServerUrl, apiKey);
        }
      }

      // if(response["status"] == "success" && response.containsKey("data")){
      //   servers = response["data"];
      //   if(servers.length == 1){
      //     selectCountry(servers[0], servers[0]["domain"]);
      //   }
      // } else {
      //   selectCountry({"domain": mainServerUrl}, mainServerUrl);
      //   return;
      // }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Closable(
        child: isLoading
            ? Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/logo-bg.png"),
                      fit: BoxFit.cover),
                ),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage("assets/images/logo.png"),
                        height: 180,
                        width: 180,
                      ),
                      LoadingWidget(),
                    ],
                  ),
                ),
              )
            : Container(
                child: Container(
                  child: Stack(
                    children: <Widget>[
                      Image(
                        image: AssetImage("assets/images/background.jpg"),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
//            padding: EdgeInsets.symmetric(horizontal: 40),
                        child: ListView(
                          children: <Widget>[
                            SafeArea(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                width: MediaQuery.of(context).size.width,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => LanguageSelector());
                                  },
                                  child: Row(
//                        mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Icon(
                                        Icons.translate,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 16),
                                      Text(
                                        lang.text("Language"),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Image(
                                    // image: AssetImage("assets/images/logo.png"),
                                    image: AssetImage(
                                        "assets/images/logo-white.png"),
                                    width: 180,
                                    height: 180,
                                  ),
                                  SizedBox(height: 32),
                                  Text(
                                    lang.text(
                                        "Please select your country and start exploring the app"),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 32),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: servers.map<Widget>((country) {
                                      return Card(
                                        child: InkWell(
                                          onTap: () async {
                                            selectCountry(
                                                country.domain, country.apiKey);
                                          },
                                          child: Column(
                                            children: [
                                              Image(
                                                image: CachedNetworkImageProvider(
                                                    "$mainServerUrl/mobile-app-settings/uploads/${country.flag}"),
                                                width: 120,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                country.country,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
    Navigator.of(context)
        .pushNamedAndRemoveUntil(splashRoute, (route) => false);
  }
}

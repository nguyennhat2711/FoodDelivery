import 'package:afandim/core/services/repository.dart';
import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/divider_middle_text.dart';
import 'package:afandim/custom_widget/rounded_button.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/control_view.dart';
import 'package:afandim/view/home/home_widget/home_location_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({
    Key key,
  }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<UpdateScreen> {
  final _prefManager = PrefManager();
  final _repository = Repository();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // init();
    super.initState();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      scaffoldKey: _scaffoldKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
                    "assets/images/logo-sm.png",
                    scale: 2,
                    fit: BoxFit.fitWidth,
                    width: 160,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    lang.api("Updating database..."),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    lang.api(
                        "We have sent verification code to your mobile number"),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(height: 32.0),
                  AlternativeButton(
                    label: lang.api("EXIT"),
                    onPressed: () {
                      Navigator.pop(context);
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

  Widget getSocialLogin() {
    if (lang.settings["mobile2_enabled_fblogin"] != "1" &&
        lang.settings["mobile2_enabled_googlogin"] != "1") {
      //  && !Platform.isIOS
      return Container();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          DividerMiddleText(
            text: lang.api("Or"),
          ),
          SizedBox(
            height: 8,
          ),
          lang.settings["mobile2_enabled_fblogin"] != "1"
              ? Container()
              : RoundedButton(
                  color: Color(0xFF475993),
                  isOutline: true,
                  onPressed: () {},
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset(
                          "assets/icons/facebook.svg",
                          width: 32,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          lang.api("Login with Facebook"),
                          style: TextStyle(color: Color(0xFF475993)),
                        ),
                      ],
                    ),
                  ),
                ),
          lang.settings["mobile2_enabled_googlogin"] != "1"
              ? Container()
              : RoundedButton(
                  color: Color(0xFFEA4335),
                  isOutline: true,
                  onPressed: () {},
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset(
                          "assets/icons/google.svg",
                          width: 32,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          lang.api("Login with Google"),
                          style: TextStyle(color: Color(0xFFEA4335)),
                        ),
                      ],
                    ),
                  ),
                ),
          SizedBox(
            height: 8,
          ),
          Divider(
            height: 3,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  openLocationScreen() async {
    var result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return HomeLocationSelector();
      }),
    );
    if (result is bool && result) {
      goHome();
    } else {
      openLocationScreen();
    }
  }

  goHome() async {
    if (!await _prefManager.contains("location") && false) {
      openLocationScreen();
    } else {
      Map<String, dynamic> addressListResponse =
          await _repository.getAddressBookDropDown();
      if (addressListResponse.containsKey("code") &&
          addressListResponse["code"] == 1) {
        List list = addressListResponse["details"]["data"];
        final provider = context.read(generalProvider);
        provider.addressList = list;
      }
      if (await _prefManager.contains("come_from")) {
        int selectedIndex = 0;
        String comeFrom = await _prefManager.get("come_from", "");
        if (comeFrom == "cart") {
          selectedIndex = 2;
        } else if (comeFrom == "order_history") {
          selectedIndex = 1;
        }
        _prefManager.remove("come_from");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return ControlView(
            selectedIndex: selectedIndex,
          );
        }), (route) => false);
      } else {
        Get.off(ControlView());
      }
    }
  }

  showMessage(String message, [color]) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: color ?? Colors.orange,
    ));
  }
}

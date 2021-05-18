import 'dart:developer';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/helper/config.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/auth/verify_otp.dart';
import 'package:afandim/view/control_view.dart';
import 'package:afandim/view/home/home_widget/home_location_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

final loginViewModel = ChangeNotifierProvider<LoginViewModel>((ref) {
  return LoginViewModel(ref.watch(generalProvider));
});

class LoginViewModel extends ChangeNotifier {
  String countryCode = "1";
  final _repository = Repository();
  final phoneController = TextEditingController();

  final _prefManager = PrefManager();
  final phoneAddressFocus = new FocusNode();

  SmsAutoFill autoFill = SmsAutoFill();

  bool agree = true;

  GeneralProvider provider;

  LoginViewModel(GeneralProvider watch) {
    this.provider = watch;
    countryCode = lang.settings["mobile_prefix"].toString().replaceAll("+", "");
  }

  @override
  void dispose() {
    super.dispose();
    _repository.close();
  }

  setCode({
    @required String code,
  }) {
    countryCode = code;
  }

  changeAgreeCondition({@required bool value}) {
    agree = value;
    notifyListeners();
  }

  void handleLogin() async {
    if (verify()) {
      String login = phoneController.text;
      login = login.startsWith("0") ? login.substring(1) : login;
      if (login.startsWith("+")) {
        countryCode = "";
      } else {
        login = countryCode + phoneController.text;
      }
      log(login);
      log("login");
      mobNo = login;
      cCode = countryCode;
      _prefManager.set("login", login);
      showLoadingDialog(lang.api("Login..."));
      startPhoneAuth(login);
    }
  }

  startPhoneAuth(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        print("hello from code ");
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.toString());
        Get.back();
        if (e.code == 'invalid-phone-number') {
          showMessage(lang.api("invalid mobile number"));
        }
      },
      codeSent: (String verificationId, int resendToken) {
        print("hello from code ");
        Get.to(() => VerifyOtp(
              countryCode: countryCode,
              phone: phoneController.text,
              verificationID: verificationId,
            ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  bool verify() {
    String login = phoneController.text;
    // String password = passwordController.text;
    if (login.isEmpty) {
      showMessage(lang.api("Please enter your mobile number"));
      return false;
    }
    if (!agree) {
      showMessage(lang.api("You must agree to terms and condition"));
      return false;
    }
    return true;
  }

  openLocationScreen() async {
    var result = await Get.to(() => HomeLocationSelector());
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
        Get.off(
          () => ControlView(
            selectedIndex: selectedIndex,
          ),
        );
        // Navigator.of(context).pushAndRemoveUntil(
        //     MaterialPageRoute(builder: (context) {
        //   return ControlView(
        //     selectedIndex: selectedIndex,
        //   );
        // }), (route) => false);
      } else {
        Get.off(ControlView());
      }
    }
  }

  showMessage(String message, [color]) {
    Get.snackbar(
      'Some Thing happen!',
      message,
      snackPosition: SnackPosition.BOTTOM,
      colorText: Colors.white,
      backgroundColor: color ?? Colors.orange,
    );
  }
}

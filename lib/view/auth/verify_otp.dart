import 'dart:convert';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/core/viewmodel/auth_viewmodel.dart';
import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/divider_middle_text.dart';
import 'package:afandim/custom_widget/rounded_button.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/auth/update_profile.dart';
import 'package:afandim/view/control_view.dart';
import 'package:afandim/view/home/home_widget/home_location_selector.dart';
import 'package:afandim/view/profile/language_selector_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyOtp extends StatefulWidget {
  final countryCode;
  final phone;
  final String verificationID;

  const VerifyOtp({Key key, this.countryCode, this.phone, this.verificationID})
      : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<VerifyOtp> {
  final _prefManager = PrefManager();
  final _repository = Repository();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  BuildContext scaffoldContext;
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();
  String code = "";
  String verificationCode = '';
  int endTime;

  @override
  void initState() {
    // init();
    super.initState();
    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
    verificationCode = widget.verificationID;
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  onStarted() {
    _showSnackBar(context, "PhoneAuth started");
//    _showSnackBar(phoneAuthDataProvider.message);
  }

  onCodeSent() {
    _showSnackBar(context, "OPT sent");
//    _showSnackBar(phoneAuthDataProvider.message);
  }

  onCodeResent() {
    _showSnackBar(context, "OPT resent");
//    _showSnackBar(phoneAuthDataProvider.message);
  }

  onVerified() async {
    _showSnackBar(context, "${context.read(phoneAuthDataProvider).message}");
    await Future.delayed(Duration(seconds: 1));

    // Navigator.of(context).push(
    //     MaterialPageRoute(builder: (BuildContext context) => CreatePro()));
    //  PagesWidget
  }

  onFailed() {
    // _showSnackBar(phoneAuthDataProvider.message);
    _showSnackBar(context, "PhoneAuth failed");
  }

  onError() {
//    _showSnackBar(phoneAuthDataProvider.message);
    _showSnackBar(context,
        "PhoneAuth error ${context.read(phoneAuthDataProvider).message}");
  }

  onAutoRetrievalTimeOut() {
    _showSnackBar(context, "PhoneAuth autoretrieval timeout");
//    _showSnackBar(phoneAuthDataProvider.message);
  }

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 1),
    ));
  }

  signIn() async {
    if (code.length != 6) {
      _showSnackBar(context, lang.api("invalid code"));
    } else {
      // Create a PhoneAuthCredential with the code
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationCode, smsCode: code);

      // Sign the user in (or link) with the credential
      if (credential != null) {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential != null) {
          User user = userCredential.user;
          String userToken = await user.getIdToken(true);
          if (user != null) {
            showLoadingDialog(lang.api("Creation account"));
            Map<String, dynamic> response = await _repository.createAccount({
              "first_name": '',
              "last_name": '',
              "contact_phone": user.phoneNumber,
              "email_address":
                  user.phoneNumber.replaceFirst('+', '') + '@gmail.com',
              "password": user.uid,
              "cpassword": user.uid,
              "check_terms_condition": 1,
              "next_step": "show_home_page",
            });
            Navigator.of(context).pop();
            if (response.containsKey("code") && response["code"] == 1) {
              print("response: $response");
              await PrefManager()
                  .set("token", response["details"]["customer_token"]);
              // Navigator.of(context).pushNamedAndRemoveUntil(
              //     homeRoute, ModalRoute.withName("/no_route"));
              // loginUser(user.phoneNumber,user.uid);
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(builder: (context) {
              //     return UpdateProfile();
              //   }),
              // );
              loginUserFirebase(user.phoneNumber, user.uid, userToken);
            } else {
              if (response["msg"] != null &&
                  (response["msg"].contains('already exist'))) {
                loginUserFirebase(user.phoneNumber, user.uid, userToken);
              } else if (response["msg"] != null &&
                  (response["msg"].contains('incorrect'))) {
                loginUserFirebase(user.phoneNumber, user.uid, userToken);
              } else {
                showError(_scaffoldKey, response["msg"]);
              }

              //
            }
          }
        }
      }
    }
  }

  Widget otpWidget() {
    return Form(
      key: Key('signUpForm_otpInput_textField'),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
          child: PinCodeTextField(
            appContext: context,
            pastedTextStyle: TextStyle(
              color: Color(0xFFEEEEF3),
              fontWeight: FontWeight.bold,
            ),
            length: 6,
            obscureText: false,
            obscuringCharacter: '*',
            blinkWhenObscuring: true,
            animationType: AnimationType.fade,
            validator: (v) {
              if (v.length < 3) {
                return "";
              } else {
                return null;
              }
            },
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(5),
              inactiveColor: Colors.grey,
              fieldHeight: 40,
              fieldWidth: 36,
              activeFillColor: Colors.white,
              inactiveFillColor: Color(0xFFEEEEF3),
              activeColor: Theme.of(context).primaryColor,
              selectedFillColor: Theme.of(context).primaryColor,
            ),
            cursorColor: Theme.of(context).primaryColor,
            animationDuration: Duration(milliseconds: 300),
            // backgroundColor: Colors.blue.shade50,
            enableActiveFill: true,

            keyboardType: TextInputType.number,
            boxShadows: [
              BoxShadow(
                offset: Offset(0, 1),
                color: Colors.black12,
                blurRadius: 10,
              )
            ],
            onCompleted: (v) {
              // print("Completed");

              signIn();
            },
            // onTap: () {
            //   print("Pressed");
            // },
            onChanged: (email) {
              code = email;
            },
            beforeTextPaste: (text) {
              print("Allowing to paste $text");
              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
              //but you can show anything you want here, like your pop up saying wrong paste format or etc
              return true;
            },
          )),
    );
  }

  loginUser(String phone, String uid) async {
    _prefManager.set("login", phone);
    _prefManager.set("password", uid);
    showLoadingDialog(lang.api("Login..."));
    Map<String, dynamic> response = await _repository.customerLogin(phone, uid);
    Navigator.of(context).pop();
    if (response.containsKey("code")) {
      if (response["code"] == 1) {
        _prefManager.set("sign_in", "login");
        _prefManager.set(
            "user.data", json.encode(response["details"]["client_info"]));
        _prefManager.set("token", response["details"]["client_info"]["token"]);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return UpdateProfile();
          }),
        );
        // goHome();
      } else {
        showMessage(response["msg"], Colors.red);
      }
    } else {
      showMessage(lang.api("System error, please try again"));
    }
  }

  loginUserFirebase(String phone, String uid, String token) async {
    _prefManager.set("login", phone);
    _prefManager.set("password", uid);
    showLoadingDialog(lang.api("Login..."));
    Map<String, dynamic> response = await _repository.loginCustomerOld({
      "user_mobile": phone,
      "login_type": 'firebase',
      "firebase_uuid": uid,
      'auth_token': token
    });
    Navigator.of(context).pop();
    if (response.containsKey("code")) {
      if (response["code"] == 1) {
        _prefManager.set("sign_in", "login");
        _prefManager.set(
            "user.data", json.encode(response["details"]["client_info"]));
        _prefManager.set("token", response["details"]["client_info"]["token"]);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return UpdateProfile();
          }),
        );
        // goHome();
      } else {
        showMessage(response["msg"], Colors.red);
      }
    } else {
      showMessage(lang.api("System error, please try again"));
    }
  }

  // This will return pin field - it accepts only single char
  Widget getPinField({String key, FocusNode focusNode}) => SizedBox(
        height: 40.0,
        width: 35.0,
        child: TextField(
          key: Key(key),

          expands: false,
//          autofocus: key.contains("1") ? true : false,
          autofocus: false,
          focusNode: focusNode,
          onChanged: (String value) {
            if (value.length == 1) {
              code += value;
              switch (code.length) {
                case 1:
                  FocusScope.of(context).requestFocus(focusNode2);
                  break;
                case 2:
                  FocusScope.of(context).requestFocus(focusNode3);
                  break;
                case 3:
                  FocusScope.of(context).requestFocus(focusNode4);
                  break;
                case 4:
                  FocusScope.of(context).requestFocus(focusNode5);
                  break;
                case 5:
                  FocusScope.of(context).requestFocus(focusNode6);
                  break;
                default:
                  FocusScope.of(context).requestFocus(FocusNode());
                  break;
              }
            }
          },
          maxLengthEnforced: false,
          textAlign: TextAlign.center,
          cursorColor: Colors.white,
          keyboardType: TextInputType.number,
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      );

  startPhoneAuth() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(minutes: 1),
      phoneNumber: '+' + widget.countryCode + widget.phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
// ANDROID ONLY!

        // Sign the user in (or link) with the auto-generated credential

        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          // print('The provided phone number is not valid.');
          showMessage(lang.api("invalid mobile number"));
        }
      },
      codeSent: (String verificationId, int resendToken) {
        setState(() {
          endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
        });
        verificationCode = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final phoneAuth = context.read(phoneAuthDataProvider);

    phoneAuth.setMethods(
      onStarted: onStarted,
      onError: onError,
      onFailed: onFailed,
      onVerified: onVerified,
      onCodeResent: onCodeResent,
      onCodeSent: onCodeSent,
      onAutoRetrievalTimeout: onAutoRetrievalTimeOut,
    );
    return CustomPage(
      scaffoldKey: _scaffoldKey,
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
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  Get.off(ControlView());
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
                children: <Widget>[
                  Image.asset(
                    "assets/images/logo-sm.png",
                    scale: 2,
                    fit: BoxFit.fitWidth,
                    width: 160,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    lang.api("Verification code"),
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
                  otpWidget(),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: <Widget>[
                  //     getPinField(key: "1", focusNode: focusNode1),
                  //     SizedBox(width: 10.0),
                  //     getPinField(key: "2", focusNode: focusNode2),
                  //     SizedBox(width: 10.0),
                  //     getPinField(key: "3", focusNode: focusNode3),
                  //     SizedBox(width: 10.0),
                  //     getPinField(key: "4", focusNode: focusNode4),
                  //     SizedBox(width: 10.0),
                  //     getPinField(key: "5", focusNode: focusNode5),
                  //     SizedBox(width: 10.0),
                  //     getPinField(key: "6", focusNode: focusNode6),
                  //     SizedBox(width: 10.0),
                  //   ],
                  // ),
                  SizedBox(height: 32.0),
//                  AlternativeTextField(
//                    controller: usernameController,
//                    hint: lang.api("Mobile number"),
//                    onFieldSubmitted: (String text){
//                      FocusScope.of(context).requestFocus(passwordFocusNode);
//                    },
//                    keyboardType: TextInputType.emailAddress,
//                    prefix: SvgPicture.asset(
//                      "assets/icons/mobile.svg",
//                      color: Colors.grey,
//                      width: 24,
//                    ),
//                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CountdownTimer(
                        endTime: endTime,
                        widgetBuilder:
                            (BuildContext context, CurrentRemainingTime time) {
                          if (time == null) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // validateMobile(getMob);
                                    // setState(() {
                                    //   endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
                                    // });
                                    startPhoneAuth();
                                  },
                                  child: Text(
                                    lang.api("click here to resend"),
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ],
                            );
                          }
                          List<Widget> list = [];

                          if (time.min != null) {
                            list.add(Row(
                              children: <Widget>[
                                Text(time.min.toString()),
                                Text(":"),
                              ],
                            ));
                          }
                          if (time.sec != null) {
                            list.add(Row(
                              children: <Widget>[
                                Text(time.sec.toString()),
                              ],
                            ));
                          }

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                lang.api("click here to resend"),
                                style: TextStyle(fontSize: 15),
                              ),
                              Container(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: list,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 30.0),

                  AlternativeButton(
                    label: lang.api("Verify"),
                    onPressed: () {
                      signIn();
                    },
                  ),
                ],
              ),
            ),
          ),
          // GestureDetector(
          //   onTap: (){
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => SupportChat(),
          //       ),
          //     );
          //   },
          //   child: Text(
          //     'Contact Us',
          //     style: TextStyle(
          //       color: Theme.of(context).primaryColor,
          //       decoration: TextDecoration.underline,
          //       fontSize: 16
          //     ),
          //   ),
          // )
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
        var provider = context.read(generalProvider);
        //         final provider = context.read(generalProvider);
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

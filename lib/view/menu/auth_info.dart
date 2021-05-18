import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthInfo extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Map<String, dynamic> request;

  AuthInfo({
    Key key,
    @required this.onComplete,
    this.request,
  }) : super(key: key);

  @override
  _AuthInfoState createState() => _AuthInfoState();
}

class _AuthInfoState extends State<AuthInfo> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final cPasswordController = TextEditingController();

  final passwordFocusNode = new FocusNode();
  final cPasswordFocusNode = new FocusNode();

  String errorMessage = "";

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    if (widget.request != null) {
      usernameController.text = widget.request["username"] ?? "";
      passwordController.text = widget.request["password"] ?? "";
      cPasswordController.text = widget.request["cpassword"] ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, right: 16, left: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AlternativeTextField(
              prefix: SvgPicture.asset(
                "assets/icons/user.svg",
                color: Colors.grey,
                width: 24,
              ),
              controller: usernameController,
              hint: lang.api("Username"),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (String text) {
                FocusScope.of(context).requestFocus(passwordFocusNode);
              },
            ),
            AlternativeTextField(
              prefix: SvgPicture.asset(
                "assets/icons/lock.svg",
                color: Colors.grey,
                width: 24,
              ),
              focusNode: passwordFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (String text) {
                FocusScope.of(context).requestFocus(cPasswordFocusNode);
              },
              controller: passwordController,
              hint: lang.api("Password"),
              isPassword: true,
            ),
            AlternativeTextField(
              prefix: SvgPicture.asset(
                "assets/icons/lock.svg",
                color: Colors.grey,
                width: 24,
              ),
              textInputAction: TextInputAction.done,
              focusNode: cPasswordFocusNode,
              controller: cPasswordController,
              hint: lang.api("Confirm Password"),
              isPassword: true,
            ),
            errorMessage.isEmpty
                ? Container()
                : Container(
                    padding: EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            AlternativeButton(
              label: lang.api("Submit"),
              onPressed: () {
                if (usernameController.text.isEmpty) {
                  errorMessage =
                      lang.api("either username or password is empty");
                } else if (isArabic(usernameController.text)) {
                  errorMessage = lang.api("username must not be arabic letter");
                } else if (passwordController.text.isEmpty) {
                  errorMessage =
                      lang.api("either username or password is empty");
                } else if (passwordController.text !=
                    cPasswordController.text) {
                  errorMessage = lang.api("Confirm password does not match");
                } else {
                  Map<String, dynamic> request = {
                    "username": usernameController.text,
                    "password": passwordController.text,
                    "cpassword": cPasswordController.text,
                    "abn": "abn",
                  };

                  widget.onComplete(request);
                  return;
                }
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

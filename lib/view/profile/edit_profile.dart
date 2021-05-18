import 'package:afandim/core/services/repository.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/helper/utils.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../helper/utils.dart';

class EditProfile extends StatefulWidget {
  final String notification;

  const EditProfile({Key key, this.notification}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _prefManager = PrefManager();
  final _repository = Repository();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  // final phoneController = TextEditingController();
  String countryCode = "1";
  bool isLoading = true;
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

  var userData;
  init() async {
    setState(() {
      countryCode =
          lang.settings["mobile_prefix"].toString().replaceAll("+", "");
      isLoading = true;
    });
    Map<String, dynamic> response = await _repository.getProfile();
    setState(() {
      isLoading = false;
    });
    if (response.containsKey("code") && response["code"] == 1) {
      userData = response["details"]["data"];
      firstNameController.text = userData["first_name"] ?? "";
      lastNameController.text = userData["last_name"] ?? "";
      emailController.text = userData["email_address"] ?? "";
      countryCode = userData["contact_phone"].toString().substring(1, 3);
      // phoneController.text = userData["contact_phone"].toString().substring(3);
    }
    if (widget.notification != null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            widget.notification,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      scaffoldKey: _scaffoldKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              // InkWell(
              //   onTap: (){
              //     Navigator.of(context).pushNamed(changePasswordRoute);
              //   },
              //   child: Container(
              //     padding: EdgeInsets.all(8),
              //     child: Row(
              //       children: <Widget>[
              //         Text(
              //           lang.api("Change password"),
              //           style: TextStyle(
              //             color: Colors.white,
              //           ),
              //         ),
              //         SizedBox(width: 8),
              //         SvgPicture.asset(
              //           "assets/icons/lock.svg",
              //           color: Colors.white,
              //           width: 24,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
          Card(
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: getBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget getBody() {
    if (isLoading) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: LoadingWidget(
          message: lang.api("loading"),
          size: 84,
          useLoader: true,
        ),
      );
    } else {
      return buildBody();
    }
  }

  Widget buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          lang.api("Edit profile"),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          lang.api("manage your profile, orders etc."),
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
          enabled: true,
          fontColor: Colors.grey,
          hint: lang.api("Email"),
          keyboardType: TextInputType.emailAddress,
          prefix: SvgPicture.asset(
            "assets/icons/mail.svg",
            color: Colors.grey,
            width: 24,
          ),
        ),
        AlternativeButton(
          label: lang.api("Save"),
          onPressed: () async {
            if (validateName(firstNameController.text) != null) {
              showError(_scaffoldKey, validateName(firstNameController.text));
            } else if (validateLastName(lastNameController.text) != null) {
              showError(
                  _scaffoldKey, validateLastName(lastNameController.text));
            } else if (validateEmail(emailController.text) != null) {
              showError(_scaffoldKey, validateEmail(emailController.text));
            } else {
              showLoadingDialog();
              Map<String, dynamic> response = await _repository.updateProfile({
                "first_name": firstNameController.text,
                "last_name": lastNameController.text,
                "email_address": emailController.text,
                "contact_phone": userData["contact_phone"].toString(),
              });
              Navigator.of(context).pop();
              showError(_scaffoldKey, response["msg"]);
            }
          },
        ),
      ],
    );
  }
}

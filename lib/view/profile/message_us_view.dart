import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MessageUs extends StatefulWidget {
  @override
  _MessageUsState createState() => _MessageUsState();
}

class _MessageUsState extends State<MessageUs> {
  final _repository = Repository();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

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

  init() async {}

  @override
  Widget build(BuildContext context) {
    return CustomPage(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text(
                    lang.api("Message Us"),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  lang.settings["contact_us"]["contact_field"].contains("name")
                      ? AlternativeTextField(
                          hint: lang.api("Name"),
                          keyboardType: TextInputType.emailAddress,
                          prefix: SvgPicture.asset(
                            "assets/icons/user.svg",
                            color: Colors.grey,
                            width: 24,
                          ),
                        )
                      : Container,
                  lang.settings["contact_us"]["contact_field"].contains("email")
                      ? AlternativeTextField(
                          controller: emailController,
                          hint: lang.api("Email"),
                          keyboardType: TextInputType.emailAddress,
                          prefix: SvgPicture.asset(
                            "assets/icons/mail.svg",
                            color: Colors.grey,
                            width: 24,
                          ),
                        )
                      : Container(),
                  lang.settings["contact_us"]["contact_field"].contains("phone")
                      ? AlternativeTextField(
                          hint: lang.api("Contact Number"),
                          keyboardType: TextInputType.phone,
                          prefix: SvgPicture.asset(
                            "assets/icons/mobile.svg",
                            color: Colors.grey,
                            width: 24,
                          ),
                        )
                      : Container(),
                  lang.settings["contact_us"]["contact_field"]
                          .contains("message")
                      ? AlternativeTextField(
                          hint: lang.api("Message"),
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.emailAddress,
                          prefix: SvgPicture.asset(
                            "assets/icons/mail.svg",
                            color: Colors.grey,
                            width: 24,
                          ),
                        )
                      : Container(),
                  AlternativeButton(
                    label: lang.api("Submit"),
                    onPressed: () {
                      Navigator.of(context).pop();
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

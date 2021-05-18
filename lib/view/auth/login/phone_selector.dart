import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PhoneSelector extends StatefulWidget {
  final String phone;
  final String countryCode;

  const PhoneSelector({Key key, this.phone, this.countryCode})
      : super(key: key);

  @override
  _PhoneSelectorState createState() => _PhoneSelectorState();
}

class _PhoneSelectorState extends State<PhoneSelector> {
  final _repository = Repository();
  final phoneController = TextEditingController();
  final searchController = TextEditingController();
  String countryCode;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    phoneController.text = widget.phone;
    countryCode = widget.countryCode;
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      scaffoldKey: _scaffoldKey,
      child: Stack(
        children: [
          Column(
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 8.0),
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
                        lang.api("Enter your mobile no."),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lang.api(
                            "We use it to make sure our deliveries reach you"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        textDirection: TextDirection.ltr,
                        children: <Widget>[
                          Expanded(
                            child: AlternativeTextField(
                              controller: phoneController,
                              textInputAction: TextInputAction.done,
                              hint: lang.api("Mobile no."),
                              keyboardType: TextInputType.phone,
                              isPhoneNumber: true,
                              onChanged: (text) {
                                setState(() {});
                              },
                              prefix: SvgPicture.asset(
                                "assets/icons/mobile.svg",
                                color: Colors.grey,
                                width: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AlternativeButton(
                        label: lang.api("Submit"),
                        onPressed: phoneController.text.isEmpty ? null : () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          isLoading ? LoadingWidget() : Container(),
        ],
      ),
    );
  }
}

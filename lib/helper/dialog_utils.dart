import 'package:afandim/helper/constance.dart';
import 'package:afandim/helper/wavy_header.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'global_translations.dart';

Future<bool> showCustomSuccessDialog(
  BuildContext context, {
  String title,
  String subtitle,
  String positive,
  String negative,
  Color color,
  bool isDismissible = false,
}) async {
  return showCustomDialog(
      title: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      color: color ?? Theme.of(context).primaryColor,
      subtitle: Text(
        subtitle,
        textAlign: TextAlign.center,
      ),
      positiveLabel: Text(
        positive ?? lang.text("OK"),
        style: TextStyle(color: Colors.white),
      ),
      negativeLabel: negative == null
          ? null
          : Text(
              negative,
              style: TextStyle(color: Colors.white),
            ),
      negativeColor: Colors.grey,
      isDismissible: isDismissible,
      positiveColor: Theme.of(context).primaryColor);
}

Future<bool> showCustomErrorDialog(
    [String title, String subtitle, String positiveLabel]) async {
  return showCustomDialog(
    title: Text(
      title ?? lang.text("Close App"),
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    color: Colors.red,
    subtitle: Text(
      subtitle ?? lang.text("Are you sure to close the app?"),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
    ),
    negativeLabel: Text(
      lang.text("Ignore"),
      style: TextStyle(color: Colors.black),
    ),
    positiveLabel: Text(
      positiveLabel ?? lang.text("Close"),
      style: TextStyle(color: Colors.white),
    ),
    negativeColor: Color(0xFFe6e6e6),
    positiveColor: Colors.red,
  );
}

Future<bool> showCustomDialog(
    {@required Widget title,
    @required Widget subtitle,
    @required Widget positiveLabel,
    @required Widget negativeLabel,
    @required Color negativeColor,
    @required Color positiveColor,
    Color color,
    bool isDismissible = true}) async {
  var status = await Get.dialog(
    AlertDialog(
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              title is Text
                  ? WavyHeader(
                      child: title,
                      color: color,
                    )
                  : title,
              SizedBox(
                height: 16,
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 0, bottom: 8, left: 16, right: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    subtitle ?? Container(),
                    subtitle == null
                        ? Container
                        : SizedBox(
                            height: 16,
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _getButtons(
                        positiveLabel,
                        positiveColor,
                        negativeLabel,
                        negativeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(16.0))),
    barrierDismissible: isDismissible,
  );

  return status ?? false;
}

List<Widget> _getButtons(
    positiveLabel, positiveColor, negativeLabel, negativeColor) {
  List<Widget> list = [
    RaisedButton(
        child: positiveLabel,
        onPressed: () async {
          Get.back(result: true);
          // Navigator.of().pop(true);
        },
        color: positiveColor,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0))),
  ];
  if (negativeLabel != null) {
    list.add(RaisedButton(
        child: negativeLabel,
        onPressed: () {
          Get.back(result: false);
        },
        color: negativeColor,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0))));
  }
  return list;
}

Future<bool> showNoInternetDialog() async {
  bool openSettings = await showCustomDialog(
    title: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image(
          image: AssetImage("assets/images/no_internet.png"),
          width: 128,
          height: 128,
        ),
        Text(
          lang.api("No Internet"),
          style: TextStyle(
            fontSize: 18,
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    subtitle: Text(
      lang.api("Ooops, Please check your internet connection."),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
    ),
    negativeLabel: Text(
      lang.api("CANCEL"),
      style: TextStyle(color: Colors.black),
    ),
    positiveLabel: Text(
      lang.api("SETTINGS"),
      style: TextStyle(color: Colors.white),
    ),
    negativeColor: Color(0xFFe6e6e6),
    positiveColor: primaryColor,
  );
  if (openSettings) {
    AppSettings.openWIFISettings();
  }
  return openSettings;
}

void showLoadingDialog([String message]) {
  // flutter defined function
  Get.dialog(
      AlertDialog(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(
              width: 32,
            ),
            Expanded(child: Text(message ?? lang.text("Loading..."))),
          ],
        ),
      ),
      barrierDismissible: false);
}

Future<DateTime> getDate(context,
    {DateTime firstDate, DateTime initialDate}) async {
  DateTime picked = await showDatePicker(
    context: context,
    locale: Locale(lang.currentLanguage),
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 356 * 20)),
  );
  return picked;
//    if (picked != null) {
//      setState(() {
//        deliveryDate = {
//          "key": DateFormat("yyyy-MM-dd", lang.currentLanguage).format(picked),
//          "label": DateFormat("dd MMM, yyyy", lang.currentLanguage).format(picked),
//        };
//      });
//    }
}

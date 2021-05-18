import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/helper/app_builder.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSelector extends StatefulWidget {
  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
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
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8.0),
                  Text(
                    lang.api("Select language"),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    lang.api("Choose the language you prefer"),
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16.0),
                  ListView.separated(
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      Locale item = lang.supportedLocales().toList()[index];
                      bool selected = item.languageCode == lang.currentLanguage;
                      return Container(
                        child: ListTile(
                          onTap: () async {
                            _handleLanguageChange(item.languageCode);
                          },
                          leading: Icon(
                            Icons.check,
                            color: selected ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            lang.text("i18n_${item.languageCode}"),
                            style: TextStyle(
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 1,
                        color: Colors.grey,
                      );
                    },
                    itemCount: lang.supportedLocales().toList().length,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: AlternativeButton(
              label: lang.api("OK"),
              onPressed: () async {
                if (!lang.isLanguageSet) {
                  await lang.setNewLanguage(lang.currentLanguage, true);
                }

                Get.back();
              },
            ),
          )
        ],
      ),
    );
  }

  void _handleLanguageChange(String value) async {
//    bool agree = await _agreeChangeLanguage();
//    if(agree){

    await lang.setNewLanguage(value, true);
    AppBuilder.of(context).rebuild();
//    }
  }

//  Future<bool> _agreeChangeLanguage() async {
//    // flutter defined function
//    var status = await showCustomDialog(context,
//      title: Text(lang.text("Change Settings"),
//        style: TextStyle(
//          fontSize: 18,
//          color: Theme.of(context).primaryColor,
//          fontWeight: FontWeight.bold,
//        ),
//      ),
//      subtitle: Text(
//        lang.text("Are you sure to change the language?"),
//        textAlign: TextAlign.center,
//        style: TextStyle(
//          fontSize: 16,
//          color: Colors.grey,
//        ),
//      ),
//      negativeLabel: Text(
//        lang.text("Not agree"),
//        style: TextStyle(color: Colors.white),
//      ),
//      positiveLabel: Text(
//        lang.text("Agree"),
//        style: TextStyle(color: Colors.white),
//      ),
//      positiveColor: Colors.green,
//      negativeColor: Colors.red,
//      isDismissible: true,
//    );
//    return status ?? false;
//  }

}

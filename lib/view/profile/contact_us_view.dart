import 'package:afandim/custom_widget/help/contact_us_card.dart';
import 'package:afandim/helper/config.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/routes.dart';
import 'package:afandim/view/support_chat/support_chat.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.api("Contact Us"),
        ),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/images/calling.png",
                width: 320,
              ),
              SizedBox(height: 8),
              Card(
                elevation: 4,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4))),
                        child: Text(lang.api("Social Medial:")),
                      ),
                      ContactUsCard(
                        imagePath: "assets/icons/facebook.svg",
                        label: lang.api("Facebook"),
                        color: Color(0xff1877F2),
                        onTap: () async {
                          String url = "https://fb.com/efendim.biz";
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
//          #
              Card(
                elevation: 4,
                child: Container(
                  child: ContactUsCard(
                    imagePath: "assets/icons/insta.svg",
                    label: lang.api("Instagram"),
                    color: Color(0xffBF369E),
                    onTap: () async {
                      String url = "https://instagram.com/efendim.biz";
                      if (await canLaunch(url)) {
                        await launch(url);
                      }
                    },
                  ),
                ),
              ),
              Card(
                elevation: 4,
                child: Container(
                  child: ContactUsCard(
                    imagePath: "assets/icons/messenger.svg",
                    label: lang.api("Messenger"),
                    color: Color(0xff007FFF),
                    onTap: () async {
                      String url = contactUsMessenger;
                      if (await canLaunch(url)) {
                        await launch(url);
                      }
                    },
                  ),
                ),
              ),
              Card(
                elevation: 4,
                child: Container(
                  child: ContactUsCard(
                    imagePath: "assets/icons/msg.png",
                    label: lang.api("Message Us"),
                    color: Color(0xff3B97D3),
                    onTap: () async {
                      Navigator.of(context).pushNamed(messageUsRoute);
                    },
                  ),
                ),
              ),
              Card(
                elevation: 4,
                child: Container(
                  child: ContactUsCard(
                    imagePath: "assets/icons/ic_action_chat.png",
                    label: lang.api("Chat Us"),
                    color: Theme.of(context).primaryColor,
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SupportChat(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

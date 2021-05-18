import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/routes.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BecomePartnerView extends StatefulWidget {
  @override
  _BecomePartnerViewState createState() => _BecomePartnerViewState();
}

class _BecomePartnerViewState extends State<BecomePartnerView> {
  List list = [
//    {
//      "image_path": "assets/images/logo.png",
//      "name": lang.api("Admin"),
//      "route_name": registerVendorRoute
//    },
    {
      "image_path": "assets/images/logo-shop.png",
      "name": lang.api("Provider"),
      "subtitle": lang.api("Register your Business with us"),
      "url":
          "https://play.google.com/store/apps/details?id=net.afandim.peoviderapp"
//      "route_name": registerProviderRoute
    },
    {
      "image_path": "assets/images/logo-delivary.png",
      "name": lang.api("Deliveryman"),
      "subtitle": lang.api("Become one of our Drivers"),
      "route_name": registerDeliveryRoute
    },
//    {
//      "image_path": "assets/images/logo.png",
//      "name": lang.api("Account Manager"),
//      "route_name": registerVendorRoute
//    },
  ];

  Widget getBody() {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.api("Be Afandim Partner")),
      ),
      body: Container(
        child: getListView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getListView() {
    return ListView.builder(
      itemCount: list.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        var item = list[index];
        return getCard(item);
      },
    );
  }

  Widget getCard(item) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4,
      child: InkWell(
        onTap: () async {
          if (item["route_name"] == null) {
            String url = item["url"];
            if (await canLaunch(url)) {
              await launch(url);
            }
          } else {
            Navigator.of(context).pushNamed(item["route_name"]);
          }
        },
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image(
                image: AssetImage(item["image_path"]),
                width: 64,
                height: 64,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item["name"]}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${item["subtitle"]}",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

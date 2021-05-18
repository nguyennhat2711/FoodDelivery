import 'dart:io';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/custom_rating_bar.dart';
import 'package:afandim/custom_widget/dialog_item.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverInfo extends StatefulWidget {
  final driverData;

  DriverInfo({Key key, this.driverData}) : super(key: key);

  @override
  _DriverInfoState createState() => _DriverInfoState();
}

class _DriverInfoState extends State<DriverInfo> {
  final _repo = Repository();
  bool isLoading = true;
  Map data;
  String message;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    setState(() {
      isLoading = true;
    });
    setState(() {
      data = widget.driverData;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.api("Profile")),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: getBody(),
      ),
    );
  }

  Widget getBody() {
    if (isLoading) {
      return LoadingWidget(
        size: 84.0,
        useLoader: true,
        message: lang.api("loading"),
      );
    } else {
      if (data == null) {
        return EmptyWidget(
          message: message,
          size: 128,
        );
      } else {
        return buildBody();
      }
    }
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            getDriverInfo(),
            SizedBox(height: 8),
            getKeyValue(),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget getDriverInfo() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: data["profile_photo"],
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                placeholder: (_, text) {
                  return Image(
                    image: AssetImage("assets/images/item-placeholder.png"),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  );
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data["full_name"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    CustomRatingBar(
                      onChanged: (value) {},
                      numStars: 5,
                      rating: double.parse("${data["rating"]["ratings"]}"),
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              DialogItem(
                icon: Icons.email,
                label: lang.api("Email"),
                onTap: () async {
                  var url = "mailto://${data["email"]}";
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                },
              ),
              DialogItem(
                icon: Icons.phone,
                label: lang.api("Phone"),
                onTap: () async {
                  var url = "tel://${data["phone"]}";
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                },
              ),
              DialogItem(
                icon: SvgPicture.asset(
                  "assets/icons/whats_app.svg",
                  width: 32,
                ),
                label: lang.api("Whatsapp"),
                onTap: () async {
                  String phone = data["phone"];
                  var url = "whatsapp://send?phone=${data["phone"]}";
                  if (Platform.isIOS) {
                    url = "whatsapp://wa.me/$phone/?text=";
                  } else {
                    url = "whatsapp://send?phone=$phone";
                  }
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getKeyValue() {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: data["sub_data"].length,
      itemBuilder: (context, index) {
        Map item = data["sub_data"][index];
        return Container(
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item["label"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item["value"],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

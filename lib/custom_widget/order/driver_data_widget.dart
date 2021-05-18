import 'package:afandim/custom_widget/circle_image.dart';
import 'package:afandim/custom_widget/custom_rating_bar.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/order/driver_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverDataWidget extends StatefulWidget {
  final Map taskData;
  final Map driverData;
  final bool loadingDriver;

  DriverDataWidget({
    Key key,
    @required this.driverData,
    this.loadingDriver = true,
    @required this.taskData,
  }) : super(key: key);

  @override
  _DriverDataWidgetState createState() => _DriverDataWidgetState();
}

class _DriverDataWidgetState extends State<DriverDataWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: widget.loadingDriver
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return DriverInfo(
                          driverData: widget.driverData,
                        );
                      }),
                    );
                  },
            child: Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        widget.loadingDriver
                            ? Container(
                                child: CircularProgressIndicator(),
                              )
                            : CircleImage(
                                child: CachedNetworkImage(
                                  imageUrl: widget.driverData["profile_photo"],
                                  width: 46,
                                  height: 46,
                                  fit: BoxFit.cover,
                                  placeholder: (_, text) {
                                    return Image(
                                      image: AssetImage(
                                          "assets/images/category-placeholder.png"),
                                      width: 46,
                                      height: 46,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                                borderWidth: 0,
                              ),
                        Text(
                          widget.taskData['driver_name'] ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.taskData['driver_email'],
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CustomRatingBar(
                              onChanged: (value) {},
                              rating: double.parse(
                                  "${widget.driverData["rating"]["ratings"]}"),
                              isInt: false,
                              size: 8,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text("${widget.driverData["rating"]["votes"]}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey,
                    width: 1,
                    height: 80,
                  ),
                  Expanded(
                    child: widget.loadingDriver
                        ? Container(
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SvgPicture.asset(
                                    "assets/icons/color.svg",
                                    color: Theme.of(context).primaryColor,
                                    width: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    widget.driverData['color'] ?? "White",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SvgPicture.asset(
                                    "assets/icons/car.svg",
                                    color: Theme.of(context).primaryColor,
                                    width: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    widget.driverData[
                                            'transport_description'] ??
                                        "Toyota",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: Text(
                                  widget.driverData['licence_plate'] ??
                                      "xx-2019",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.green,
            padding: EdgeInsets.all(16),
            child: InkWell(
              onTap: () async {
                var tel = "tel:${widget.taskData['driver_phone']}";

                if (await canLaunch(tel)) {
                  await launch(tel);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.phone_android,
                    color: Colors.white,
                  ),
                  Text(
                    lang.api("Call the Captain"),
                    style: TextStyle(
                      color: Colors.white,
                    ),
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

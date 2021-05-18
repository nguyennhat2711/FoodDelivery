import 'package:afandim/custom_widget/custom_rating_bar.dart';
import 'package:afandim/helper/constance.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/utils.dart';
import 'package:afandim/view/restaurant_details/restaurant_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CartMerchantData extends StatelessWidget {
  final details;

  CartMerchantData({Key key, this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 165,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return MerchantDetailsView(
                  merchantId: details["cart_details"]["merchant_id"],
                );
              }),
            );
          },
          child: Stack(
            children: <Widget>[
              Container(
                child: CachedNetworkImage(
                  imageUrl: details["merchant"]["background_url"],
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: 165,
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        lang.api("Click to add more items"),
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                    CustomRatingBar(
                      onChanged: (value) {},
                      size: 12,
                      numStars: 5,
                      rating: customRound(
                          double.parse("${details["merchant"]["rating"]}"), 1),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black38,
                        Colors.black38,
                      ],
                      stops: [0.5, 0.5],
                    ),
                  ),
                  child: Text(
                    lang.api(details["merchant"]["restaurant_name"]),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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

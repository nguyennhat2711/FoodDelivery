import 'package:flutter/material.dart';

class PriceWidget extends StatelessWidget {
  final String price;
  final String oldPrice;

  const PriceWidget({Key key, this.price, this.oldPrice,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return getPrice();
  }

  Widget getPrice(){
    return RichText(
//      textDirection: TextDirection.ltr,
//      textAlign: lang.isRtl()? TextAlign.end: TextAlign.start,
      text: new TextSpan(
        children: <TextSpan>[
          oldPrice == null? TextSpan() : TextSpan(
            text: "$oldPrice  ",
            style: new TextStyle(
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
              fontFamily: "Roboto"
            ),
          ),
          TextSpan(
            text: "$price",
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Roboto"
            ),
          ),
        ],
      ),
    );

  }
}

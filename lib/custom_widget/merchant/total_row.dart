import 'package:flutter/material.dart';

class TotalRow extends StatelessWidget {

  final String text;
  final String value;
  final bool boldValue;
  final double valueFontSize;

  const TotalRow({
    Key key,
    this.text,
    this.value,
    this.boldValue = false,
    this.valueFontSize = 16
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return getTotalRow();
  }

  Widget getTotalRow(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: boldValue? FontWeight.bold: FontWeight.normal,
              fontFamily: "Roboto",
              fontSize: valueFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

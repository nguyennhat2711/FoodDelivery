import 'package:flutter/material.dart';

class ServiceBadge extends StatelessWidget {
  final String text;
  final Widget icon;

  const ServiceBadge({Key key, this.text, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      margin: EdgeInsets.fromLTRB(2, 8, 2, 2),
      padding: EdgeInsets.all(icon != null ? 4 : 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ?? Container(),
          SizedBox(
            width: 4,
          ),
          Text(
            getClearValue(text ?? ""),
            style: TextStyle(
              fontFamily: "Roboto",
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String getClearValue(String value) {
    return value.replaceAll(".0", "");
  }
}

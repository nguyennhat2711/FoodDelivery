import 'package:flutter/material.dart';

class DividerMiddleText extends StatelessWidget {
  final String text;

  const DividerMiddleText({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
        child: new Container(
          child: Divider(
            color: Colors.grey,
            height: 1,
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(text),
      ),
      Expanded(
        child: new Container(
          child: Divider(
            color: Colors.grey,
            height: 1,
          ),
        ),
      ),
    ]);
  }
}

import 'package:flutter/material.dart';

class GreyButton extends StatelessWidget {
  final Widget child;
  final Color color;
  const GreyButton({
    Key key,
    this.child,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
//      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: color ?? Colors.grey[300],
          borderRadius: BorderRadius.circular(8)
      ),
      child: child,
    );
  }
}

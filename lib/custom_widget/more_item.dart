import 'package:flutter/material.dart';

class MoreItem extends StatelessWidget{
  final icon;
  final String label;
  final onTap;
  final bool hasArrow;
  final color;
  final arrowColor;
  final bool isTextBold;
  MoreItem({
    @required this.label,
    @required this.onTap,
    this.icon = Icons.settings,
    this.hasArrow = true,
    this.color,
    this.arrowColor, this.isTextBold = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                icon is Icons? Icon(
                  this.icon,
                  color: color ?? Colors.grey,
                ): icon is Widget? icon: Container(),
                SizedBox(width: 8,),
                Text(this.label, style: TextStyle(
                  color: color ?? Colors.black,
                  fontWeight: isTextBold? FontWeight.bold: FontWeight.normal
                ),)
              ],
            ),
            hasArrow? Icon(
              Icons.chevron_right,
              color: arrowColor ?? Theme.of(context).primaryColor,
            ): Container(),
          ],
        ),
      ),
      onTap: this.onTap,
    );
  }
}
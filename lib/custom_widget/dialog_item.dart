import 'package:afandim/helper/constance.dart';
import 'package:flutter/material.dart';

class DialogItem extends StatelessWidget {
  final String label;
  final icon;
  final onTap;

  DialogItem({
    @required this.icon,
    @required this.label,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            children: <Widget>[
              this.icon is IconData
                  ? Icon(
                      this.icon,
                      size: 32,
                      color: primaryColor,
                    )
                  : this.icon,
              Text(
                this.label,
                style: TextStyle(
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: this.onTap,
    );
  }
}

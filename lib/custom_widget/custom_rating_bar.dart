import 'dart:math';

import 'package:afandim/helper/constance.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';

class CustomRatingBar extends StatelessWidget {
  final int numStars;
  final double rating;
  final double size;
  final bool isInt;
  final ValueChanged<double> onChanged;

  CustomRatingBar(
      {Key key,
      this.numStars = 5,
      this.rating = 0.0,
      this.size = 14.0,
      @required this.onChanged,
      this.isInt = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragDown: (dragDown) {
        RenderBox box = context.findRenderObject();
        var local = box.globalToLocal(dragDown.globalPosition);
        var rating =
            (local.dx / box.size.width * numStars * 2).ceilToDouble() / 2;
        rating = max(0.0, rating);
        rating = min(numStars.toDouble(), rating);
        onChanged(rating);
      },
      onHorizontalDragUpdate: (dragUpdate) {
        RenderBox box = context.findRenderObject();
        var local = box.globalToLocal(dragUpdate.globalPosition);
        var rating =
            (local.dx / box.size.width * numStars * 2).ceilToDouble() / 2;
        rating = max(0.0, rating);
        rating = min(numStars.toDouble(), rating);
        onChanged(rating);
      },
      child: Row(
//        textDirection: TextDirection.ltr,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          numStars,
          (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              child: _buildStar(context, index),
            );
          },
          growable: false,
        ),
      ),
    );
  }

  Widget _buildStar(BuildContext context, int index) {
    Container icon;
    if (index >= rating) {
      icon = Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.star,
          size: size,
          color: Colors.white,
        ),
      );
    } else if (index > rating - 1 && index < rating && !this.isInt) {
      icon = Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey,
          gradient: LinearGradient(
            begin: lang.isRtl() ? Alignment.centerRight : Alignment.centerLeft,
            end: lang.isRtl() ? Alignment.centerLeft : Alignment.centerRight,
            colors: [
              primaryColor,
              Colors.grey,
            ],
            stops: [0.00, 0.5],
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.star,
          size: size,
          color: Colors.white,
        ),
      );
    } else {
      icon = Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.star,
          size: size,
          color: Colors.white,
        ),
      );
    }
    return icon;
  }
}

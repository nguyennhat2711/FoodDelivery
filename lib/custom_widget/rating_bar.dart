import 'dart:math';

import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  RatingBar({
    this.numStars = 5,
    this.rating = 0.0,
    this.size = 30.0,
    @required this.onChanged,
    this.isInt = false
  });

  final int numStars;
  final double rating;
  final double size;
  final bool isInt;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragDown: (dragDown) {
        RenderBox box = context.findRenderObject();
        var local = box.globalToLocal(dragDown.globalPosition);
        var rating = (local.dx / box.size.width * numStars * 2).ceilToDouble() /
            2;
        rating = max(0.0, rating);
        rating = min(numStars.toDouble(), rating);
        onChanged(rating);
      },
      onHorizontalDragUpdate: (dragUpdate) {
        RenderBox box = context.findRenderObject();
        var local = box.globalToLocal(dragUpdate.globalPosition);
        var rating = (local.dx / box.size.width * numStars * 2).ceilToDouble() /
            2;
        rating = max(0.0, rating);
        rating = min(numStars.toDouble(), rating);
        onChanged(rating);
      },
      child: Row(
        textDirection: TextDirection.ltr,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
            numStars, (index) => _buildStar(context, index),
            growable: false,
        ),
      ),
    );
  }

  Widget _buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = Icon(
        Icons.star_border,
        size: size,
        color: Theme
            .of(context)
            .primaryColor,
      );
    } else if (index > rating - 1 && index < rating && !this.isInt) {
      icon = Icon(
        Icons.star_half,
        size: size,
        color: Theme
            .of(context)
            .primaryColor,
      );
    } else {
      icon = Icon(
        Icons.star,
        size: size,
        color: Theme
            .of(context)
            .primaryColor,
      );
    }
    return icon;
  }
}
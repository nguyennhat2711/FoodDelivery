import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';

class IdleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(Icons.explore, size: 40),
          SizedBox(height: 16),
          Text(
            lang.api("Start typing to find what you want."),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';

Widget buildLoadingWidget([String message]) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircularProgressIndicator(),
        SizedBox(
          height: 16,
        ),
        Text(
          message ?? lang.api("loading"),
        ),
      ],
    ),
  );
}

Widget buildEmptyWidget(BuildContext context, [String message]) {
  return Center(
    child: Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.hourglass_empty,
              size: 120,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              message ?? lang.api("No data found"),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

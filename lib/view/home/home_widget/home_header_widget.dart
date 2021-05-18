import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/custom_widget/rounded_button.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final String subTitle;
  final Function onViewAllTap;
  final bool showViewAll;
  const HomeHeader(
      {Key key,
      this.title,
      this.subTitle,
      this.onViewAllTap,
      this.showViewAll = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subTitle != null && subTitle.length > 0
                    ? Text(
                        subTitle,
                        style: TextStyle(color: Colors.grey),
                      )
                    : Container(),
              ],
            ),
          ),
          SizedBox(
            width: 16,
          ),
          showViewAll
              ? Container(
                  height: 28,
                  child: RoundedButton(
                    onPressed: onViewAllTap,
                    color: Theme.of(context).primaryColor,
                    isOutline: false,
                    child: Text(
                      lang.api("See All"),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

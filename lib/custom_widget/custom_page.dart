import 'package:afandim/helper/constance.dart';
import 'package:flutter/material.dart';

class CustomPage extends StatelessWidget {
  final Widget child;
  final Widget floatingActionButton;
  final onRefresh;
  final scaffoldKey;
  const CustomPage(
      {Key key,
      this.child,
      this.floatingActionButton,
      this.scaffoldKey,
      this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/background.jpg"),
                    fit: BoxFit.cover),
              ),
//              color: primaryColor,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              color: primaryColor.withOpacity(0.6),
            ),
          ),
          SafeArea(
            child: onRefresh == null
                ? getScrollableChild()
                : RefreshIndicator(
                    onRefresh: onRefresh,
                    child: getScrollableChild(),
                  ),
          )
        ],
      ),
    );
  }

  Widget getScrollableChild() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 12),
        child: child,
      ),
    );
  }
}

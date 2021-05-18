import 'package:flutter/material.dart';

import 'dialog_utils.dart';

class Closable extends StatefulWidget {
  final Widget child;

  const Closable({Key key, this.child}) : super(key: key);

  @override
  _ClosableState createState() => _ClosableState();
}

class _ClosableState extends State<Closable> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: widget.child,
        onWillPop: onWillPop,
      ),
    );
  }

  Future<bool> onWillPop() {
    return _showDialog();
  }

  Future<bool> _showDialog() async {
    // flutter defined function
    var status = await showCustomErrorDialog();
    return status ?? false;
  }
}

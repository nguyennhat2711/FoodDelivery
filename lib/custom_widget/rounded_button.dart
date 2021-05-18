import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final bool isOutline;
  const RoundedButton({
    Key key,
    this.child,
    this.onPressed,
    this.color,
    this.isOutline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (isOutline) ?OutlineButton(
      borderSide: BorderSide(
        color: this.color ?? Theme.of(context).primaryColor, //Color of the border
        style: BorderStyle.solid, //Style of the border
        width: 1, //width of the border
      ),
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(40.0),
      ),
      onPressed: this.onPressed,
      child: this.child,
    ) : RaisedButton(
      color: this.color ?? Theme.of(context).primaryColor,
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(40.0),
      ),
      onPressed: this.onPressed,
      child: this.child,
    );
  }
}

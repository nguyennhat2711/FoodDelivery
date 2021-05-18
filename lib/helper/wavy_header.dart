import 'package:flutter/material.dart';

class WavyHeader extends StatelessWidget {
  final Widget child;
  final Color color;
  const WavyHeader({Key key, this.child, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      child: Container(
        width: double.infinity,
        height: 100,
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: color ?? Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16.0)
        ),
        child: child ?? Container(),
      ),

      clipper: BottomWaveClipper(),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height - 20);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
    Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
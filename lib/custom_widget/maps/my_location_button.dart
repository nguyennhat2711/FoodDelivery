import 'package:flutter/material.dart';

class MyLocationButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData iconData;
  const MyLocationButton({
    Key key,
    this.onTap,
    this.iconData = Icons.my_location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4))),
          child: Icon(
            iconData,
            size: 24,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

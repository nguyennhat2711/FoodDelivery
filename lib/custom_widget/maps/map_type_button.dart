import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTypeButton extends StatefulWidget {
  final MapType mapType;
  final Function(MapType) onMapTypeChanged;

  const MapTypeButton({Key key, this.mapType, this.onMapTypeChanged}) : super(key: key);

  @override
  _MapTypeButtonState createState() => _MapTypeButtonState();
}

class _MapTypeButtonState extends State<MapTypeButton> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          if (widget.mapType == MapType.normal) {
            widget.onMapTypeChanged(MapType.hybrid);
          } else {
            widget.onMapTypeChanged(MapType.normal);
          }
        },
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4))),
          child: Icon(
            Icons.map,
            size: 24,
            color: widget.mapType == MapType.normal? Colors.grey: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

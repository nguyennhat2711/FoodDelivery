import 'dart:async';
import 'dart:typed_data';

import 'package:afandim/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final Map currentLocation;

  const MapWidget({Key key, this.currentLocation}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  BitmapDescriptor markerIcon;
  LatLng initLatLng = LatLng(0.0, 0.0);
  Marker currentMarker = Marker(
    markerId: MarkerId(LatLng(0, 0).toString()),
    position: LatLng(0, 0),
  );

  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    print("currentLocation: ${widget.currentLocation}");
    final Uint8List markerIconList =
        await getBytesFromAsset("assets/images/marker_orange.png", 120);
    markerIcon = BitmapDescriptor.fromBytes(markerIconList);
    currentMarker = currentMarker.copyWith(
        positionParam: initLatLng, iconParam: markerIcon);
    setState(() {});
  }

  LatLng getLocation() {
    if (widget.currentLocation == null) {
      initLatLng = LatLng(0.0, 0.0);
    } else {
      initLatLng = LatLng(double.parse("${widget.currentLocation["latitude"]}"),
          double.parse("${widget.currentLocation["longitude"]}"));
    }
    return initLatLng;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      onMapCreated: _onMapCreated,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      markers: getMarkers().toSet(),
      initialCameraPosition: CameraPosition(
        target: getLocation(),
        zoom: 18.0,
      ),
    );
  }

  List<Marker> getMarkers() {
    if (markerIcon == null) {
      return [];
    }
    return [currentMarker.copyWith(iconParam: markerIcon)];
  }

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    mapController = controller;

    // getJsonFile("assets/map_styles/silver.json").then((String mapStyle){mapController.setMapStyle(mapStyle);});
    if (widget.currentLocation != null) {
      LatLng latLng = LatLng(
          double.parse("${widget.currentLocation["latitude"]}"),
          double.parse("${widget.currentLocation["longitude"]}"));

      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: latLng,
          zoom: 17.0,
        ),
      ));
    }
  }
}

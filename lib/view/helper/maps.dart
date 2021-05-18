import 'dart:async';
import 'dart:typed_data';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/maps/map_type_button.dart';
import 'package:afandim/custom_widget/maps/my_location_button.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/location_utils.dart';
import 'package:afandim/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Maps extends StatefulWidget {
  final Map currentLocation;
  final bool greenMarker;
  final Map addressDetails;
  const Maps(
      {Key key,
      this.currentLocation,
      this.greenMarker = true,
      this.addressDetails})
      : super(key: key);

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  LatLng initLatLng = LatLng(0.0, 0.0);
  Marker currentMarker = Marker(
    markerId: MarkerId(LatLng(0, 0).toString()),
    position: LatLng(0, 0),
  );
//  final _prefManager = PrefManager();
  final _repository = Repository();
  var _mapType = MapType.normal;
  String title;
  String subtitle;
  bool loading = false;
  BitmapDescriptor markerIcon;

  @override
  initState() {
    super.initState();

    init();
  }

  init() async {
    if (widget.currentLocation == null ||
        widget.currentLocation["latitude"].toString().isEmpty) {
      String lat = "${lang.settings["default_map_location"]["lat"]}";
      String lng = "${lang.settings["default_map_location"]["lng"]}";
      if (lng.isEmpty && lat.isEmpty) {
        initLatLng = LatLng(41.012366, 28.931426);
      } else {
        initLatLng = LatLng(double.parse(lat), double.parse(lng));
      }
    } else {
      initLatLng = LatLng(double.parse("${widget.currentLocation["latitude"]}"),
          double.parse("${widget.currentLocation["longitude"]}"));
    }

    final Uint8List markerIconList = await getBytesFromAsset(
        widget.greenMarker
            ? "assets/images/marker_green.png"
            : "assets/images/marker_orange.png",
        120);
    markerIcon = BitmapDescriptor.fromBytes(markerIconList);
    currentMarker = currentMarker.copyWith(
        positionParam: initLatLng, iconParam: markerIcon);
    setState(() {
      subtitle = lang.api("Search for your location");
    });
  }

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  List<Marker> getMarkers() {
    if (markerIcon == null) {
      return [];
    }
    return [currentMarker.copyWith(iconParam: markerIcon)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          lang.api("Select Location"),
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: _mapType,
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            onTap: _onMapTap,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            markers: getMarkers().toSet(),
            initialCameraPosition: CameraPosition(
              target: initLatLng,
              zoom: 18.0,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Card(
              margin: EdgeInsets.all(16),
              child: InkWell(
                //
                // onTap: () async {
                //   Map item = await Navigator.of(context).push(
                //     MaterialPageRoute(builder: (context) {
                //       return SearchLocation();
                //     }),
                //   );
                //   if(item != null){
                //     LatLng position = new LatLng(item["geometry"]["location"]["lat"], item["geometry"]["location"]["lng"]);
                //     setState(() {
                //       subtitle = item["formatted_address"];
                //     });
                //     mapController.animateCamera(CameraUpdate.newLatLng(position));
                //   }
                // },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xDDFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 18,
                        height: 18,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              title ?? lang.api("YOUR LOCATION"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle == null ? Container() : Text(subtitle),
                          ],
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        child:
                            loading ? CircularProgressIndicator() : Container(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: lang.isRtl()
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  MapTypeButton(
                    mapType: _mapType,
                    onMapTypeChanged: (MapType mapType) {
                      setState(() {
                        _mapType = mapType;
                      });
                    },
                  ),
                  MyLocationButton(
                    onTap: _currentLocation,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(8),
                    child: RaisedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              var result = await getLocationName(
                                  context, widget.addressDetails);
                              if (result != null && result is Map) {
                                subtitle = result["name"];
                                setState(() {});
                                Navigator.of(context).pop({
                                  "formatted_address": result["name"],
                                  "result": result,
                                  "address_components": [],
                                  "location": {
                                    "latitude": currentMarker.position.latitude,
                                    "longitude":
                                        currentMarker.position.longitude
                                  }
                                });
                                return;
                              }

                              // setState(() {
                              //   subtitle = lang.api("IDENTIFY LOCATION");
                              //   loading = true;
                              // });
                              // Map<String, dynamic> response = await _repository.geocode(getMarkerLocation(currentMarker, 10));
                              // loading = false;
                              // if(response["status"] == "OK"){
                              //   subtitle = response["results"][0]["formatted_address"];
                              //   Navigator.of(context).pop(response["results"][0]..addAll({
                              //     "location": {
                              //       "latitude": currentMarker.position.latitude,
                              //       "longitude": currentMarker.position.longitude
                              //     }
                              //   }));
                              // } else {
                              //   subtitle = lang.api("location not available");
                              // }
                              // setState(() {
                              // });
                            },
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text(lang.api("Save location")),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getMarkerLocation(Marker marker, int point) {
    return "${customRound(marker.position.latitude, point)},${customRound(marker.position.longitude, point)}";
  }

  void _onMapTap(LatLng latLng) async {
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(latLng.latitude, latLng.longitude), zoom: 18.0),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    mapController = controller;

    // getJsonFile("assets/map_styles/silver.json").then((String mapStyle){mapController.setMapStyle(mapStyle);});
    if (widget.currentLocation != null &&
        widget.currentLocation["latitude"].toString().isNotEmpty) {
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
    } else {
      _currentLocation();
    }
  }

  void _onCameraMove(CameraPosition position) async {
    setState(() {
      currentMarker = currentMarker.copyWith(positionParam: position.target);
    });
  }

  _currentLocation() async {
    Position locationData = await getCurrentLocation();
    LatLng latLng = LatLng(locationData.latitude, locationData.longitude);

    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: latLng,
        zoom: 17.0,
      ),
    ));
  }
}

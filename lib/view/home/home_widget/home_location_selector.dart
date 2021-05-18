import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/custom_widget/maps/map_type_button.dart';
import 'package:afandim/custom_widget/maps/my_location_button.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/location_utils.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/helper/utils.dart';
import 'package:afandim/view/helper/search_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeLocationSelector extends StatefulWidget {
  final bool greenMarker;
  final Map locationData;
  const HomeLocationSelector(
      {Key key, this.greenMarker = true, this.locationData})
      : super(key: key);

  @override
  _HomeLocationSelectorState createState() => _HomeLocationSelectorState();
}

class _HomeLocationSelectorState extends State<HomeLocationSelector> {
  final _prefManager = PrefManager();
  LatLng initLatLng = LatLng(41.012366, 28.931426);
  Marker currentMarker = Marker(
    markerId: MarkerId(LatLng(41.012366, 28.931426).toString()),
    position: LatLng(41.012366, 28.931426),
  );
  final _repository = Repository();
  var _mapType = MapType.normal;
  String title;
  String subtitle;
  bool loading = false;
  BitmapDescriptor markerIcon;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {
    init();
    super.initState();
  }

  init() async {
    if (widget.locationData == null ||
        widget.locationData["lat"] == null ||
        widget.locationData["lng"] == null) {
      String lat = "${lang.settings["default_map_location"]["lat"]}";
      String lng = "${lang.settings["default_map_location"]["lng"]}";
      if (lng.isEmpty && lat.isEmpty) {
        initLatLng = LatLng(41.012366, 28.931426);
      } else {
        initLatLng = LatLng(double.parse(lat), double.parse(lng));
      }
    } else {
      initLatLng =
          LatLng(widget.locationData["lat"], widget.locationData["lng"]);
    }
    currentMarker = currentMarker.copyWith(positionParam: initLatLng);
    final Uint8List markerIconList = await getBytesFromAsset(
        widget.greenMarker
            ? "assets/images/marker_green.png"
            : "assets/images/marker_orange.png",
        120);
    markerIcon = BitmapDescriptor.fromBytes(markerIconList);

    setState(() {
      subtitle = lang.api("Search for your location");
    });
  }

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

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
                onTap: () async {
                  Map item = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SearchLocation();
                      },
                    ),
                  );
                  if (item != null) {
                    LatLng position = new LatLng(
                        item["geometry"]["location"]["lat"],
                        item["geometry"]["location"]["lng"]);
                    setState(() {
                      subtitle = item["formatted_address"];
                    });
                    mapController
                        .animateCamera(CameraUpdate.newLatLng(position));
                  }
                },
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
                              var result = await getLocationName(context);
                              if (result != null && result is Map) {
                                subtitle = result[
                                    "name"]; //response["results"][0]["formatted_address"];
                                setState(() {});
                                showLoadingDialog();

                                List<geo.Placemark> placemarks =
                                    await geo.placemarkFromCoordinates(
                                        currentMarker.position.latitude,
                                        currentMarker.position.longitude);

                                Map<String, dynamic> locationResponse =
                                    await _repository.setLocation({
                                  "lat": currentMarker.position.latitude,
                                  "lng": currentMarker.position.longitude,
                                  "recent_search_address": placemarks[0].name,
                                  "mapbox_drag_map": true,
                                  "mapbox_drag_end": true,
                                  "street": result["street"],
                                  "city": placemarks[0].subLocality,
                                  "state": placemarks[0].locality,
                                  "zipcode": placemarks[0].postalCode,
                                });
                                // Add address to address list.
                                String cCode = "TR";
                                // if(serverUrl == "https://efendim.biz") {
                                //   cCode = "JO";
                                // }
                                await _repository.saveAddressBook({
                                  "street": result["street"],
                                  "city": result["city"],
                                  "state": result["state"],
                                  "zipcode": "",
                                  "country_code": cCode,
                                  "lat": currentMarker.position.latitude,
                                  "lng": currentMarker.position.longitude,
                                  "location_name": subtitle,
                                });
                                Map<String, dynamic> addressListResponse =
                                    await _repository.getAddressBookDropDown();
                                if (addressListResponse
                                        .containsKey("success") &&
                                    addressListResponse["success"]) {
                                  List list =
                                      addressListResponse["details"]["data"];
                                  final provider =
                                      context.read(generalProvider);

                                  provider.addressList = list;
                                }
                                _prefManager.set(
                                    "location",
                                    json.encode({
                                      "lat": currentMarker.position.latitude,
                                      "lng": currentMarker.position.longitude,
                                      "address": subtitle,
                                    }));
                                Navigator.of(context).pop();
                                if (locationResponse.containsKey("code") &&
                                    locationResponse["code"] == 1) {
                                  Navigator.of(context).pop(true);
                                } else {
                                  showError(
                                      _scaffoldKey, locationResponse["msg"]);
                                }
                                setState(() {});
                              } else {
                                showToast(lang.api(
                                    "You have to write full details for your address"));
                              }
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
    if (widget.locationData != null &&
        widget.locationData["lat"] != null &&
        widget.locationData["lng"] != null) {
//      LatLng latLng = LatLng(widget.currentLocation["latitude"], widget.currentLocation["longitude"]);
      LatLng latLng =
          LatLng(widget.locationData["lat"], widget.locationData["lng"]);

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
    if (!loading) {
      setState(() {
        currentMarker = currentMarker.copyWith(positionParam: position.target);
      });
    }
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

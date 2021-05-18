import 'dart:async';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/maps/map_type_button.dart';
import 'package:afandim/custom_widget/maps/my_location_button.dart';
import 'package:afandim/custom_widget/order/driver_data_widget.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/maps_util.dart';
import 'package:afandim/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:random_color/random_color.dart';

class TrackDriver extends StatefulWidget {
  final String orderId;

  TrackDriver({
    Key key,
    @required this.orderId,
  }) : super(key: key);

  @override
  _TrackDriverState createState() => _TrackDriverState();
}

class _TrackDriverState extends State<TrackDriver> {
  final _repository = Repository();
  var _mapType = MapType.normal;
  bool loading = true;
  bool loadingDriver = true;
  Map data;
  Map driverData;
  Timer timer;
  final _randomColor = RandomColor();

  BitmapDescriptor driverIcon;
  BitmapDescriptor pickupIcon;
  BitmapDescriptor dropOffIcon;

  LatLng driver;
  LatLng pickup;
  LatLng dropOff;
  List<List<LatLng>> route = [];
  List<Polyline> polyline;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {
    init();
    super.initState();
  }

  init() async {
    dropOffIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset("assets/images/marker_green.png", 120));
    pickupIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset("assets/images/marker_orange.png", 120));
    driverIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset("assets/images/marker_driver.png", 120));
    setState(() {
      loading = true;
    });
    Map<String, dynamic> response =
        await _repository.taskInformation(widget.orderId);
    loading = false;
    if (response.containsKey("code") && response["code"] == 1) {
      data = response["details"]["data"];
      print("data: $data");
      if ("${data["driver_lat"]}".isNotEmpty &&
          "${data["driver_lng"]}".isNotEmpty) {
        driver = LatLng(double.parse("${data["driver_lat"]}"),
            double.parse("${data["driver_lng"]}"));
      }
      if ("${data["task_lat"]}".isNotEmpty &&
          "${data["task_lng"]}".isNotEmpty) {
        pickup = LatLng(double.parse("${data["task_lat"]}"),
            double.parse("${data["task_lng"]}"));
      }
      if ("${data["dropoff_lat"]}".isNotEmpty &&
          "${data["dropoff_lng"]}".isNotEmpty) {
        dropOff = LatLng(double.parse("${data["dropoff_lat"]}"),
            double.parse("${data["dropoff_lng"]}"));
      }
      getRoute();
      startTimer();
      setState(() {
        loadingDriver = true;
      });
      Map<String, dynamic> driverDataResponse =
          await _repository.driverInformation("${data["driver_id"]}");
      loadingDriver = false;
      if (driverDataResponse.containsKey("code") &&
          driverDataResponse["code"] == 1) {
        driverData = driverDataResponse["details"]["data"];
      }
      setState(() {});
    }
    setState(() {});
  }

  List<Polyline> getPolyline() {
    polyline = [];
    route.forEach((element) {
      Polyline routePolyline = Polyline(
        polylineId: PolylineId("route"),
        points: element,
        color: route.indexOf(element) == 0
            ? Theme.of(context).primaryColor
            : _randomColor.randomColor(),
        width: 2,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        jointType: JointType.round,
      );
      polyline.add(routePolyline);
    });
    return polyline;
  }

  _zoomOut() {
    List<LatLng> temp = [];
    getMarkers().forEach((element) {
      temp.add(element.position);
    });
    if (temp.isNotEmpty) {
      LatLngBounds bound = boundsFromLatLngList(temp);
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bound, 64));
    }
  }

  void getRoute() async {
    if (dropOff == null || pickup == null) {
      return;
    }
    showLoadingDialog(lang.api("loading"));
    Map<String, dynamic> response = await _repository.getRoute(
        getMarkerLocation(pickup, 10), getMarkerLocation(dropOff, 10));
    Navigator.of(context).pop();
    if (response.containsKey("routes") &&
        response['routes'] is List &&
        response['routes'].length > 0) {
      response["routes"].forEach((element) {
        Map legsInfo;
        if (element["legs"].length > 0) {
          var legs = element["legs"][0];
          legsInfo = {
            "distance": legs["distance"],
            "duration": legs["duration"],
            "end_address": legs["end_address"],
            "end_location": legs["end_location"],
            "start_address": legs["start_address"],
            "start_location": legs["start_location"]
          };
        }
        Map newRoute = {
          "bounds": element["bounds"],
          "points": element["overview_polyline"]["points"],
          "route_info": legsInfo
        };
        setState(() {
          route.add(getRouteList(newRoute));
        });
        _zoomOut();
      });
    } else {
      _zoomOut();
    }
  }

  List<LatLng> getRouteList(Map routeData) {
    Map bounds = routeData['bounds'];
    LatLngBounds bound = boundsFromLatLngList([
      LatLng(bounds['northeast']['lat'], bounds['northeast']['lng']),
      LatLng(bounds['southwest']['lat'], bounds['southwest']['lng']),
    ]);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bound, 60));
    List<LatLng> route = decodeEncodedPolyline(routeData["points"]);
    return route;
  }

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 7), (timer) async {
      if (data != null) {
        Map<String, dynamic> response =
            await _repository.trackDriver(widget.orderId, data["driver_id"]);
        if (response.containsKey("code") && response["code"] == 1) {
          var trackData = response["details"]["data"];
          setState(() {
            driver = LatLng(double.parse("${trackData["location_lat"]}"),
                double.parse("${trackData["location_lng"]}"));
          });
        }
      }
    });
  }

  List<Marker> getMarkers() {
    if (loading || data == null) {
      return [];
    }
    List<Marker> markers = [];
    if (dropOff != null) {
      markers.add(Marker(
        markerId: MarkerId(dropOff.toString()),
        infoWindow: InfoWindow(
          title: data["dropoff_contact_name"],
          snippet: data["drop_address"],
        ),
        position: dropOff,
        icon: dropOffIcon,
      ));
    }
    if (pickup != null) {
      markers.add(Marker(
        markerId: MarkerId(pickup.toString()),
        position: pickup,
        infoWindow: InfoWindow(
            title: data["customer_name"], snippet: data["delivery_address"]),
        icon: pickupIcon,
      ));
    }

    if (driver != null) {
      markers.add(Marker(
        markerId: MarkerId(driver.toString()),
        position: driver,
        infoWindow: InfoWindow(
            title: data["driver_name"], snippet: data["driver_phone"]),
        icon: driverIcon,
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          lang.api("Driver Location"),
        ),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                GoogleMap(
                  mapType: _mapType,
                  onMapCreated: _onMapCreated,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  markers: getMarkers().toSet(),
                  polylines: getPolyline().toSet(),
                  initialCameraPosition: CameraPosition(
                    target: LatLng(41.012366, 28.931426),
                    zoom: 10.0,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: EdgeInsets.all(8),
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
                          iconData: Icons.zoom_out_map,
                          onTap: _zoomOut,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading || loadingDriver
              ? Container(
                  padding: EdgeInsets.all(16),
                  child: LoadingWidget(
                    useLoader: true,
                    message: lang.api("Loading driver data"),
                    size: 62,
                  ),
                )
              : Container(
                  child: Column(
                    children: <Widget>[
                      DriverDataWidget(
                          taskData: data,
                          driverData: driverData,
                          loadingDriver: loadingDriver),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  String getMarkerLocation(LatLng position, int point) {
    return "${customRound(position.latitude, point)},${customRound(position.longitude, point)}";
  }

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    mapController = controller;
    // getJsonFile("assets/map_styles/silver.json").then((String mapStyle){mapController.setMapStyle(mapStyle);});

    _zoomOut();
  }
}

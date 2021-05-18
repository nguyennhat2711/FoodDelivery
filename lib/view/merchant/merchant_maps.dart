import 'dart:async';
import 'dart:typed_data';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/maps/map_type_button.dart';
import 'package:afandim/custom_widget/maps/my_location_button.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/maps_util.dart';
import 'package:afandim/helper/utils.dart';
import 'package:afandim/model/search_merchant.dart';
import 'package:afandim/view/home/home_widget/all_restaurant_card_widget.dart';
import 'package:afandim/view/restaurant_details/restaurant_details_view.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MerchantMaps extends StatefulWidget {
  final List<SearchMerchantList> list;

  MerchantMaps({Key key, this.list}) : super(key: key);

  @override
  _MerchantMapsState createState() => _MerchantMapsState();
}

class _MerchantMapsState extends State<MerchantMaps> {
  final _repository = Repository();
  var _mapType = MapType.normal;
  String title;
  String subtitle;
  bool loading = false;
  BitmapDescriptor markerIcon;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool fullView = false;
  Map<String, BitmapDescriptor> markerIcons = {};

  @override
  initState() {
    init();
    super.initState();
  }

  init() async {
    final Uint8List markerIconList =
        await getBytesFromAsset("assets/images/marker_orange.png", 120);
    markerIcon = BitmapDescriptor.fromBytes(markerIconList);
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

    List<Marker> markers = [];
    widget.list.forEach((e) {
      SearchMerchantList element = e;
      if ("${element.latitude}".isNotEmpty &&
          "${element.lontitude}".isNotEmpty) {
        String index = "${element.merchantId}";
//        print(index);
        if (markerIcons[index] == null) {
          markerIcons[index] = markerIcon;
        }
        LatLng latLng = LatLng(double.parse("${element.latitude}"),
            double.parse("${element.lontitude}"));
        markers.add(Marker(
            markerId: MarkerId(latLng.toString()),
            position: latLng,
            icon: markerIcons[index],
            infoWindow: InfoWindow(
                title: element.restaurantName,
                snippet: element.cuisine,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return MerchantDetailsView(
                        searchMerchantList: element,
                      );
                    }),
                  );
                })));
      }
    });
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          lang.api("Locations on maps"),
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: _mapType,
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            padding: EdgeInsets.only(bottom: 240),
            markers: getMarkers().toSet(),
            initialCameraPosition: CameraPosition(
              target: LatLng(41.012366, 28.931426),
              zoom: 12.0,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
//              margin: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: lang.isRtl()
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: MapTypeButton(
                      mapType: _mapType,
                      onMapTypeChanged: (MapType mapType) {
                        setState(() {
                          _mapType = mapType;
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: MyLocationButton(
                      onTap: () {
                        _zoomOut();
                        setState(() {
                          fullView = true;
                        });
                      },
                      iconData: Icons.zoom_out_map,
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(bottom: 16, top: 8),
                      child: CarouselSlider.builder(
                        itemCount: widget.list.length,
                        itemBuilder: (BuildContext context, int index, int ss) {
                          if (widget.list.isNotEmpty) {
                            return MerchantCard(
                              item: widget.list[index],
                              showOffers: false,
                            );
                          } else {
                            return Container();
                          }
                        },
                        options: CarouselOptions(
                          autoPlay: false,
//                        pauseAutoPlayOnManualNavigate: true,
                          height: 224,
                          enableInfiniteScroll: false,
                          onPageChanged: (int index,
                              CarouselPageChangedReason changedReason) {
                            if (changedReason ==
                                CarouselPageChangedReason.manual) {
                              fullView = true;
                            }
                            if (changedReason ==
                                    CarouselPageChangedReason.manual ||
                                !fullView && getMarkers().isNotEmpty) {
                              mapController.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                      target: getMarkers()[index].position,
                                      zoom: 18.0),
                                ),
                              );
                            }
                          },
                        ),
                      )),
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

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    mapController = controller;
    _zoomOut();
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

  void _onCameraMove(CameraPosition position) async {}
}

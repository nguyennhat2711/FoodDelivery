import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/helper/consts.dart';
import 'package:afandim/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'global_translations.dart';

Future<Position> getCurrentLocation() async {
  bool servicesEnable;
  LocationPermission permission;

  servicesEnable = await Geolocator.isLocationServiceEnabled();
  if (!servicesEnable) {
    return Future.error('Location Services are Disable ');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
}

Future getLocationName(BuildContext context, [Map addressDetails]) async {
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  var name = staticLocations[0];
  if (addressDetails != null) {
    streetController.text = addressDetails["street"] ?? "";
    cityController.text = addressDetails["city"] ?? "";
    stateController.text = addressDetails["state"] ?? "";
    if (addressDetails["name"] != null) {
      for (int i = 0; i < staticLocations.length; i++) {
        if (staticLocations[i]["name"] == addressDetails["name"]) {
          name = staticLocations[i];
          break;
        }
      }
    }
  }

  var result = await showModalBottomSheet(
    context: context,
    enableDrag: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    lang.api("Description"),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: TextFormField(
                    controller: streetController,
                    textInputAction: TextInputAction.next,
                    minLines: 10,
                    maxLines: 10,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      hintText: lang.api("Write a label for your location"),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                        gapPadding: 0,
                      ),
                      hasFloatingPlaceholder: false,
                    ),
                  ),
                ),
                AlternativeButton(
                  label: lang.api("Select location"),
                  onPressed: () {
                    if (streetController.text.isNotEmpty) {
                      Navigator.of(context).pop({
                        "name": name["name"],
                        "street": streetController.text,
                        "city": cityController.text,
                        "state": stateController.text,
                      });
                    } else {
                      showToast(lang.api(
                          "You have to write full details for your address"));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result;
}

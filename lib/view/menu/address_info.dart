import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/helper/maps.dart';
import 'package:flutter/material.dart';

class AddressInfo extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Map<String, dynamic> request;

  AddressInfo({
    Key key,
    @required this.onComplete,
    this.request,
  }) : super(key: key);

  @override
  _AddressInfoState createState() => _AddressInfoState();
}

class _AddressInfoState extends State<AddressInfo> {
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final _locationController = TextEditingController();
  final deliveryDistanceCoveredController = TextEditingController();

  final cityFocusNode = new FocusNode();
  final postCodeFocusNode = new FocusNode();
  final stateFocusNode = new FocusNode();
  final deliveryFocusNode = new FocusNode();

  String errorMessage = "";
  Map locationMap;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    if (widget.request != null) {
      streetController.text = widget.request["street"] ?? "";
      cityController.text = widget.request["city"] ?? "";
      stateController.text = widget.request["state"] ?? "";

      deliveryDistanceCoveredController.text =
          widget.request["delivery_distance_covered"] ?? "";
      locationMap = {
        "latitude": widget.request["latitude"] ?? "",
        "longitude": widget.request["lontitude"] ?? "",
      };
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, right: 16, left: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                var result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return Maps(
                      greenMarker: false,
                      currentLocation: locationMap,
                    );
                  }),
                );
                if (result != null) {
                  _locationController.text = result["formatted_address"];

                  cityController.text = result["result"]["city"];
                  stateController.text = result["result"]["state"];
                  streetController.text = result["result"]["street"];
                  locationMap = result["location"];
                }
              },
              child: AlternativeTextField(
                controller: _locationController,
                enabled: false,
                prefix: Icon(
                  Icons.map,
                  color: Theme.of(context).primaryColor,
                ),
                fontColor: Colors.grey,
                hint: lang.api("Location on Map"),
              ),
            ),
            AlternativeTextField(
              controller: streetController,
              hint: lang.api("Street Address"),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (String text) {
                FocusScope.of(context).requestFocus(cityFocusNode);
              },
            ),
            AlternativeTextField(
              controller: stateController,
              focusNode: stateFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (String text) {
                FocusScope.of(context).requestFocus(deliveryFocusNode);
              },
              hint: lang.api("Building no"),
            ),
            AlternativeTextField(
              controller: cityController,
              focusNode: cityFocusNode,
              hint: lang.api("Floor"),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (String text) {
                FocusScope.of(context).requestFocus(postCodeFocusNode);
              },
            ),
            AlternativeTextField(
              controller: deliveryDistanceCoveredController,
              focusNode: deliveryFocusNode,
              hint: lang.api("Delivery distance covered(KM)"),
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            errorMessage.isEmpty
                ? Container()
                : Container(
                    padding: EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            AlternativeButton(
              label: lang.api("Submit"),
              onPressed: () {
                if (streetController.text.isEmpty) {
                  errorMessage = lang.api("Street Address is required");
                } else if (cityController.text.isEmpty) {
                  errorMessage = lang.api("City is required");
                } else if (deliveryDistanceCoveredController.text.isEmpty) {
                  errorMessage =
                      lang.api("Delivery distance covered is required");
                } else if (stateController.text.isEmpty) {
                  errorMessage = lang.api("State/Region is required");
                } else {
                  Map<String, dynamic> request = {
                    "street": streetController.text,
                    "city": cityController.text,
                    "post_code": "",
                    "state": stateController.text,
                    "latitude": locationMap["latitude"],
                    "lontitude": locationMap["longitude"],
                    "distance_unit": "km",
                    "delivery_distance_covered":
                        deliveryDistanceCoveredController.text,
                  };
                  widget.onComplete(request);
                  return;
                }
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

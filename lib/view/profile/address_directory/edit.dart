import 'package:afandim/core/services/repository.dart';
import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/view/helper/maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditAddressDirectory extends StatefulWidget {
  final String id;

  const EditAddressDirectory({Key key, this.id}) : super(key: key);

  @override
  _EditAddressDirectoryState createState() => _EditAddressDirectoryState();
}

class _EditAddressDirectoryState extends State<EditAddressDirectory> {
  final _repository = Repository();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _locationController = TextEditingController();
  Map location;
  bool isLoading = true;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    Map<String, dynamic> response =
        await _repository.getAddressBookById(widget.id);
    isLoading = false;
    var data = response["details"]["data"];
    print("data: $data");
    _streetController.text = data["street"];
    _stateController.text = data["state"];
    _cityController.text = data["city"];
    _zipCodeController.text = data["zipcode"];
    _locationController.text = data["location_name"];
    location = {
      "latitude": double.parse(data["latitude"]),
      "longitude": double.parse(data["longitude"])
    };
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      scaffoldKey: _scaffoldKey,
      child: isLoading
          ? Card(
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 4,
              child: Container(
                height: MediaQuery.of(context).size.height / 1.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.0),
                    Text(
                      lang.api("Edit Address"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    LoadingWidget(),

                    /// todo :
                    // SpinKitThreeBounce(
                    //   size: 82.0,
                    //   color: Theme.of(context).primaryColor,
                    // ),
                    Text(
                      lang.api("Loading..."),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        bool delete = await showCustomErrorDialog(
                            lang.api("Delete this address"),
                            lang.api("Are you sure?"),
                            lang.api("Yes"));
                        if (delete) {
                          showLoadingDialog();
                          Map<String, dynamic> response =
                              await _repository.deleteAddressBook(widget.id);
                          Navigator.of(context).pop();
                          if (response.containsKey("code") &&
                              response["code"] == 1) {
                            Navigator.of(context).pop(true);
                          } else {
                            showError(_scaffoldKey, response["msg"]);
                          }
                        }
//              deleteAddressBook
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Card(
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 16.0),
                        Text(
                          lang.api("Edit Address"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: () async {
                            var result = await Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return Maps(
                                  currentLocation: location,
                                  addressDetails: {
                                    "street": _streetController.text,
                                    "city": _cityController.text,
                                    "state": _stateController.text,
                                    "name": _locationController.text,
                                  },
                                );
                              }),
                            );
                            if (result != null) {
                              location = result["location"];
                              _locationController.text =
                                  result["result"]["name"];
                              _cityController.text = result["result"]["city"];
                              _stateController.text = result["result"]["state"];
                              _streetController.text =
                                  result["result"]["street"];
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
                          controller: _streetController,
                          hint: lang.api("Street"),
                        ),
                        AlternativeTextField(
                          controller: _stateController,
                          hint: lang.api("Building no"),
                        ),
                        AlternativeTextField(
                          controller: _cityController,
                          hint: lang.api("Floor"),
                        ),
//                  AlternativeTextField(
//                    controller: _zipCodeController,
//                    hint: lang.api("Zip Code"),
//                  ),
                        AlternativeButton(
                          label: lang.api("Save"),
                          onPressed: () async {
                            showLoadingDialog();
                            String cCode = "JO";
                            final provider = context.read(generalProvider);
                            if (provider.apiUrl.contains("tr.efendim.biz")) {
                              cCode = "TR";
                            }

                            Map<String, dynamic> response =
                                await _repository.saveAddressBook({
                              "street": _streetController.text,
                              "city": _cityController.text,
                              "state": _stateController.text,
                              "zipcode": _zipCodeController.text,
                              "id": widget.id,
                              "country_code": cCode, // JO
                              "location_name": _locationController.text,
                              "lat": location["latitude"],
                              "lng": location["longitude"],
                            });
                            Navigator.of(context).pop();
                            if (response.containsKey("code") &&
                                response["code"] == 1) {
                              Navigator.of(context).pop(true);
                            } else {
                              showError(_scaffoldKey, response["msg"]);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

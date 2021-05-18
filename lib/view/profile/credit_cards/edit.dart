import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_dropdown_list.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditCard extends StatefulWidget {
  final String ccId;

  const EditCard({Key key, this.ccId}) : super(key: key);

  @override
  _EditCardState createState() => _EditCardState();
}

class _EditCardState extends State<EditCard> {
  final _repository = Repository();
  final _nameController = TextEditingController();
  final _cvvController = TextEditingController();
  final _numberController = TextEditingController();
  final _addressController = TextEditingController();
  var year;
  var month;
  List months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec'
  ];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await _repository.getCreditCartInfo("${widget.ccId}");
    setState(() {
      isLoading = false;
    });
    if (response.containsKey("code") && response["code"] == 1) {
      var data = response["details"]["data"];
      _nameController.text = data["card_name"];
      _numberController.text = data["credit_card_number"];
      _cvvController.text = data["cvv"];
      _addressController.text = data["billing_address"];
      month = {"id": months[int.parse(data["expiration_month"]) - 1]};
      year = {"id": data["expiration_yr"]};
    }
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
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
                      lang.api("Edit Card Details"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),

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
                            lang.api("Delete credit card"),
                            lang.api("Are you sure?"),
                            lang.api("Yes"));
                        if (delete) {
                          Navigator.of(context).pop();
                        }
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
                          lang.api("Edit Card Details"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        AlternativeTextField(
                          controller: _nameController,
                          hint: lang.api("Cardholders Name"),
                          prefix: SvgPicture.asset(
                            "assets/icons/user.svg",
                            color: Colors.grey,
                            width: 24,
                          ),
                        ),
                        AlternativeTextField(
                          controller: _numberController,
                          hint: lang.api("Credit Card Number"),
                          keyboardType: TextInputType.number,
                          prefix: SvgPicture.asset(
                            "assets/icons/credit-card.svg",
                            color: Colors.grey,
                            width: 24,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: AlternativeDropdownList(
                                key: UniqueKey(),
                                labels: List.generate(
                                    45,
                                    (index) => {
                                          "name":
                                              "${DateTime.now().year + index}",
                                          "index": index,
                                          "id": "${DateTime.now().year + index}"
                                        }),
//                                    prefix: Text("YY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                displayLabel: "name",
                                selectedId:
                                    year != null ? "${year["id"]}" : null,
                                onChange: (item) {
                                  setState(() {
                                    year = item;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: AlternativeDropdownList(
                                key: UniqueKey(),
                                labels: List.generate(
                                    months.length,
                                    (index) => {
                                          "name": lang.api(months[index]),
                                          "index": index,
                                          "id": months[index],
                                        }),
//                                    prefix: Text("MM", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                displayLabel: "name",
                                selectedId:
                                    month != null ? "${month["id"]}" : null,
                                onChange: (item) {
                                  setState(() {
                                    month = item;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        AlternativeTextField(
                          controller: _cvvController,
                          hint: lang.api("CVV"),
                          isPassword: true,
                          keyboardType: TextInputType.number,
                          prefix: SvgPicture.asset(
                            "assets/icons/lock.svg",
                            color: Colors.grey,
                            width: 24,
                          ),
                        ),
                        AlternativeTextField(
                          controller: _addressController,
                          hint: lang.api("Billing Address"),
                          prefix: SvgPicture.asset(
                            "assets/icons/home.svg",
                            color: Colors.grey,
                            width: 24,
                          ),
                        ),
                        AlternativeButton(
                          label: lang.api("Save"),
                          onPressed: () {
                            Navigator.of(context).pop();
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

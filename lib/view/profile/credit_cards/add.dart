import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_dropdown_list.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AddCard extends StatefulWidget {
  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
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

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
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
                    lang.api("Add New Card"),
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
                                    "name": "${DateTime.now().year + index}",
                                    "index": index,
                                    "id": "${DateTime.now().year + index}"
                                  }),
//                                    prefix: Text("YY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                          displayLabel: "name",
                          selectedId: year != null ? "${year["id"]}" : null,
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
                          selectedId: month != null ? "${month["id"]}" : null,
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

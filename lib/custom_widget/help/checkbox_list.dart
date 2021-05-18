import 'package:afandim/helper/constance.dart';
import 'package:flutter/material.dart';

class CheckboxList extends StatefulWidget {
  final List<Map<String, dynamic>> list;
  final String labelKey;
  final String idKey;
  final Function(Map<String, dynamic> data) onSelect;
  final Map<String, bool> selectedValues;

  final bool twoColumns;

  CheckboxList({
    Key key,
    @required this.list,
    @required this.onSelect,
    this.labelKey = "name",
    this.idKey = "id",
    @required this.selectedValues,
    this.twoColumns = false,
  }) : super(key: key);

  @override
  _CheckboxListState createState() =>
      _CheckboxListState(checkBoxListControllers: selectedValues);
}

class _CheckboxListState extends State<CheckboxList> {
  Map<String, bool> checkBoxListControllers;

  _CheckboxListState({this.checkBoxListControllers = const {}});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListView.builder(
          itemCount: widget.list.length,
          primary: false,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            if (widget.twoColumns) {
              int index1 = index;
              int index2 = index + 1;
              if (index % 2 != 0) {
                return Container();
              }
              return Row(
                children: <Widget>[
                  Expanded(
                    child: buildItem(widget.list[index1]),
                  ),
                  index2 >= widget.list.length
                      ? Container()
                      : Expanded(
                          child: buildItem(widget.list[index2]),
                        ),
                ],
              );
            } else {
              var item = widget.list[index];
              return buildItem(item);
            }
          },
        )
      ],
    );
  }

  Widget buildItem(item) {
    return Row(
      children: <Widget>[
        Checkbox(
          value: checkBoxListControllers["${item[widget.idKey]}"] ?? false,
          activeColor: primaryColor,
          onChanged: (value) {
            setState(() {
              checkBoxListControllers["${item[widget.idKey]}"] = value;
            });
            widget.onSelect(checkBoxListControllers);
          },
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                checkBoxListControllers["${item[widget.idKey]}"] =
                    !(checkBoxListControllers["${item[widget.idKey]}"] ??
                        false);
              });
              widget.onSelect(checkBoxListControllers);
            },
            child: Container(
              child: Text(
                item[widget.labelKey],
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

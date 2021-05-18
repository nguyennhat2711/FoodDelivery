import 'package:flutter/material.dart';

class RadioList extends StatefulWidget {
  final List<Map<String, dynamic>> list;
  final String labelKey;
  final String idKey;
  final Function(Map<String, dynamic> data) onSelect;
  final String selectedValue;
  const RadioList({
    Key key,
    @required this.list,
    @required this.onSelect,
    this.labelKey = "name",
    this.idKey = "id",
    @required this.selectedValue,
  }) : super(key: key);

  @override
  _RadioListState createState() => _RadioListState();
}

class _RadioListState extends State<RadioList> {

//  Map<String, String> radioControllers = {};
  String radioController;
  @override
  void initState() {
    super.initState();
    setState(() {
      radioController = widget.selectedValue;
    });
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
            String value = "${widget.list[index][widget.idKey]}";
            return Row(
              children: <Widget>[
                Radio<String>(
                  value: value,
                  groupValue: radioController,
                  onChanged: (String newValue) {
                    widget.onSelect(widget.list[index]);
                    setState(() {
                      radioController = newValue;
                    });
                  },
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      widget.onSelect(widget.list[index]);
                      setState(() {
                        radioController = value;
                      });
                    },
                    child: Container(
                      child: Text(
                        widget.list[index][widget.labelKey],
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                  ),
                ),
              ],
            );
          },
        )
      ],
    );
  }
}

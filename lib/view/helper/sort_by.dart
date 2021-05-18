import 'package:afandim/custom_widget/alternative_dropdown_list.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';

enum SortByValue { restaurant, cusine }

class SortBy extends StatefulWidget {
  final SortByValue byValue;
  final Map selected;
  final bool isAsc;

  SortBy({
    Key key,
    @required this.byValue,
    this.selected,
    this.isAsc = false,
  }) : super(key: key);

  @override
  _SortByState createState() => _SortByState();
}

class _SortByState extends State<SortBy> {
  String sortValue;
  List list = [];
  List labels = [
    {
      "name": lang.api("Ascending"),
      "id": "asc",
    },
    {
      "name": lang.api("Descending"),
      "id": "desc",
    },
  ];
  Map sort;

  @override
  void initState() {
    String type =
        widget.byValue == SortByValue.restaurant ? "restaurant" : "cusine";
    lang.settings["sort"][type].keys.toList().forEach((key) {
      list.add({"name": lang.api(key), "id": key});
    });
    if (widget.selected == null) {
      sortValue = list[0]["id"];
    } else {
      sortValue = widget.selected["id"];
    }
    if (widget.isAsc) {
      sort = labels[0];
    } else {
      sort = labels[1];
    }
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.api("Sort by")),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return buildBody();
  }

  Widget getList() {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var item = list[index];
        return Row(
          children: [
            Radio<String>(
              value: "${item["id"]}",
              groupValue: sortValue,
              activeColor: Theme.of(context).primaryColor,
              onChanged: onChange,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  onChange("${item["id"]}");
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.api(item["name"])),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget getTop() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            lang.api("Sort by"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: AlternativeDropdownList(
              key: UniqueKey(),
              labels: labels,
              displayLabel: "name",
              selectedId: sort["id"] ?? "desc",
              onChange: (item) {
                setState(() {
                  sort = item;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getBottom() {
    return InkWell(
      onTap: () {
        list.forEach((element) {
          if (element["id"] == sortValue) {
            Navigator.of(context).pop({"sort": sort["id"], "sort_by": element});
          }
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.all(16),
        child: Text(
          lang.api("Confirm"),
          style: TextStyle(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: Container(
            child: ListView(
              children: [
                getTop(),
                getList(),
              ],
            ),
          ),
        ),
        Container(
          child: getBottom(),
        ),
      ],
    );
  }

  void onChange(value) {
    setState(() {
      sortValue = value;
    });
  }
}

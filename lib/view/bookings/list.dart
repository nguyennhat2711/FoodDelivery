import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class BookingList extends StatefulWidget {
  @override
  _BookingListState createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> {
  final _randomColor = RandomColor();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 7,
      separatorBuilder: (BuildContext context, int index){
        return Divider(height: 2, color: Colors.grey,);
      },
      itemBuilder: (BuildContext context, int index){
        return ListTile(
          leading: Container(
            child: CircleAvatar(
              backgroundColor: _randomColor.randomColor(),
              child: Text(
                "#${index+1}",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          title: Text("List Tile ${index+1}"),
          subtitle: Text("Subtile ${index+1}"),
        );
      }
    );
  }
}

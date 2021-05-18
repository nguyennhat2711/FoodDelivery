import 'package:afandim/helper/constance.dart';
import 'package:flutter/material.dart';

class CartError extends StatelessWidget {
  final List errorList;

  const CartError({Key key, this.errorList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorList.isEmpty) {
      return Container();
    }
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      color: primaryColor,
      child: Container(
        child: ListView.separated(
          primary: false,
          shrinkWrap: true,
          itemCount: errorList.length,
          separatorBuilder: (_, index) {
            return Divider(color: Colors.grey, height: 2);
          },
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(8),
              child: Text(
                errorList[index],
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Roboto",
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

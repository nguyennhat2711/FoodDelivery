import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final VoidCallback onSearchClicked;
  final String title;
  final String normalText;
  final Widget icon;
  const SearchBox(
      {Key key, this.onSearchClicked, this.title, this.icon, this.normalText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSearchClicked,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          child: Row(
            children: <Widget>[
              IconButton(
                icon: icon ?? Icon(Icons.search),
                onPressed: onSearchClicked,
                iconSize: 32,
              ),
              Expanded(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: normalText,
                      ),
                      TextSpan(
                        text: " $title",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_drop_down),
                onPressed: onSearchClicked,
                iconSize: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BarItem {
  final title;
  final IconData iconData;
  final color;
  final Widget icon;
  BarItem({this.icon, this.title, this.iconData, this.color});
}

class AnimatedBottomBar extends StatefulWidget {
  final List<BarItem> barItems;
  final Duration animationDuration;
  final Function(int index) onSelectBar;
  final currentIndex;
  const AnimatedBottomBar(
      {Key key,
      this.barItems,
      this.animationDuration = const Duration(milliseconds: 500),
      this.onSelectBar,
      this.currentIndex = 0})
      : super(key: key);

  @override
  _AnimatedBottomBarState createState() =>
      _AnimatedBottomBarState(currentIndex);
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar>
    with TickerProviderStateMixin {
  int selectedItem;

  _AnimatedBottomBarState(this.selectedItem);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10.0,
          left: 4.0,
          right: 4.0,
          bottom: 10.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildBarRow(),
        ),
      ),
    );
  }

  List<Widget> _buildBarRow() {
    List<Widget> _barItems = [];
    for (int i = 0; i < widget.barItems.length; i++) {
      BarItem item = widget.barItems.elementAt(i);
      bool isSelected = selectedItem == i;
      _barItems.add(InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          setState(() {
            selectedItem = i;
            widget.onSelectBar(selectedItem);
          });
        },
        child: AnimatedContainer(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color:
                isSelected ? item.color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          child: Row(
            children: <Widget>[
              item.icon != null
                  ? item.icon
                  : isSelected
                      ? Icon(
                          item.iconData,
                          color: item.color,
                          size: 24.0,
                        )
                      : Icon(
                          item.iconData,
                          size: 20.0,
                          color: Colors.grey,
                        ),
              SizedBox(width: 8.0),
              AnimatedSize(
                child: item.title is Widget
                    ? Container(
                        child: item.title,
                        height: 24,
                      )
                    : Text(
                        isSelected ? item.title : "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: item.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                duration: widget.animationDuration,
                vsync: this,
                curve: Curves.easeInOut,
              )
            ],
          ),
          duration: widget.animationDuration,
        ),
      ));
    }
    return _barItems;
  }
}

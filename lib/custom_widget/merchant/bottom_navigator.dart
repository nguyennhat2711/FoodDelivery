import 'package:flutter/material.dart';

class BottomNavigator extends StatefulWidget {
  final List<Widget> pages;
  final List tabs;
  final int selectedIndex;
  final Function(int) onChanged;
  const BottomNavigator({Key key, this.pages, this.tabs, this.selectedIndex, this.onChanged}) : super(key: key);

  @override
  _BottomNavigatorState createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if(widget.selectedIndex != null){
      selectedIndex = widget.selectedIndex;
    }
    return Container(
      child: Column(
        children: [
          Flexible(
            child: widget.pages[selectedIndex],
          ),
          SafeArea(
            bottom: true,
            top: false,
            left: false,
            right: false,
            child: Container(
              child: Row(
                children: List.generate(widget.tabs.length, (index) {
                  return Expanded(
                    child: InkWell(
                      child: Container(
                        child: widget.tabs[index] is Widget?
                          widget.tabs[index] :
                          Text(
                            widget.tabs[index],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedIndex == index? Theme.of(context).primaryColor: Colors.black,
                            ),
                          ),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: selectedIndex == index? BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ): BorderSide(
                              width: 2,
                              color: Colors.grey[300]
                            ),
                          ),
                        ),
                      ),
                      onTap: (){
                        selectedIndex = index;
//                      setState(() {
//                      });
                        if(widget.onChanged != null){
                          widget.onChanged(index);
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/view/bookings/list.dart';
import 'package:flutter/material.dart';

class BookingsHistory extends StatefulWidget {
  @override
  _BookingsHistoryState createState() => _BookingsHistoryState();
}

class _BookingsHistoryState extends State<BookingsHistory> {
  final _repository = Repository();
  bool isLoading = true;
  List list = [];
  List tabs = [
    lang.api("All"),
    lang.api("pending"),
    lang.api("Approved"),
    lang.api("Denied"),
  ];
  int selectedIndex = 0;
  String message;

  @override
  void initState() {
    super.initState();
    init();
  }

  init([bool forceRefresh = false]) async {
//    setState(() {
//      tabs = getListFromMap(lang.settings["booking_tabs"], true);
//    });

    setState(() {
      isLoading = true;
      list = [];
    });
    Map<String, dynamic> response = await _repository.getBookingList();
    isLoading = false;
    if (response.containsKey("success") && response["success"]) {
      list = response["details"]["data"];
    } else {
      message = response["msg"];
    }
    setState(() {});
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang.api("Booking History")),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.autorenew),
              onPressed: () {
                init(true);
              },
            )
          ],
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            tabs: List.generate(tabs.length, (index) {
              return Tab(
                text: tabs[index],
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: List.generate(tabs.length, (index) {
            return Card(
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 4,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.all(16.0),
                child: getListView(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget getListView() {
    if (isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// todo :
          LoadingWidget(),
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
      );
    } else {
      if (list.length == 0) {
        return EmptyWidget(
          size: 128.0,
          message: message,
        );
      } else {
        return BookingList();
      }
    }
  }
}

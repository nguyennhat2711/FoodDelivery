import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/auth/login/login_view.dart';
import 'package:afandim/view/orders/order_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class OrdersHistory extends StatefulWidget {
  @override
  _OrdersHistoryState createState() => _OrdersHistoryState();
}

class _OrdersHistoryState extends State<OrdersHistory> {
  final _prefManager = PrefManager();
  List tabs = [];
  bool isLogin = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    isLogin = await _prefManager.contains("token");
    if (!isLogin) {
      _prefManager.set("come_from", "order_history");
      Get.off(LoginPhone());
    }
    setState(() {
      tabs = getListFromMap(lang.settings["order_tabs"]);
    });
  }

  List<Map<String, dynamic>> getListFromMap(Map map) {
    List<Map<String, dynamic>> temp = [];
    map.keys.toList().forEach((key) {
      temp.add({
        "name": lang.api("${key[0].toUpperCase()}${key.substring(1)}"),
        "id": key
      });
    });

    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    if (isLogin) {
      return getBody();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            lang.api("Order History"),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/login.svg",
                  width: 128,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 16),
                Text(
                  lang.api("Login to view your orders!"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget getBody() {
    return DefaultTabController(
      length: tabs.length,
      initialIndex: 0,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            lang.api("Order History"),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: List.generate(tabs.length, (index) {
              return Tab(
                text: tabs[index]["name"],
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: List.generate(tabs.length, (index) {
            var item = tabs[index];
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: getListView(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget getListView(Map item) {
    return OrderList(
        code: item["id"],
        label: item["name"],
        showMessage: (String msg) {
          showError(_scaffoldKey, msg);
        });
  }
}

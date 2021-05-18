import 'dart:async';
import 'dart:convert';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/animated_bottom_bar.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/cart/cart.dart';
import 'package:afandim/view/home/home_view.dart';
import 'package:afandim/view/profile/edit_profile.dart';
import 'package:afandim/view/profile/orders_history.dart';
import 'package:afandim/view/profile/profile.dart';
import 'package:afandim/view/restaurant_details/restaurant_details_view.dart';
import 'package:afandim/view/search/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uni_links/uni_links.dart';

class ControlView extends StatefulWidget {
  final int selectedIndex;

  ControlView({Key key, this.selectedIndex = 0}) : super(key: key);

  @override
  _ControlViewState createState() => _ControlViewState();
}

class _ControlViewState extends State<ControlView> {
  final _repository = Repository();
  int _selectedIndex = 0;
  int _counter = 0;
  final _prefManager = PrefManager();
  Timer timer;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.selectedIndex;
    });
    checkPhone();
    startTimer();
    initUniLinks();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  StreamSubscription _sub;

  Future<Null> initUniLinks() async {
    try {
      String initialLink = await getInitialLink();
      onUniLinks(initialLink);
      _sub = getLinksStream().listen((String link) {
        onUniLinks(link);
      }, onError: (err) {
        print("Exception occur: $err");
      });
    } on PlatformException catch (e) {
      print("Exception occur: $e");
    }
  }

  void onUniLinks(String urlLink) {
    if (urlLink != null) {
      String id = urlLink.substring(urlLink.lastIndexOf("/") + 1);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return MerchantDetailsView(
            merchantId: id,
          );
        }),
      );
    }
  }

  void checkPhone() async {
    if (await _prefManager.contains("user.data")) {
      Map userData = json.decode(await _prefManager.get("user.data", "{}"));
      if (userData.containsKey("contact_phone") &&
          userData["contact_phone"].toString().isEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return EditProfile(
                notification: lang.api(
                    "Unfortunately; Your phone number is not set, please provide it."));
          }),
        );
      }
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _repository.close();
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  void startTimer() {
    if (timer != null && timer.isActive) {
      return;
    }
    timer = Timer.periodic(Duration(seconds: 7), (timer) async {
//      print("Timer started");
      bool loadCartCount = await _prefManager.get("load_cart_count", true);
//      print("loadCartCount: $loadCartCount");
      if (loadCartCount || _counter != 0) {
//        print("Timer Work");
        Map<String, dynamic> response = await _repository.getCartCount();
        if (response != null &&
            response.containsKey("details") &&
            response["details"] != null &&
            response["details"].containsKey("count")) {
          await _prefManager.set(
              "cart_details", json.encode(response["details"]));
          await _prefManager.set("load_cart_count", false);
          try {
            _counter = int.parse("${response["details"]["count"]}");
          } on Exception catch (e) {
            print("Exception: $e");
            _counter = 0;
          }
        }
      } else {
        Map basketDetails =
            json.decode(await _prefManager.get("cart_details", "{}"));
        if (basketDetails != null && basketDetails.containsKey("count")) {
          try {
            _counter = int.parse("${basketDetails["count"]}");
          } on Exception catch (e) {
            print("Exception: $e");
            _counter = 0;
          }
          setState(() {});
        }
      }
      if (await FlutterAppBadger.isAppBadgeSupported()) {
        if (_counter == 0) {
          FlutterAppBadger.removeBadge();
        } else {
          FlutterAppBadger.updateBadgeCount(_counter);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: WillPopScope(
        child: [
          HomeView(),
          Search(),
          OrdersHistory(),
          CartView(),
          Profile(),
        ][_selectedIndex],
        onWillPop: onWillPop,
      ),
      bottomNavigationBar: SafeArea(
        child: AnimatedBottomBar(
          currentIndex: _selectedIndex,
          barItems: [
            BarItem(
              title: lang.api("Home"),
              iconData: Icons.home,
              color: Theme.of(context).primaryColor,
            ),
            BarItem(
              title: lang.api("Search"),
              iconData: Icons.search,
              color: Theme.of(context).primaryColor,
            ),
            BarItem(
              title: lang.api("Orders"),
              icon: SvgPicture.asset(
                "assets/icons/order-history.svg",
                color: Colors.grey,
                width: 20.0,
                height: 20.0,
              ),
              color: Theme.of(context).primaryColor,
            ),
            BarItem(
              title: _counter == 0
                  ? lang.api("Cart")
                  : Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: new BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: new Text(
                              '$_counter',
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ),
//                    _selectedIndex != 3 ? Container() : SizedBox(width: 6),
//                    _selectedIndex != 3
//                        ? Container()
//                        : Text(
//                      lang.api("cart"),
//                      style: TextStyle(
//                        color: Theme.of(context).primaryColor,
//                        fontWeight: FontWeight.w600,
//                      ),
//                    ),
                        ],
                      ),
                    ),
              iconData: Icons.shopping_cart,
              color: Theme.of(context).primaryColor,
            ),
            BarItem(
              title: lang.api("Profile"),
              iconData: Icons.person,
              color: Theme.of(context).primaryColor,
            ),
          ],
          animationDuration: Duration(milliseconds: 300),
          onSelectBar: (index) async {
            startTimer();
            if (await _prefManager.get("has_page", false)) {
              await _prefManager.remove("has_page");
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) {
                return ControlView(
                  selectedIndex: index,
                );
              }), ModalRoute.withName("/no_route"));
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
        ),
      ),
    );
  }

  Future<bool> onWillPop() async {
    startTimer();
    if (await _prefManager.get("has_page", false)) {
      await _prefManager.remove("has_page");
      return true;
    }
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    } else {
      return showCustomErrorDialog();
    }
  }
}

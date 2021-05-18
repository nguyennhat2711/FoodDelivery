import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/more_item.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/helper/routes.dart';
import 'package:afandim/view/auth/login/login_view.dart';
import 'package:afandim/view/control_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _prefManager = PrefManager();
  bool isLogin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  init() async {
    isLogin = await _prefManager.contains("token");
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          lang.api("ACCOUNT"),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: isLoading
              ? LoadingWidget(
                  message: lang.api("loading"),
                  useLoader: true,
                  size: 84.0,
                )
              : ListView(
                  padding: EdgeInsets.only(top: 8),
                  children: <Widget>[
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.api("ACCOUNT"),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            lang.api(
                                "Manage your profile, orders, adresses etc."),
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        lang.api("Account"),
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    !isLogin
                        ? Container()
                        : MoreItem(
                            label: lang.api("Edit profile"),
                            icon: SvgPicture.asset(
                              "assets/icons/edit.svg",
                              color: Colors.grey,
                              width: 24,
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(editProfileRoute);
                            },
                          ),
                    !isLogin
                        ? Container()
                        : Divider(
                            color: Colors.grey,
                            height: 2,
                          ),

                    !isLogin
                        ? Container()
                        : MoreItem(
                            label: lang.api("Order History"),
                            icon: SvgPicture.asset(
                              "assets/icons/order-history.svg",
                              color: Colors.grey,
                              width: 24,
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(ordersHistoryRoute);
                            },
                          ),
                    !isLogin
                        ? Container()
                        : Divider(
                            color: Colors.grey,
                            height: 2,
                          ),

                    !isLogin
                        ? Container()
                        : MoreItem(
                            label: lang.api("Points"),
                            icon: SvgPicture.asset(
                              "assets/icons/points.svg",
                              color: Colors.grey,
                              width: 24,
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(pointsRoute);
                            },
                          ),
                    !isLogin
                        ? Container()
                        : Divider(
                            color: Colors.grey,
                            height: 2,
                          ),

                    !isLogin
                        ? Container()
                        : MoreItem(
                            label: lang.api("Favorites"),
                            icon: SvgPicture.asset(
                              "assets/icons/heart.svg",
                              color: Colors.grey,
                              width: 24,
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(favoriteRoute);
                            },
                          ),
                    !isLogin
                        ? Container()
                        : Divider(
                            color: Colors.grey,
                            height: 2,
                          ),

                    !isLogin
                        ? Container()
                        : MoreItem(
                            label: lang.api("Address Book"),
                            icon: SvgPicture.asset(
                              "assets/icons/pin.svg",
                              color: Colors.grey,
                              width: 24,
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(addressDirectoryRoute);
                            },
                          ),
                    !isLogin
                        ? Container()
                        : Divider(
                            color: Colors.grey,
                            height: 2,
                          ),

//              !isLogin? Container():
//              MoreItem(label: lang.api("Booking History"), icon: SvgPicture.asset(
//                "assets/icons/booking-history.svg",
//                color: Colors.grey,
//                width: 24,
//              ), onTap: (){
//                Navigator.of(context).pushNamed(bookingsHistoryRoute);
//              },),
//              !isLogin? Container():
//              Divider(color: Colors.grey, height: 2,),

//              !isLogin? Container():
//              MoreItem(label: lang.api("Credit Cards"), icon: SvgPicture.asset(
//                "assets/icons/credit-card.svg",
//                color: Colors.grey,
//                width: 24,
//              ), onTap: (){
//                Navigator.of(context).pushNamed(creditCardsRoute);
//              },),
//              !isLogin? Container():
//              Divider(color: Colors.grey, height: 2,),

                    MoreItem(
                      label: lang.api("Be Afandim Partner"),
                      icon: SvgPicture.asset(
                        "assets/icons/car.svg",
                        color: Colors.grey,
                        width: 24,
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(partnerRoute);
                      },
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 2,
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        lang.api("Settings"),
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    MoreItem(
                      label: lang.api("Settings"),
                      icon: SvgPicture.asset(
                        "assets/icons/settings.svg",
                        color: Colors.grey,
                        width: 24,
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(settingsRoute);
                      },
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 2,
                    ),

                    !isLogin
                        ? Container()
                        : MoreItem(
                            label: lang.api("Push notifications"),
                            icon: SvgPicture.asset(
                              "assets/icons/notification.svg",
                              color: Colors.grey,
                              width: 24,
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(notificationsRoute);
                            },
                          ),
                    !isLogin
                        ? Container()
                        : Divider(
                            color: Colors.grey,
                            height: 2,
                          ),

                    MoreItem(
                      label: lang.api("Contact Us"),
                      icon: SvgPicture.asset(
                        "assets/icons/mail.svg",
                        color: Colors.grey,
                        width: 24,
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(contactUsRoute);
                      },
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 2,
                    ),

                    !isLogin
                        ? MoreItem(
                            label: lang.api("Login"),
                            icon: SvgPicture.asset(
                              "assets/icons/login.svg",
                              color: Colors.grey,
                              width: 24,
                            ),
                            onTap: () {
                              Get.off(LoginPhone());
                            },
                          )
                        : MoreItem(
                            label: lang.api("Log out"),
                            hasArrow: false,
                            icon: SvgPicture.asset(
                              "assets/icons/logout.svg",
                              color: Colors.grey,
                              width: 24,
                            ),
                            onTap: () async {
                              bool logout = await showCustomErrorDialog(
                                lang.api("Log out"),
                                lang.api("Are you sure?"),
                                lang.api("Ok"),
                              );
                              if (logout) {
                                await _prefManager.remove("token");
                                await _prefManager.remove("active_merchant");
                                await _prefManager
                                    .remove("firebase_notification_token");
                                await _prefManager.remove("login");
                                await _prefManager.remove("password");
                                await _prefManager.remove("user.data");
                                await _prefManager.remove("load_cart_count");
                                await _prefManager.remove("fb_login");
                                await _prefManager.set("fbLogout", true);
                                Get.off(() => ControlView());
                              }
                            }),
                  ],
                ),
        ),
      ),
    );
  }
}

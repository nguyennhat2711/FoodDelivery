import 'package:afandim/helper/closable.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/auth/login/login_view.dart';
import 'package:afandim/view/control_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/pref_manager.dart';

class OnBoardingView extends StatefulWidget {
  @override
  _OnBoardingViewState createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  PageController _pageController = PageController();
  final _prefManager = PrefManager();
  int selectedIndex = 0;
  bool isLoading = true;
  Map startup = {};
  List startupText = [
    {
      "title": "Find restaurants nearby",
      "subtitle":
          "Order delicious food from your favourite restaurants with a few clicks"
    },
    {
      "title": "Secure and private",
      "subtitle":
          "Paying trought the app is easy, fast and safe. Here your info are private"
    },
    {
      "title": "We take it to you",
      "subtitle":
          "Get the order at home. You don\'t even have to get up off the couch"
    }
  ];
  int index = 0;
  bool isLast = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      isLoading = false;
      startup = lang.settings["startup"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    return Scaffold(
      body: Closable(
        child: SafeArea(
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RaisedButton(
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        onPressed: () {
                          _prefManager.set('intro', true);
                          Get.offAll(() => ControlView());
                        },
                        child: Text(
                          lang.api("Skip"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      children: startup["banner"].map<Widget>((data) {
                        return AspectRatio(
                          aspectRatio: 1.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: Container(
//                                margin: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: CachedNetworkImage(
                                    imageUrl: data,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fitWidth,
//                                    scale: 1,
                                  ),
                                ),
                              ),
                              selectedIndex >= startupText.length
                                  ? Container()
                                  : Text(
                                      lang.api(
                                          startupText[selectedIndex]["title"]),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              selectedIndex >= startupText.length
                                  ? Container()
                                  : Text(
                                      lang.api(startupText[selectedIndex]
                                          ["subtitle"]),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                              SizedBox(
                                height: 16.0,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 7 / 1,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(startup["banner"].length, (index) {
                            return Card(
                              color: index == selectedIndex
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[900],
                              shape: CircleBorder(),
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                              ),
                            );
                          }).toList()),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: OutlineButton(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                style: BorderStyle.solid,
                                width: 1),
                            textColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            onPressed: () {
                              _prefManager.set('intro', true);
                              Get.off(LoginPhone());
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                lang.api("Sign In or Register"),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // SizedBox(width: 16),
                        // Expanded(
                        //   child: RaisedButton(
                        //     shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(10.0)),
                        //     color: Theme.of(context).primaryColor,
                        //     textColor: Colors.white,
                        //     child: Padding(
                        //       padding: const EdgeInsets.symmetric(vertical: 8),
                        //       child: Text(
                        //         lang.api("Register"),
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.w700,
                        //         ),
                        //       ),
                        //     ),
                        //     onPressed: () {
                        //       _prefManager.set('intro', true);
                        //       Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, ModalRoute.withName("/no_route"));
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

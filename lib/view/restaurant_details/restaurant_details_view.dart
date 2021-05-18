import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/animated_bottom_bar.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/merchant/bottom_navigator.dart';
import 'package:afandim/helper/app_builder.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/model/search_merchant.dart';
import 'package:afandim/view/shop/menu_view.dart';
import 'package:afandim/view/shop/overview/overview_view.dart';
import 'package:flutter/material.dart';

class MerchantDetailsView extends StatefulWidget {
  final SearchMerchantList searchMerchantList;
  final String merchantId;

  const MerchantDetailsView({
    Key key,
    this.searchMerchantList,
    this.merchantId,
  }) : super(key: key);

  @override
  _MerchantDetailsViewState createState() => _MerchantDetailsViewState();
}

class _MerchantDetailsViewState extends State<MerchantDetailsView> {
  final _repo = Repository();
  Map merchantData;
  bool isLoading = true;
  Map merchantAbout;
  List menuList;
  List reviewList;
  int selectedIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool forceRefresh = false;
  int _selectedIndex = 1;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    String merchantId = widget.merchantId ?? widget.merchantId;
    print("merchantId: $merchantId");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> merchantInfo =
        await _repo.getRestaurantInfo(merchantId); // forceRefresh
    isLoading = false;
    // log("merchantInfo: $merchantInfo");
    if (merchantInfo.containsKey("code") && merchantInfo["code"] == 1) {
      merchantData = merchantInfo["details"]["data"];
      // log("merchantData: ${json.encode(merchantData)}");
      if (merchantData["status_raw"] == "close") {
        showCustomErrorDialog(lang.api("Merchant is closed"),
            merchantData["close_message"], lang.api("OK"));
//        showError(_scaffoldKey, merchantData["close_message"]);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Dismissible(
        key: Key("Merchant dismissable"),
        direction: DismissDirection.down,
        onDismissed: (dir) {
          Navigator.of(context).pop();
        },
        child: getBottomSheet(),
      ),
      backgroundColor: Colors.grey[50],
    );
  }

  getBottomNav() {
    if (isLoading || merchantData == null) {
      return Container();
    }
    return SafeArea(
      child: AnimatedBottomBar(
        currentIndex: _selectedIndex,
        barItems: [
          BarItem(
            title: lang.api("Overview"),
            iconData: Icons.home,
            color: Theme.of(context).primaryColor,
          ),
          BarItem(
            title: lang.api("Menu"),
            iconData: Icons.menu,
            color: Theme.of(context).primaryColor,
          ),
        ],
        animationDuration: Duration(milliseconds: 300),
        onSelectBar: (index) async {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Future<bool> onWillPop() async {
    if (selectedIndex != 1) {
      setState(() {
        selectedIndex = 1;
      });
      return false;
    } else {
      return true;
    }
  }

  Widget getBody() {
    if (isLoading) {
      return SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: LoadingWidget(
                      size: 84.0,
                      useLoader: true,
                      message: lang.api("loading"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (merchantData == null) {
      return Column(
        children: [
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: EmptyWidget(
                size: 128,
                message: lang.api("Fail to load merchant name"),
              ),
            ),
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 2));
        setState(() {
          forceRefresh = true;
        });
        return;
      },
      child: [
        Overview(
          merchantData: merchantData,
          merchantAbout: merchantAbout,
          forceRefresh: forceRefresh,
          openReview: () {
            setState(() {
              selectedIndex = 2;
            });
            AppBuilder.of(context).rebuild();
          },
          onLoadMerchantAbout: (Map merchantAbout) {
            this.merchantAbout = merchantAbout;
            setState(() {});
          },
          merchantId: widget.merchantId ?? widget.searchMerchantList.merchantId,
        ),
        Menu(
          merchantData: merchantData,
          merchantId: widget.merchantId ?? widget.searchMerchantList.merchantId,
          onLoadList: (List menuList) {
            this.menuList = menuList;
            setState(() {});
          },
          openOverView: () {
            setState(() {
              selectedIndex = 0;
            });
            AppBuilder.of(context).rebuild();
          },
          list: menuList,
        ),
      ][_selectedIndex],
    );
//    return getBottomSheet();
  }

  Widget getBottomSheet() {
    return RefreshIndicator(
      onRefresh: () async {
        forceRefresh = true;
        await Future.delayed(Duration(seconds: 2));
        return;
      },
      child: BottomNavigator(
        selectedIndex: selectedIndex,
        onChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        pages: [
          Overview(
            merchantData: merchantData,
            merchantAbout: merchantAbout,
            forceRefresh: forceRefresh,
            openReview: () {
              setState(() {
                selectedIndex = 1;
              });
              AppBuilder.of(context).rebuild();
            },
            onLoadMerchantAbout: (Map merchantAbout) {
              this.merchantAbout = merchantAbout;
              setState(() {});
            },
            merchantId:
                widget.merchantId ?? widget.searchMerchantList.merchantId,
          ),
          Menu(
            merchantData: merchantData,
            merchantId:
                widget.merchantId ?? widget.searchMerchantList.merchantId,
            onLoadList: (List menuList) {
              this.menuList = menuList;
              setState(() {});
            },
            openOverView: () {
              setState(() {
                selectedIndex = 0;
              });
              AppBuilder.of(context).rebuild();
            },
            list: menuList,
          ),
//          Review(
//            merchantId: widget.merchantId ?? widget.merchantData["merchant_id"],
//            list: reviewList,
//            forceRefresh: forceRefresh,
//            onLoadReviews: (List reviewList) {
//              this.reviewList = reviewList;
//              setState(() {});
//            },
//          ),
        ],
        tabs: [
          lang.api("Overview"),
          lang.api("Menu"),
//          lang.api("Review"),
        ],
      ),
    );
  }
}

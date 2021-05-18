import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/custom_rating_bar.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/maps/map_widget.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/home/home_widget/banner_widget.dart';
import 'package:afandim/view/merchant/gallery.dart';
import 'package:afandim/view/merchant/gallery_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chat_view/chat_overview_view.dart';

class Overview extends StatefulWidget {
  final Map merchantData;
  final String merchantId;
  final Map merchantAbout;
  final bool forceRefresh;
  final Function(Map) onLoadMerchantAbout;
  final VoidCallback openReview;
  const Overview({
    Key key,
    this.merchantData,
    this.merchantId,
    @required this.onLoadMerchantAbout,
    this.merchantAbout,
    this.openReview,
    this.forceRefresh,
  }) : super(key: key);

  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  var top = 0.0;
  final _repo = Repository();
  Map merchantData;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isFavorite = false;
  bool isLoading = true;
  Map merchantAbout;
  String merchantInfo;
  bool viewOriginalText = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  init() async {
    merchantData = widget.merchantData;
    isFavorite = widget.merchantData["added_as_favorite"];
    if (widget.merchantAbout == null) {
      String merchantId = widget.merchantId;
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> merchantAboutResponse =
          await _repo.getMerchantAbout(merchantId);
      isLoading = false;
      if (merchantAboutResponse.containsKey("code") &&
          merchantAboutResponse["code"] == 1) {
        merchantAbout = merchantAboutResponse["details"]["data"];
        widget.onLoadMerchantAbout(merchantAbout);
      }
    } else {
      isLoading = false;
      merchantAbout = widget.merchantAbout;
    }
    merchantInfo = lang.api("Translating...");
    setState(() {});
    merchantInfo = await getTranslatedInfo();
    setState(() {});
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getOverView();
  }

  Widget getOverView() {
    if (merchantData == null) {
      return getLoadingWidget();
    } else {
      return Scaffold(
        key: _scaffoldKey,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              getSliverAppBar(),
            ];
          },
          body: getBodyContent(),
        ),
      );
    }
  }

  Widget getLoadingWidget() {
    return SingleChildScrollView(
      child: Container(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 220,
                color: Colors.grey[500],
                margin: EdgeInsets.all(4),
              ),
              Container(
                height: 18,
                width: MediaQuery.of(context).size.width / 2,
                margin: EdgeInsets.all(4),
                color: Colors.grey[500],
              ),
              Container(
                height: 18,
                width: MediaQuery.of(context).size.width / 3,
                margin: EdgeInsets.all(4),
                color: Colors.grey[500],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  height: 2,
                  color: Colors.grey,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 18,
                    width: MediaQuery.of(context).size.width / 3,
                    margin: EdgeInsets.all(4),
                    color: Colors.grey[500],
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 18,
                          width: MediaQuery.of(context).size.width / 2.5,
                          margin: EdgeInsets.all(4),
                          color: Colors.grey[500],
                        ),
                        Container(
                          height: 18,
                          width: MediaQuery.of(context).size.width / 3.5,
                          margin: EdgeInsets.all(4),
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 174.0,
      floating: true,
      pinned: true,
      stretch: true,
      elevation: 0.0,
      actions: [
        IconButton(
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: () async {
            addRemoveFavorite();
          },
        ),
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
//             – [Merchent Name], [City]
//            http://onelink.to/afandim
            Share.share(
              "${lang.api("Find services on Afandim")} - ${merchantData["restaurant_name"]}, "
              "${merchantData["complete_address"]}\n${lang.api("http://onelink.to/afandim")}/${widget.merchantId}",
              subject: merchantData["share_options"]["subject"],
            );
//            Share.share(
//              "${merchantData["share_options"]["message"]} ${merchantData["share_options"]["url"]}",
//              subject: merchantData["share_options"]["subject"],
//            );
          },
        ),
      ],
      flexibleSpace: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            top = constraints.biggest.height;
            return FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              title: AnimatedOpacity(
                duration: Duration(milliseconds: 100),
                opacity: top == AppBar().preferredSize.height ? 1.0 : 0.0,
                child: Container(
                  margin: lang.isRtl()
                      ? EdgeInsets.only(left: 86)
                      : EdgeInsets.only(right: 86),
                  child: Text(
                    merchantData["restaurant_name"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              background: Container(
                child: Stack(
                  overflow: Overflow.visible,
                  children: [
                    CachedNetworkImage(
                      imageUrl: merchantData["background_url"],
                      fit: BoxFit.cover,
                      height: 174,
                      width: MediaQuery.of(context).size.width,
                      placeholder: (context, text) {
                        return Image(
                          image: AssetImage("assets/images/background-2.jpg"),
                          fit: BoxFit.cover,
                          height: 174,
                          width: MediaQuery.of(context).size.width,
                        );
                      },
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 174,
                      color: Colors.black38,
                    ),
                    Positioned(
                      bottom: 24,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            merchantData["restaurant_name"],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RaisedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return Gallery(
                                        merchantId: widget.merchantId,
                                      );
                                    }),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      color: Colors.white,
//                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      lang.api("Gallery"),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(6),
                                ),
                                elevation: 0,
                                color: Colors.black38,
                              ),
                              InkWell(
                                onTap: () {
                                  widget.openReview();
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "${merchantData["rating"]["votes"]}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    CustomRatingBar(
                                      onChanged: (value) {
                                        widget.openReview();
                                      },
                                      numStars: 5,
                                      rating: double.parse(
                                          "${merchantData["rating"]["ratings"]}"),
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  addRemoveFavorite() async {
    showLoadingDialog(lang.api("Adding to favorite"));
    Map<String, dynamic> response = await _repo.addFavorite(widget.merchantId);
    Navigator.of(context).pop();
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          response["msg"],
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: (response.containsKey("code") && response["code"] == 1)
            ? Colors.green
            : Colors.red,
      ),
    );
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Widget getBodyContent() {
    return Container(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: merchantData["logo"],
                    placeholder: (context, text) {
                      return Image(
                        image: AssetImage("assets/images/logo-placeholder.png"),
                        width: 46,
                        height: 46,
                      );
                    },
                    width: 46,
                    height: 46,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchantData["restaurant_name"],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          merchantData["cuisine"],
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 8),
              Divider(
                color: Colors.grey,
                height: 2,
              ),
              SizedBox(height: 8),
              getAbout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getContactItem(
      {String label, String svgPath, VoidCallback onTap, color}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            SvgPicture.asset(
              svgPath,
              width: 24,
              color: color,
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget getAbout() {
    if (isLoading == true) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: LoadingWidget(
          size: 82.0,
          useLoader: true,
          message: lang.api("loading"),
        ),
      );
    } else {
      if (merchantAbout == null) {
        return EmptyWidget(
          size: 128,
        );
      }
      return Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                getContactItem(
                  label: lang.api("Chat"),
                  svgPath: "assets/icons/chat_icon.svg",
                  onTap: () async {
                    Get.to(ChatOverViewScreen(widget.merchantData));
                  },
                  color: Theme.of(context).primaryColor,
                ),
                merchantAbout["website"].toString().isEmpty
                    ? Container()
                    : getContactItem(
                        label: lang.api("Website"),
                        svgPath: "assets/icons/browser.svg",
                        color: Theme.of(context).primaryColor,
                        onTap: () async {
                          String url = "${merchantAbout["website"]}";
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        }),
                merchantAbout["latitude"].toString().isEmpty ||
                        merchantAbout["lontitude"].toString().isEmpty
                    ? Container()
                    : getContactItem(
                        label: lang.api("Directions"),
                        svgPath: "assets/icons/location.svg",
                        onTap: () {
                          openMap(direction: true);
                        }),
              ],
            ),
          ),
          merchantData["gallery"] is List && merchantData["gallery"].length > 0
              ? BannerWidget(
                  /// TODO :
                  homeBannerModelList: merchantData["gallery"],
                  withTitle: false,
                  directImage: true,
                  onTap: (item) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return GalleryList(
                          image: item,
                          list: merchantData["gallery"],
                        );
                      }),
                    );
                  },
                )
              : Container(),
          merchantData.containsKey("offers") &&
                  merchantData["offers"].length > 0
              ? SizedBox(
                  height: 8,
                )
              : Container(),
          merchantData.containsKey("offers") &&
                  merchantData["offers"].length > 0
              ? Container(
                  height: 42,
                  child: ListView.builder(
                    itemCount: merchantData["offers"].length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/off.svg",
                                height: 24,
                                width: 24,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 16),
                              Text(
                                lang.api(merchantData["offers"][index]["full"]),
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Roboto",
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(),
          merchantAbout["opening"].length == 0
              ? Container()
              : Column(
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 2,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        lang.api("Opening Hours"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: merchantAbout["opening"].length,
                      itemBuilder: (context, index) {
                        var item = merchantAbout["opening"][index];
                        return Container(
                          margin: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item["day"]),
                              Text(item["hours"]
                                  .toString()
                                  .replaceAll("&nbsp;", "")),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
          merchantAbout["payment"].length == 0
              ? Container()
              : Column(
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 2,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        lang.api("Payment Methods"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: merchantAbout["payment"].length,
                      itemBuilder: (context, index) {
                        var item = merchantAbout["payment"][index];
                        return Container(
                          margin: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/credit-card.svg",
                                width: 24,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(item["label"]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
          merchantAbout["latitude"].toString().isEmpty ||
                  merchantAbout["lontitude"].toString().isEmpty
              ? Container()
              : Column(
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 2,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        lang.api("Location on Map"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Text(
                            merchantData["complete_address"],
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Card(
                      elevation: 8,
                      margin: EdgeInsets.only(top: 8),
                      child: InkWell(
                        onTap: () {
                          openMap(direction: false);
                        },
                        child: Container(
                          height: 160,
                          width: MediaQuery.of(context).size.width,
                          child: IgnorePointer(
                            ignoring: true,
                            child: MapWidget(
                              currentLocation: {
                                "latitude": merchantAbout["latitude"],
                                "longitude": merchantAbout["lontitude"]
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          lang.api("Click on map for direction"),
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          merchantAbout["information"].toString().isEmpty
              ? Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 2,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        lang.api("INFORMATION"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Html(
                      data: viewOriginalText
                          ? merchantAbout["information"]
                          : (merchantInfo ?? ""),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          viewOriginalText = !viewOriginalText;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.grey[200],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              viewOriginalText
                                  ? Icons.g_translate
                                  : Icons.do_not_disturb,
                              color: Colors.black,
                            ),
                            SizedBox(width: 8),
                            Text(
                              viewOriginalText
                                  ? lang.api("View Translated Text")
                                  : lang.api("Disable translation"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      );
    }
  }

  Future<String> getTranslatedInfo() async {
    if (merchantAbout["information"].toString().isNotEmpty) {
      final GoogleTranslator translator = new GoogleTranslator();
      var v = await translator.translate(merchantAbout["information"],
          to: lang.currentLanguage);
      return v.text;
    } else {
      return merchantAbout["information"];
    }
  }

  openMap({bool direction}) async {
    String url;
    if (direction) {
      url = "https://www.google.com/maps/dir/?api=1&"
          "destination=${merchantAbout["latitude"]},${merchantAbout["lontitude"]}&travelmode=driving&dir_action=navigate";
    } else {
      url =
          "https://www.google.com/maps/search/?api=1&query=${merchantAbout['latitude']},${merchantAbout['lontitude']}";
    }
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}

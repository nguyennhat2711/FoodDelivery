import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/model/banner_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerWidget extends StatefulWidget {
  final List<HomeBannerModel> homeBannerModelList;
  final bool withTitle;
  final bool directImage;
  final Function(dynamic) onTap;
  const BannerWidget({
    Key key,
    this.homeBannerModelList,
    this.withTitle = true,
    this.directImage = false,
    this.onTap,
  }) : super(key: key);

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.homeBannerModelList.isEmpty) {
      return Container();
    }
    return Container(
      margin: EdgeInsets.only(top: 8),
      width: MediaQuery.of(context).size.width,
      child: getSwiper(),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget getSwiper() {
    return CarouselSlider.builder(
      itemCount: widget.homeBannerModelList.length,
      itemBuilder: (BuildContext context, int itemIndex, int ss) {
        return getItem(itemIndex);
      },
      options: CarouselOptions(
        autoPlay: true,
        enableInfiniteScroll: true,
        pauseAutoPlayOnManualNavigate: true,
        viewportFraction: 1.0,
        aspectRatio: 2.0,
        pageSnapping: true,
        enlargeCenterPage: true,
        height: (MediaQuery.of(context).size.width / 2),
        autoPlayCurve: Curves.easeInBack,
      ),
    );
  }

  Widget getItem(index) {
    HomeBannerModel bannerListItem = widget.homeBannerModelList[index];
    return Container(
      child: Card(
        child: InkWell(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap(bannerListItem);
            }
          },
          child: Stack(
            children: <Widget>[
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(24.0)),
                child: Hero(
                  tag: bannerListItem,
                  child: CachedNetworkImage(
                    imageUrl: widget.directImage
                        ? widget.homeBannerModelList[index]
                        : bannerListItem.banner,
                    fit: BoxFit.fitWidth,
                    width: MediaQuery.of(context).size.width,
                    height: (MediaQuery.of(context).size.width / 2),
                    placeholder: (_, text) {
                      return Image(
                        image: AssetImage("assets/images/item-placeholder.png"),
                        width: MediaQuery.of(context).size.width,
                        height: (MediaQuery.of(context).size.width / 2),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              !widget.withTitle
                  ? Container()
                  : Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 8, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          bannerListItem.title != null &&
                                  bannerListItem.title.length > 2
                              ? Container(
                                  padding: EdgeInsets.all(11),
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.zero,
                                        topRight: Radius.circular(20.0),
                                        bottomLeft: Radius.zero,
                                        bottomRight: Radius.circular(20.0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 1,
                                          color: Colors.white,
                                          offset: Offset(1, 2),
                                        )
                                      ] // Make rounded corner of border

                                      ),
                                  child: Text(
                                    lang.api(bannerListItem.title),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          bannerListItem.subTitle != null &&
                                  bannerListItem.subTitle.length > 2
                              ? Container(
                                  padding: EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(222, 152, 83, 1),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.zero,
                                        topRight: Radius.circular(15.0),
                                        bottomLeft: Radius.zero,
                                        bottomRight: Radius.circular(15.0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 1,
                                          color: Colors.white,
                                          offset: Offset(1, 2),
                                        )
                                      ] // Make rounded corner of border

                                      ),
                                  child: Text(
                                    lang.api(bannerListItem.subTitle),
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 217, 159, 1),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black38,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.5],
                      )),
                      width: MediaQuery.of(context).size.width,
                      height: (MediaQuery.of(context).size.width / 2),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'gallery_list.dart';

class Gallery extends StatefulWidget {
  final String merchantId;

  const Gallery({Key key, @required this.merchantId}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final _repo = Repository();
  bool isLoading = true;
  List list = [];
  String message;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    setState(() {
      isLoading = true;
      list = [];
    });
    Map<String, dynamic> response = await _repo.getGallery(widget.merchantId);
    isLoading = false;
    if (response.containsKey("code") && response["code"] == 1) {
      list = response["details"]["data"]["gallery"];
    } else {
      message = lang.api(response["msg"]);
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
      appBar: AppBar(
        key: _scaffoldKey,
        title: Text(lang.api("Gallery")),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: getBody(),
      ),
    );
  }

  Widget getBody() {
    if (isLoading) {
      return LoadingWidget(
        size: 84.0,
        useLoader: true,
        message: lang.api("loading"),
      );
    } else {
      if (list.isEmpty) {
        return EmptyWidget(
          message: message,
          size: 128,
        );
      } else {
        return buildBody();
      }
    }
  }

  Widget buildBody() {
    return Container(
      child: buildList(),
    );
  }

  Widget buildList() {
    return ListView.builder(
      itemCount: (list.length / 6).ceil(),
      itemBuilder: (context, index) {
        return getItem(index);
      },
    );
  }

  Widget getItem(index) {
    return Container(
      child: Column(
        children: <Widget>[
          index % 2 == 0
              ? Row(
                  children: <Widget>[
                    getImage((index * 6) + 0, true),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        getImage((index * 6) + 1),
                        getImage((index * 6) + 2),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        getImage((index * 6) + 1),
                        getImage((index * 6) + 2),
                      ],
                    ),
                    getImage((index * 6) + 0, true),
                  ],
                ),
          Row(
            children: <Widget>[
              getImage((index * 6) + 3),
              getImage((index * 6) + 4),
              getImage((index * 6) + 5),
            ],
          ),
        ],
      ),
    );
  }

  Widget getImage(int index, [bool isBig = false]) {
    if (index >= list.length) {
      return Container();
    }
    double imageSize = MediaQuery.of(context).size.width / 3;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return GalleryList(
              image: list[index],
              list: list,
            );
          }),
        );
      },
      child: Container(
        padding: EdgeInsets.all(8),
        width: isBig ? imageSize * 2 : imageSize,
        height: isBig ? imageSize * 2 : imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(8.0),
          child: Hero(
            tag: list[index],
            child: CachedNetworkImage(
              imageUrl: list[index],
              fit: BoxFit.cover,
              placeholder: (context, text) {
                return Image(
                  image: AssetImage("assets/images/item-placeholder.png"),
                  // item-placeholder.png
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

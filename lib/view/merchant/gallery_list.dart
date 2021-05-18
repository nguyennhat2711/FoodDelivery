import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class GalleryList extends StatefulWidget {
  final List list;
  final String image;
  GalleryList({
    Key key,
    @required this.list,
    @required this.image
  }) : super(key: key);

  @override
  _GalleryListState createState() => _GalleryListState();
}

class _GalleryListState extends State<GalleryList> {
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.list.indexOf(widget.image)
    );
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            SafeArea(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back, color: Colors.white,),
                    ),
                  ],
                ),
              ),
            ),
            _pageController == null? Container():
            Expanded(
              child: Dismissible(
                key: Key('DragDown'),
                direction: DismissDirection.vertical,
                onDismissed: (_) => Navigator.pop(context),
                child: PageView(
                  controller: _pageController,
                  children: widget.list.map<Widget>((data) {
                    return Hero(
                      tag: data,
                      child: Container(
                        child: PhotoView(
                          imageProvider: CachedNetworkImageProvider(data),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

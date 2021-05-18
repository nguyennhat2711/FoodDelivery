import 'package:afandim/custom_widget/grey_button.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/model/category_model.dart';
import 'package:afandim/view/home/home_widget/services_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AllCategories extends StatefulWidget {
  final List<CategoryModelList> categoryModelList;
  const AllCategories({Key key, this.categoryModelList}) : super(key: key);

  @override
  _AllCategoriesState createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories> {
  final _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isListView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(lang.api("What do you wish?")),
      ),
      body: getListView(),
    );
  }

  Widget getListView() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              GreyButton(
                  child: InkWell(
                onTap: () {
                  setState(() {
                    isListView = !isListView;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Icon(isListView ? Icons.view_module : Icons.list),
                ),
              )),
              Expanded(
                child: GreyButton(
                  child: TextFormField(
                    controller: _controller,
                    onChanged: (text) {
                      setState(() {});
                    },
                    onFieldSubmitted: (text) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      hintText: lang.api("Search"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: isListView ? getList() : getGridList(),
        ),
        isLoading
            ? Container(
                padding: EdgeInsets.all(16),
                child: LoadingWidget(
                  message: lang.api("loading"),
                  useLoader: true,
                  size: 40,
                ),
              )
            : Container(),
      ],
    );
  }

  Widget getList() {
    return ListView.separated(
      itemCount: getSubList().length,
      separatorBuilder: (_, index) {
        return Divider(
          height: 2,
          color: Colors.grey,
        );
      },
      itemBuilder: (context, index) {
        var item = getSubList()[index];
        return getListItem(item);
      },
    );
  }

  Widget getListItem(CategoryModelList item) {
    return InkWell(
      onTap: () {
        onCategoryClicked(item);
      },
      child: Container(
        padding: EdgeInsets.all(6),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: item.featuredImage,
              fit: BoxFit.cover,
              placeholder: (context, text) {
                return Image(
                  image: AssetImage("assets/images/category-placeholder.png"),
                  width: 46,
                  height: 46,
                );
              },
              width: 46,
              height: 46,
            ),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget getGridList() {
    return GridView.builder(
      itemCount: getSubList().length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, childAspectRatio: 3.5 / 4, mainAxisSpacing: 1.0),
      itemBuilder: (BuildContext context, int index) {
        var item = getSubList()[index];
        return getCard(item);
      },
    );
  }

  Widget getCard(CategoryModelList item) {
    return Center(
      child: InkWell(
        onTap: () {
          onCategoryClicked(item);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: item.featuredImage,
              fit: BoxFit.fitWidth,
              width: 64,
              height: 64,
              placeholder: (context, text) {
                return Image(
                  image: AssetImage("assets/images/category-placeholder.png"),
                  width: 64,
                  height: 64,
                );
              },
            ),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  onCategoryClicked(CategoryModelList categoryModelList) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ServicesList(
          cuisineId: "${categoryModelList.id}",
          title: "${categoryModelList.name}",
          searchType: "byCuisine",
        );
      }),
    );
  }

  List getSubList() {
    List temp = [];
    String searchText = _controller.text;
    widget.categoryModelList.forEach((element) {
      if (element.name.toString().contains(searchText)) {
        temp.add(element);
      }
    });
    return temp;
  }
}

import 'dart:convert';

import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/circle_image.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/merchant/price_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/merchant/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CategoryItems extends StatefulWidget {
  final Map item;

  const CategoryItems({Key key, this.item}) : super(key: key);

  @override
  _CategoryItemsState createState() => _CategoryItemsState();
}

class _CategoryItemsState extends State<CategoryItems> {
  final _repo = Repository();
  bool isLoading = true;
  List list = [];
  String message;

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
    Map<String, dynamic> response = await _repo.getItemByCategory(
        widget.item["merchant_id"], widget.item["cat_id"]);
    isLoading = false;
    if (response.containsKey("code") && response["code"] == 1) {
      list = response["details"]["data"];
    } else {
      message = response["msg"];
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
        title: Text(json.decode(
            widget.item["category_name_trans"])[lang.getLanguageText()]),
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
        useLoader: true,
        message: lang.api("loading"),
        size: 84.0,
      );
    } else {
      if (list.isEmpty) {
        return EmptyWidget(
          size: 128,
          message: message,
        );
      }
    }
    return buildList();
  }

  Widget buildList() {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return getItem(list[index]);
      },
    );
  }

  Widget getItem(var item) {
    String name = json.decode(item["item_name_trans"])[lang.getLanguageText()];
    String description =
        json.decode(item["item_description_trans"])[lang.getLanguageText()];

    return Container(
      child: InkWell(
        onTap: () async {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return Product(
                merchantId: "${item["merchant_id"]}",
                catId: "${item["cat_id"]}",
                itemId: "${item["item_id"]}",
                itemName: name,
              );
            }),
          );
        },
        child: Container(
          margin: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: item["prices2"].length,
                        itemBuilder: (context, index) {
                          var priceItem = item["prices2"][index];
                          bool hasDiscount =
                              ("${priceItem["discount"]}".isNotEmpty &&
                                  "${priceItem["discount"]}" != "0");
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_offer,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: PriceWidget(
                                    price: hasDiscount
                                        ? priceItem["discounted_price_pretty"]
                                        : priceItem["original_price"],
                                    oldPrice: hasDiscount
                                        ? priceItem["original_price"]
                                        : null,
                                  ),
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
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: CircleImage(
                  borderRadius: 8,
                  borderWidth: 0,
                  child: CachedNetworkImage(
                    imageUrl: item["photo"],
                    fit: BoxFit.cover,
                    placeholder: (context, text) {
                      return Image(
                        image: AssetImage("assets/images/item-placeholder.png"),
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

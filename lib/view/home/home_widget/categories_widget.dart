import 'package:afandim/core/viewmodel/home_viewmodel.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/view/home/home_widget/all_categories.dart';
import 'package:afandim/view/home/home_widget/services_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../custom_widget/loading_widget.dart';

class CategoriesWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    final viewModel = watch(homeViewModel);
    return viewModel.isLoadingCategory
        ? LoadingWidget()
        : Container(
            child: Column(
              children: <Widget>[
                viewModel.listCategory.length != 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              lang.api('Choose what you wish'),
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            child: Container(
                              height: 100,
                              color: Colors.white,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: viewModel.listCategory.length < 8
                                    ? viewModel.listCategory.length
                                    : 8,
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          if (index == 7) {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                return AllCategories(
                                                  categoryModelList:
                                                      viewModel.listCategory,
                                                );
                                              }),
                                            );
                                          } else {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                return ServicesList(
                                                  cuisineId: viewModel
                                                      .listCategory[index].id,
                                                  title: viewModel
                                                      .listCategory[index].name,
                                                  searchType: "byCuisine",
                                                );
                                              }),
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 78.3,
                                          width: 78.3,
                                          color: Colors.grey.shade50,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              index == 7
                                                  ? Image(
                                                      image: AssetImage(
                                                          "assets/icons/more.png"),
                                                      width: 52,
                                                      height: 52,
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl: viewModel
                                                          .listCategory[index]
                                                          .featuredImage,
                                                      fit: BoxFit.fitWidth,
                                                      width: 52,
                                                      height: 52,
                                                      placeholder:
                                                          (context, text) {
                                                        return Image(
                                                          image: AssetImage(
                                                              "assets/images/category-placeholder.png"),
                                                          fit: BoxFit.fitWidth,
                                                          width: 52,
                                                          height: 52,
                                                        );
                                                      },
                                                    ),
                                              index == 7
                                                  ? Expanded(
                                                      child: Text(
                                                        'More',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    )
                                                  : Expanded(
                                                      child: Text(
                                                        viewModel
                                                            .listCategory[index]
                                                            .name,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          );
  }
}

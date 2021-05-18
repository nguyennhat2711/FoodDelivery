import 'package:afandim/core/viewmodel/home_viewmodel.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/view/home/home_widget/all_restaurant_card_widget.dart';
import 'package:afandim/view/home/home_widget/home_header_widget.dart';
import 'package:afandim/view/home/home_widget/services_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeNearByWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read(homeViewModel);
    if (viewModel.listNearBy.length == 0 && !viewModel.isLoadingNearBy) {
      return Container();
    } else {
      return Column(
        children: <Widget>[
          HomeHeader(
            title: viewModel.titleNearBy != null &&
                    viewModel.titleNearBy.length > 0 &&
                    viewModel.titleNearBy.split(' ').length > 1
                ? viewModel.titleNearBy.split(' ')[1]
                : '',
            showViewAll: viewModel.listNearBy.length != 0,
            onViewAllTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return ServicesList(
                    title: viewModel.titleNearBy,
                    list: viewModel.listNearBy,
                    paginateTotal: viewModel.paginateTotalNearBy,
                    searchType: "byLatLong",
                  );
                }),
              );
            },
          ),
          !viewModel.isLoadingNearBy
              ? Column(
                  children: viewModel.listNearBy != null &&
                          viewModel.listNearBy.length > 0
                      ? getListWidget(viewModel)
                      : Container(),
                )
              : LoadingWidget(),
        ],
      );
    }
  }

  List<Widget> getListWidget(viewModel) {
    List<Widget> widList = [];
    for (int i = 0;
        i < (viewModel.listNearBy.length > 5 ? 5 : viewModel.listNearBy.length);
        i++) {
      widList.add(MerchantCard(
        item: viewModel.listNearBy[i],
        showOffers: false,
      ));
    }
    return widList;
  }
}

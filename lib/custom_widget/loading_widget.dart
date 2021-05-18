import 'package:afandim/helper/global_translations.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  final String message;

  final bool useLoader;
  final double size;
  const LoadingWidget(
      {Key key, this.message, this.useLoader = false, this.size = 42.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Lottie.asset('assets/images/loading.json',
              height: 100, width: 100),
        ),
        SizedBox(height: 16),
        Text(message ?? lang.api("Loading"))
      ],
    );
  }
}

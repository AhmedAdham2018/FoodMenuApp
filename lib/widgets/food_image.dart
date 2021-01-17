import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../model/food.dart';
import 'dart:math' as math;

import '../routes.dart';

class FoodImage extends StatelessWidget {
  FoodImage({this.food});
  final Food food;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.topCenter,
      child:  GestureDetector(
        behavior: HitTestBehavior.opaque,
//        onTap: () =>
//            Routes.navigateTo(
//              context,
//              '/detail/${food.id}',
//            ),
        child: Hero(
          tag: 'icon-${food.id}',
          child: Image(
            image: AssetImage(food.image),
            height: 160.0,
            width: 160.0,
          ),
        ),
      ),
    );
  }
}
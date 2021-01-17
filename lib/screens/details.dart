import 'package:flutter/material.dart';
import '../model/food.dart';
import '../model/menu.dart';

class DetailPage extends StatelessWidget {

  final Food food;
  DetailPage(String id) : food = Menu.getFoodById(id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: (){

          },
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body:  Center(
        child:  Hero(
          tag: 'icon-${food.id}',
          child: Image(
            image:  AssetImage(food.image),
            height: 160.0,
            width: 160.0,
          ),
        ),
      ),
    );
  }
}

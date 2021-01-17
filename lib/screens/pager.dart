import 'dart:async';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/material.dart';
import '../model/background_colors.dart';
import '../model/food.dart';
import '../model/menu.dart';
import '../widgets/cart_button.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/animated_circle.dart';
import '../widgets/rectangle_indicator.dart';
import '../widgets/food_image.dart';
import '../widgets/item_card.dart';
import '../widgets/shadows.dart';
import 'dart:math' as math;

class MenuPager extends StatefulWidget {
  @override
  _MenuPagerState createState() => _MenuPagerState();
}

const double _kViewportFraction = 0.75;

class _MenuPagerState extends State<MenuPager> with TickerProviderStateMixin {
  final PageController _backgroundPageController = PageController();
  final PageController _pageController =
      PageController(viewportFraction: _kViewportFraction);
  ValueNotifier<double> selectedIndex = ValueNotifier<double>(0.0);
  Color _backColor = const Color.fromRGBO(128, 129, 223, 0.7);
  int _counter = 0;
  int _cartQuantity = 0;
  AnimationController controller, scaleController;
  Animation<double> scaleAnimation;
  bool firstEntry = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    scaleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 175));
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.20).animate(
        CurvedAnimation(parent: scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    controller.dispose();
    scaleController.dispose();
    _pageController.dispose();
    _backgroundPageController.dispose();
    super.dispose();
  }

  Future<Null> playAnimation() async {
    try {
      if (controller.isCompleted) {
        controller.reset();
        await controller.forward().whenComplete(() {
          scaleController.forward().whenComplete(() {
            scaleController.reverse();
            setState(() {
              _cartQuantity = _cartQuantity + _counter;
              _counter = 0;
            });
          });
        });
      } else {
        await controller.forward().whenComplete(() {
          setState(() {
            if (firstEntry) {
              firstEntry = false;
            }
            _cartQuantity = _cartQuantity + _counter;
            _counter = 0;
          });
          scaleController.forward().whenComplete(() {
            scaleController.reverse();
          });
        });
      }
    } on TickerCanceled {}
  }

  onChangeFoodItem(int index, int value, Food food) {
    setState(() {
      Menu.menu[index] = food.copyWith(quantity: value);
    });
  }

  _contentWidget(Food food, int index, Alignment alignment, double resize) {
    return Stack(
      children: <Widget>[
        Center(
          child: Container(
            alignment: alignment,
            width: 300.0 * resize,
            height: 400.0 * resize,
            child: Stack(
              children: <Widget>[
                shadow2,
                shadow1,
                ItemCard(
                  food: food,
                  increment: () {
                    setState(() {
                      _counter++;
                    });
                    onChangeFoodItem(index, _counter, food);
                  },
                  decrement: () {
                    setState(() {
                      _counter--;
                    });
                    onChangeFoodItem(index, _counter, food);
                  },
                ),
                FoodImage(food: food),
                CartButton(
                    counter: food.quantity,
                    addToCart: () {
                      onChangeFoodItem(index, 0, food);
                      playAnimation();
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Iterable<Widget> _buildPages() {
    final List<Widget> pages = <Widget>[];
    for (int index = 0; index < 10; index++) {
      var alignment = Alignment.center.add(Alignment(
          (selectedIndex.value - index) * _kViewportFraction, 0.0));
      var resizeFactor =
          (1 - (((selectedIndex.value - index).abs() * 0.2).clamp(0.0, 1.0)));
      pages.add(_contentWidget(
        Menu.menu[index],
        index,
        alignment,
        resizeFactor,
      ));
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: <Widget>[
        Positioned.fill(
            bottom: screenHeight / 2,
            child: Container(decoration: BoxDecoration(color: _backColor))),
        CustomAppBar(),
        Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: RectangleIndicator(_backgroundPageController,
                    Menu.menu.length, 6.0, Colors.grey[400], Colors.black))),
        PageView.builder(
          itemCount: Menu.menu.length,
          itemBuilder: (BuildContext context, int itemCount) {
            return Container();
          },
          controller: _backgroundPageController,
          onPageChanged: (index) {
            setState(() {
              _backColor = colors[math.Random().nextInt(colors.length)];
            });
          },
        ),
        NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.depth == 0 &&
                notification is ScrollUpdateNotification) {
              selectedIndex.value = _pageController.page;
              if (_backgroundPageController.page != _pageController.page) {
                _backgroundPageController.position
                    // ignore: deprecated_member_use
                    .jumpToWithoutSettling(
                        _pageController.position.pixels / _kViewportFraction);
              }
              setState(() {});
            }
            return false;
          },
          child: PageView(
            controller: _pageController,
            children: _buildPages(),
          ),
        ),
        Positioned.fill(
          top: 30.0,
          right: 5.0,
          bottom: 100.0,
          child: StaggerAnimation(controller: controller.view),
        ),
        firstEntry
            ? Container()
            : Align(
                alignment: Alignment.topRight,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Container(
                    height: 20.0,
                    width: 20.0,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 30.0, right: 5.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.amber),
                    child: Text('$_cartQuantity',
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12.0)),
                  ),
                ),
              ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './routes.dart';
import './screens/pager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Routes.initRoutes();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'FOOD MENU',
    home: MenuHomePage(),
  ));
}

class MenuHomePage extends StatelessWidget {
  MenuHomePage() {
    SystemChrome.setPreferredOrientations(
        <DeviceOrientation>[DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: <Widget>[
          MenuPager(),
        ],
      ),
    );
  }
}

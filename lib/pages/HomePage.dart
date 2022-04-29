import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:open_bsp/darktheme.dart';
import 'StartPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open BSP',
      theme: appTheme,
      routes: {
        '/': (context) => StartPage(),
      },
    );
  }
}

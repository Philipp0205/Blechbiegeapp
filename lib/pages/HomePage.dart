import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'CategorySelectionPage.dart';
import 'QuizPage4.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open BSP',
      routes: {
        '/' : (context) => QuizCategoryPage(),
        '/Quiz' : (context)  => QuizPage4(),
      },
      //onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

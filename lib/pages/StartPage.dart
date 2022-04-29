import 'package:flutter/material.dart';
import 'package:open_bsp/db/CsvService.dart';
import 'package:open_bsp/models/category.dart';
import 'package:open_bsp/pages/quiz/CategorySelectionPage.dart';
import 'package:open_bsp/pages/StatisticPage.dart';

import '../db/QuestionDb.dart';
import 'Settings.dart';

class StartPage extends StatefulWidget {
  static const routeName = '/';

  // const StartPage({Key? key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  var _selectedIndex = 0;
  QuestionDb db = QuestionDb.instance;
  CsvService csvService = new CsvService();

  static List<Widget> _pages = <Widget>[
    Center(
      child: CategorySelectionPage(),
    ),
    Center(
      child: StatisticPage(),
    ),
    Center(
      child: StatisticPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Open BSP"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Settings(),
                ),
              );
            },
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Lernen",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch),
            label: "Prüfung",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Statistik",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

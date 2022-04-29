import 'package:flutter/material.dart';

import '../pages/HomePage.dart';
import '../pages/quiz/CategorySelectionPage.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage(title: '',));
      case '/CategoryPage':
        return MaterialPageRoute(builder: (_) => CategorySelectionPage());
      default:
        return _errorRoute();
    }
  }



  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text(
            'ERROR: Please try again.',
            style: TextStyle(fontSize: 32),
          ),
        ),
      );
    });
  }
}


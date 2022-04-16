import 'package:flutter/material.dart';

import '../pages/CategorySelectionPage.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => QuizCategoryPage2());
      case '/Quiz':
        //return MaterialPageRoute(builder: (_) => QuizPage4());
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


import 'package:flutter/material.dart';
import 'package:open_bsp/models/category.dart';
import 'package:provider/provider.dart';

import '../QuizPage.dart';

class QuizStartPage extends StatelessWidget {
  final Category category;

  const QuizStartPage(this.category);

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizPageState>(context);
    return Scaffold(
      body: ListView(
        children: [
          Hero(
            tag: category.imagePath,
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Color(int.parse('0xff${category.color}')),
              child: Center(
                  child: Container(
                      height: 200,
                      child:
                      Image.asset('assets/images/${category.imagePath}'))),
            ),
            // child: Image.asset('assets/images/${category.imagePath}',
            //     width: MediaQuery.of(context).size.width),
          ),
          Container(
            padding: EdgeInsets.only(top: 5, left: 10, right: 10),
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          Divider(),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  state.nextPage();
                },
                child: Text('Quiz Starten!')),
          ),
        ],
      ),
    );
  }
}
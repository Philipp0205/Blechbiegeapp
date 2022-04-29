import 'package:flutter/material.dart';
import 'package:open_bsp/db/QuestionDb.dart';
import 'package:open_bsp/models/category.dart';
import 'package:provider/provider.dart';

import '../QuizPage.dart';

class ResultPage extends StatelessWidget {
  QuestionDb db = QuestionDb.instance;
  Category category;

  ResultPage(this.category);


  @override
  Widget build(BuildContext context) {
    category.setTimesCompleted(category.timesCompleted + 1);
    print('Times completed ${category.timesCompleted + 1}');
    db.updateCategory(category);

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              "Glückwunsch!",
              style: Theme.of(context).textTheme.headline4,
            ),
            Divider(),
            Text("Bald hast du die Patente A, D (und die 6)"),
            Image.asset("assets/gifs/harald.gif"),
          ],
        ),
      ),
    );
  }
}
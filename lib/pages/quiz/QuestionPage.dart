import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_bsp/db/QuestionDb.dart';
import 'package:open_bsp/models/question.dart';
import 'package:provider/provider.dart';

import '../QuizPage.dart';

class QuestionPage extends StatelessWidget {
  bool fastAnswerMode = true;
  final Question question;
  QuestionDb db = QuestionDb.instance;

  QuestionPage(this.question);

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizPageState>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(question.question),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: question.options.map((option) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                    color: Colors.blue,
                  ),
                  height: 70,
                  margin: EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      state.setSelected = option;
                      db.incrementStat('totalAnsweredQuestions');
                      _bottomSheet(context, option);
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                              state.getSelected == option
                                  ? FontAwesomeIcons.checkCircle
                                  : FontAwesomeIcons.circle,
                              size: 30),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 16),
                              child: Text(
                                option.value,
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom sheet shown when Question is answered
  _bottomSheet(BuildContext context, Option option) {
    bool correct = option.correct;
    correct
        ? db.incrementStat('rightAnsweredQuestions')
        : db.incrementStat('falseAnsweredQuestions');

    var state = Provider.of<QuizPageState>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(correct ? 'Good Job!' : 'Wrong'),
              Text(
                option.value,
                style: TextStyle(fontSize: 18, color: Colors.white54),
              ),
              FlatButton(
                color: correct ? Colors.green : Colors.red,
                child: Text(
                  correct ? 'Onward!' : 'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (correct) {
                    state.nextPage();
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  MaterialColor _colorRightAnswer(BuildContext context, Option option) {
    var state = Provider.of<QuizPageState>(context, listen: false);
    bool correct = option.correct;

    if (state.getSelected != null) {
      if (correct) {
        state.nextPage();
        return Colors.green;
      } else {
        return Colors.blue;
      }
    }
    return Colors.blue;
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_bsp/models/question.dart';
import 'package:provider/provider.dart';

class QuizPage3 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final questions =
    ModalRoute
        .of(context)!
        .settings
        .arguments as List<Question>;

    return ChangeNotifierProvider(
      builder: (_) => QuizPageState(),
      child: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot snap) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Fragen"),
            ),
            body: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return QuestionPageView(questions[0]);
              },
            )
            ,
          );
        },
      ),
    );
  }
}

class QuizPageState with ChangeNotifier {
  double _progress = 0;

  get process => _progress;
  get selected => _selected;

}

class QuestionPageView extends StatelessWidget {
  final Question question;

  QuestionPageView(this.question);

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<_QuizPageState>(context);

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
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: question.options
                .map(
                  (e) =>
              new Container(
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    )),
                height: 90,
                margin: EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        state._selected == e
                            ? FontAwesomeIcons.checkCircle
                            : FontAwesomeIcons.circle,
                        size: 30,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            e.value,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyText2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Bottom sheet shown when Question is answered
  _bottomSheet(BuildContext context, Option opt) {
    bool correct = opt.correct;
    var state = Provider.of<_QuizPageState>(context);
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
                    // state.nextPage();
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
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_bsp/models/question.dart';
import 'package:provider/provider.dart';

class QuizPageState with ChangeNotifier {
  double _progress = 0;
  Option? _selected;

  final PageController controller = PageController();

  get getSelected => _selected;

  get progress => _progress;

  set setSelected(Option option) {
    _selected = option;
    notifyListeners();
  }

  set setProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void nextPage() async {
    await controller.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }
}

class QuizPage4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final questions =
        ModalRoute.of(context)?.settings.arguments as List<Question>;

    return ChangeNotifierProvider(
      create: (_) => QuizPageState(),
      child: Builder(builder: (context) {
        var state = Provider.of<QuizPageState>(context);

        return Scaffold(
          appBar: AppBar(
            title: Text("Quiz4"),
          ),
          body: PageView.builder(
            controller: state.controller,
            itemBuilder: (context, index) {
              return QuestionPage(questions[0]);
            },
          ),
        );
      }),
    );
  }
}

class QuestionPage extends StatelessWidget {
  final Question question;

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
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: question.options.map((e) {
              return Container(
                height: 90,
                margin: EdgeInsets.only(bottom: 10),
                color: Colors.black26,
                child: InkWell(
                  onTap: () {
                    state.setSelected = e;
                    _bottomSheet(context, e);
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                            state.getSelected == e
                                ? FontAwesomeIcons.checkCircle
                                : FontAwesomeIcons.circle,
                            size: 30),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 16),
                            child: Text(
                              e.value,
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
        )
      ],
    );
  }

  /// Bottom sheet shown when Question is answered
  _bottomSheet(BuildContext context, Option opt) {
    bool correct = opt.correct;
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
                opt.value,
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_bsp/models/category.dart';
import 'package:open_bsp/models/question.dart';
import 'package:provider/provider.dart';

class QuizPageState with ChangeNotifier {
  double _progress = 0;
  Option? _selected;

  final PageController controller = PageController();

  get getSelected => _selected;

  get getProgress => _progress;

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
  final Category category;

  QuizPage4(this.category);

  @override
  Widget build(BuildContext context) {
    // final questions =
    //     ModalRoute.of(context)?.settings.arguments as List<Question>;
    final questions = category.questions;

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
            onPageChanged: (int index) =>
                state.setProgress = (index / (questions.length + 1)),
            itemBuilder: (context, index) {
              //return QuestionPage(questions[index]);
              return StartPage(category);
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
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: question.options.map((question) {
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
                      state.setSelected = question;
                      _bottomSheet(context, question);
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                              state.getSelected == question
                                  ? FontAwesomeIcons.checkCircle
                                  : FontAwesomeIcons.circle,
                              size: 30),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 16),
                              child: Text(
                                question.value,
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
        )
      ],
    );
  }

  /// Bottom sheet shown when Question is answered
  _bottomSheet(BuildContext context, Option opt) {
    bool correct = opt.correct;
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
}

class StartPage extends StatelessWidget {
  final Category category;

  StartPage(this.category);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Hero(
            tag: category.imagePath,
            child: Image.asset('assets/images/${category.imagePath}',
                width: MediaQuery.of(context).size.width),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          Divider(),
          Center(
            child: ElevatedButton(
                onPressed: () {},
                child: Text('Quiz Starten')),
          ),
        ],
      ),
    );
  }
}

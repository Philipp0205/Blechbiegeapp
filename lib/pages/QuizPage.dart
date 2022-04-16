import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_bsp/db/QuestionDb.dart';
import 'package:open_bsp/models/category.dart';
import 'package:open_bsp/models/question.dart';
import 'package:provider/provider.dart';

import 'loading.dart';

class QuizPageState with ChangeNotifier {
  double _progress = -1;
  Option? _selected;
  MaterialColor _cardColor = Colors.blue;

  late Category category;

  final PageController controller = PageController();

  get getSelected => _selected;

  get getProgress => _progress;

  get getCardColor => _cardColor;

  set setSelected(Option option) {
    _selected = option;
    notifyListeners();
  }

  set setProgress(double progress) {
    print("set progress $progress");
    _progress = progress;
    notifyListeners();
  }

  set setCardColor(MaterialColor color) {
    _cardColor = color;
    notifyListeners();
  }

  void nextPage() async {
    await controller.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void setColor(MaterialColor color) {
    _cardColor = color;
    notifyListeners();
  }

  void setSelected2(Option option) {
    _selected = option;
    notifyListeners();
  }
}

class QuizPage4 extends StatelessWidget {
  final Category category;

  // final QuestionDb db = QuestionDb.instance;

  const QuizPage4({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    QuestionDb questionDb = QuestionDb.instance;

    List<Question> emptyQuestions = [];

    return ChangeNotifierProvider(
      create: (_) => QuizPageState(),
      child: FutureBuilder<List<Question>>(
        initialData: emptyQuestions,
        future: questionDb.getAllQuestionsOfCategory(category.name),
        builder: (context, snapshot) {
          var state = Provider.of<QuizPageState>(context);

          if (!snapshot.hasData || snapshot.hasError) {
            return Loader();
          } else {
            List<Question> questions = snapshot.data!;
            print("questions length " + questions.length.toString());
            return Scaffold(
              appBar: AppBar(
                title: Text("Quiz4"),
              ),
              body: PageView.builder(
                controller: state.controller,
                onPageChanged: (int index) =>
                    state.setProgress = (index / (questions.length + 1)),
                itemBuilder: (context, index) {
                  print(index);
                  if (index == 0) {
                    return StartPage(category);
                  } else if (index == questions.length + 1) {
                    return ResultPage();
                  } else {
                    return QuestionPage(questions[index - 1]);
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }

// @override
// Widget build(BuildContext context) {
//
//   QuestionDb questionDb = QuestionDb.instance;
//
//   return Scaffold(
//     appBar: AppBar(
//       backgroundColor: Colors.transparent,
//     ),
//     body: ListView(children: [
//       Hero(
//         tag: category.imagePath,
//         child: Image.asset('assets/images/${category.imagePath}',
//             width: MediaQuery.of(context).size.width),
//       ),
//       Text(
//         category.name,
//         style:
//         const TextStyle(height: 2, fontSize: 20, fontWeight: FontWeight.bold),
//       ),
//       // QuizList(topic: topic)
//     ]),
//   );
// }

}

createQuestionPages(List<Question> questions) {
  // var state = Provider.of<QuizPageState>(context);
  List<Widget> widgets =
      questions.map((question) => QuestionPage(question)).toList();
  return widgets;
  // return PageView.builder(
  //   controller: state.controller,
  //   onPageChanged: (int index) =>
  //   state.setProgress = (index / (questions.length + 1)),
  //   itemBuilder: (context, index) {
  //     return QuestionPage(questions[index]);
  //   },
  // );
}

class QuestionPage extends StatelessWidget {
  bool fastAnswerMode = true;

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
                    color: _colorRightAnswer(context, question)
                  ),
                  height: 70,
                  margin: EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      state.setSelected = question;
                      if (!fastAnswerMode) {
                        _bottomSheet(context, question);
                      } else {
                        _colorRightAnswer(context, question);
                      }
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
  _bottomSheet(BuildContext context, Option option) {
    bool correct = option.correct;
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

class StartPage extends StatelessWidget {
  final Category category;

  StartPage(this.category);

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

class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

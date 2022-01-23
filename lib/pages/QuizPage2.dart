import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_bsp/models/question.dart';
import 'package:provider/provider.dart';

class QuizPage extends StatelessWidget {
  static const routeName = "/QuizPage";

  const QuizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    final questions =
    ModalRoute
        .of(context)!
        .settings
        .arguments as List<Question>;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Fragen"),
        ),
        body: PageView.builder(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            controller: QuizPageStage();
}

class _QuizPageStage extends State<QuizPage> {
  bool btnPressed = false;
  int currentQuestionIndex = 0;
  double _progress = 0;
  late Option _selected;

  double get progress => _progress;

  Option get selected => _selected;

  set progress(double newValue) {
    _progress = newValue;
  }

  set selected(Option newValue) {
    _selected = newValue;
  }

  createQuestionPage(List<Question> questions, int index) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              questions[0].question,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Divider(),
          for (int i = 0; i < questions[index].answers.length; i++)
            createQuestion(questions[index].answers.keys.elementAt(i),
                questions[0].answers.values.elementAt(i)),
          Divider(),
        ],
      ),
    );
  }

  createQuestionPage2(List<Question> questions, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            questions[0].question,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        Divider(),
        for (int i = 0; i < questions[index].answers.length; i++)
          createQuestion(questions[index].answers.keys.elementAt(i),
              questions[0].answers.values.elementAt(i)),
        Divider(),
      ],
    );
  }

  createQuestion(String text, bool type) {
    return Container(
      width: double.infinity,
      height: 50.0,
      margin: EdgeInsets.only(bottom: 20, left: 12, right: 12),
      child: RawMaterialButton(
        fillColor: btnPressed
            ? type
            ? Colors.green
            : Colors.red
            : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        onPressed: () {
          setState(() {
            btnPressed = true;
          });
        },
        child: Text(text),
      ),
    );
  }

  crateSmallProgressDot() {
    //   return Padding;
    //   d:
    //   Text(text)
    //   ,(
    //   padding: EdgeInsets.all(2),
    //   child: Container(
    //   width: 5,
    //   height: 5,
    //   decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black),
    //   ),
    //   );
    // }
  }

  class QuestionPage extends StatelessWidget {
  final Question question;

  QuestionPage({this.question});

  @override
  Widget build(BuildContext context) {
  var state = Provider.of<_QuizPageStage>(context);

  return Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
  Expanded(
  child: Container(
  padding: EdgeInsets.all(16),
  alignment: Alignment.center,
  child: Text(question.question),
  )
  ),
  Container(
  padding: EdgeInsets.all(20),
  child: Column(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: question.options.map((opt) {
  return Container(
  height: 90,
  margin: EdgeInsets.only(bottom: 10),
  color: Colors.black,
  child: InkWell(
  onTap: () {
  state.selected = opt;
  },
  child: Container(
  padding: EdgeInsets.all(16),
  child: Row(
  children: [
  Icon(
  state.selected == opt
  ? FontAwesomeIcons.checkCircle
      : FontAwesomeIcons.circle,
  size: 30),
  Expanded(
  child: Container(
  margin: EdgeInsets.only(left: 16),
  child: Text(
  opt.value,
  style: Theme
      .of(context)
      .textTheme
      .bodyText2,
  ),
  )
  )
  ],
  ),
  ),
  ),
  )
  }).toList(),
  ),
  )
  ],
  )
  }


  }

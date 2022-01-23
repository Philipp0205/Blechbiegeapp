import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/models/category.dart';
import 'package:open_bsp/models/question.dart';

class QuizPage extends StatefulWidget {
  static const routeName = "/QuizPage";

  const QuizPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuizPageStage();
}

class _QuizPageStage extends State<QuizPage> {
  bool btnPressed = false;
  int currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    final questions =
        ModalRoute.of(context)!.settings.arguments as List<Question>;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Fragen"),
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int i = 0; i < questions.length; i++)
                    crateSmallProgressDot(),
                ],
              ),
              Divider(),
              Navigator(
                pages: [
                  MaterialPage(child: createQuestionPage(questions, 0)),
                ],
                onPopPage: (route, result) {
                  if (!route.didPop(result)) return false;

                  return true;
                },
              ),
              // PageView.builder(
              //   controller: controller,
              //   itemBuilder: (BuildContext context, int index) {
              //     return createQuestionPage2(questions, index);
              //    },
              // ),
            ],
          ),
        ),
      ),
    );
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
    return Padding(
      padding: EdgeInsets.all(2),
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black),
      ),
    );
  }
}

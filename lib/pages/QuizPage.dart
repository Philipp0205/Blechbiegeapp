import 'package:flutter/material.dart';
import 'package:open_bsp/db/QuestionDb.dart';
import 'package:open_bsp/models/category.dart';
import 'package:open_bsp/models/question.dart';
import 'package:open_bsp/pages/quiz/QuestionPage.dart';
import 'package:open_bsp/pages/quiz/QuizStartPage.dart';
import 'package:open_bsp/pages/quiz/ResultPage.dart';
import 'package:provider/provider.dart';

import 'loading.dart';

class QuizPageState with ChangeNotifier {
  double _progress = -1;
  int _index = 0;
  Option? _selected;
  MaterialColor _cardColor = Colors.blue;

  late Category category;

  final PageController controller = PageController();

  get getSelected => _selected;

  get getProgress => _progress;

  get getCardColor => _cardColor;

  get getIndex => _index;

  set setSelected(Option option) {
    _selected = option;
    notifyListeners();
  }

  set setProgress(double progress) {
    _progress = double.parse(progress.toStringAsFixed(2));
    notifyListeners();
  }

  set setIndex(int index) {
    _index = index;
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

  const QuizPage4({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Category ${category.name}');
    QuestionDb db = QuestionDb.instance;

    List<Question> emptyQuestions = [];

    return ChangeNotifierProvider(
      create: (_) => QuizPageState(),
      child: FutureBuilder<List<Question>>(
        initialData: emptyQuestions,
        future: db.getAllQuestionsOfCategory(category.name),
        builder: (context, snapshot) {
          var state = Provider.of<QuizPageState>(context);

          if (!snapshot.hasData || snapshot.hasError) {
            return Loader();
          } else {
            List<Question> questions = snapshot.data!;
            print("questions length " + questions.length.toString());
            return Scaffold(
              appBar: AppBar(
                title: Container(
                    child: Row(
                  children: [
                    Text("Quiz"),
                  ],
                )),
              ),
              body: Column(
                children: [
                  LinearProgressIndicator(
                    value: state.getProgress,
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: state.controller,
                      onPageChanged: (int index) {
                        state.setProgress = (index / (questions.length + 1));
                        state.setIndex = index - 1;
                        // db.updateStat(category.name + 'Progress', state.getProgress);
                        category.setCompletion(state._progress);
                        db.updateCategory(category);
                        // Provider.of<CategorySelectionPage2>(context).notifyListeners();
                      },
                      itemBuilder: (context, index) {
                        print(index);
                        if (index == 0) {
                          return QuizStartPage(category);
                        } else if (index == questions.length + 1) {
                          return ResultPage(category);
                        } else {
                          return QuestionPage(questions[index - 1]);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

createQuestionPages(List<Question> questions) {
  List<Widget> widgets =
      questions.map((question) => QuestionPage(question)).toList();
  return widgets;
}







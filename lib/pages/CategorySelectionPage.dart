import 'package:flutter/material.dart';
import 'package:open_bsp/models/category.dart';
import 'package:open_bsp/models/question.dart';

class QuizCategoryPage extends StatefulWidget {
  static const routeName = '/';

  const QuizCategoryPage({Key? key}) : super(key: key);

  @override
  _QuizCategoryPageState createState() => _QuizCategoryPageState();
}

class _QuizCategoryPageState extends State<QuizCategoryPage> {
  late List<Category> categoryList = [];

  @override
  void initState() {
    Category category1 =
        new Category(1, "Allgemeine Fragen zum Bodensee", "waves.png");

    Option option1 = new Option(false, "30km/h");
    Option option2 = new Option(true, "40km/h");
    Option option3 = new Option(false, "10km/h");

    List<Option> options1 = [];
    options1.add(option1);
    options1.add(option2);
    options1.add(option3);

    Question question1 = new Question(id: 2, question: "Das ist eine Testfrage", options: options1);

    Option option4 = new Option(false, "Antwort 1");
    Option option5 = new Option(true, "Antwort 2 ");
    Option option6 = new Option(false, "Antwort 3");

    List<Option> options2 = [];
    options2.add(option4);
    options2.add(option5);
    options2.add(option6);

    Question question2 = new Question(id: 3, options: options2, question: "Die ist eine weitere Frage");

    category1.addQuestion(question1);
    category1.addQuestion(question2);
    categoryList.add(category1);

    categoryList.add(new Category(1, "Schallzeichen", "bell.png"));
    categoryList.add(new Category(1, "Navigation", "compass.png"));
    categoryList.add(new Category(1, "Lichtzeichen", "lighthouse.png"));
    categoryList.add(new Category(1, "Umweltschutz", "seagull.png"));
    categoryList.add(new Category(1, "Seemannschaft", "knot.png"));
    categoryList.add(new Category(1, "Motorboot Fahrregeln", "propeller.png"));
    categoryList.add(new Category(1, "Segeln Allgemient", "sailboat.png"));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Kategorien"),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Wrap(
                direction: Axis.horizontal,
                children: categoryList
                    .map((category) => GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/Quiz",
                                arguments: category.questions);
                          },
                          child: Container(
                            width: 140,
                            height: 140,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage(
                                      "assets/images/" + category.imagePath),
                                  width: 50,
                                ),
                                Text(
                                  category.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ))
          ],
        ),
      ),
    ));
  }
}

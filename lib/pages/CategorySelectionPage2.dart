import 'package:flutter/material.dart';
import 'package:open_bsp/db/CsvService.dart';
import 'package:open_bsp/db/DbService.dart';
import 'package:open_bsp/models/Dog.dart';
import 'package:open_bsp/models/category.dart';
import 'package:open_bsp/models/question.dart';
import 'package:open_bsp/pages/QuizPage.dart';

import 'Settings.dart';

class QuizCategoryPage2 extends StatefulWidget {
  static const routeName = '/';

  const QuizCategoryPage2({Key? key}) : super(key: key);

  @override
  _QuizCategoryPage2State createState() => _QuizCategoryPage2State();
}

class _QuizCategoryPage2State extends State<QuizCategoryPage2> {
  late List<Category> categoryList = [];
  DbService dbService = new DbService();

  @override
  void initState() {
    CsvService csvService = new CsvService();
    csvService.loadCsv();
    categoryList = csvService.getCategories();
    print("categoryList");
    print(categoryList);

    Category category1 =
        new Category(1, "Allgemeine Fragen zum Bodensee", "wavescard.png");

    Option option1 = new Option(false, "30km/h");
    Option option2 = new Option(true, "40km/h");
    Option option3 = new Option(false, "10km/h");

    List<Option> options1 = [];
    options1.add(option1);
    options1.add(option2);
    options1.add(option3);

    Question question1 = new Question(options1, "Das ist eine Testfrage");

    Option option4 = new Option(false, "Antwort 1");
    Option option5 = new Option(true, "Antwort 2 ");
    Option option6 = new Option(false, "Antwort 3");

    List<Option> options2 = [];
    options2.add(option4);
    options2.add(option5);
    options2.add(option6);

    Question question2 = new Question(options2, "Dies ist einer weitere Frage");

    category1.addQuestion(question1);
    category1.addQuestion(question2);
    categoryList.add(category1);

    categoryList.add(new Category(1, "Schallzeichen", "bellcard.png"));
    // categoryList.add(new Category(1, "Navigation", "compass.png"));
    // categoryList.add(new Category(1, "Lichtzeichen", "lighthouse.png"));
    // categoryList.add(new Category(1, "Umweltschutz", "seagull.png"));
    // categoryList.add(new Category(1, "Seemannschaft", "knot.png"));
    // categoryList.add(new Category(1, "Motorboot Fahrregeln", "propeller.png"));
    // categoryList.add(new Category(1, "Segeln Allgemein", "sailboat.png"));

    testDb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Kategorien"), actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Settings(),
                ),
              );
            },
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ]),
        body: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          primary: false,
          padding: const EdgeInsets.all(20.0),
          children:
              categoryList.map((category) => CategoryCard(category)).toList(),
        ),
      ),
    );
  }

  void testDb() async {
    print('testdb');
    // Create a Dog and add it to the dogs table

    var fido = Dog(
      id: 0,
      name: 'Fido',
      age: 35,
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  CategoryCard(this.category);

  CsvService csvService = new CsvService();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Hero(
        tag: category.imagePath,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: InkWell(
            onTap: () {
              csvService.loadCsv();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuizPage4(category),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/" + category.imagePath,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                        child: Text(
                          category.name,
                          style: TextStyle(
                              height: 1.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

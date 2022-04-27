import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_bsp/common/ApplicationsColors.dart';
import 'package:open_bsp/db/CsvService.dart';
import 'package:open_bsp/models/category.dart';
import 'package:open_bsp/pages/QuizPage.dart';

import '../db/QuestionDb.dart';
import 'Settings.dart';
import 'loading.dart';

class QuizCategoryPage2 extends StatefulWidget {
  static const routeName = '/';

  const QuizCategoryPage2({Key? key}) : super(key: key);

  @override
  _QuizCategoryPage2State createState() => _QuizCategoryPage2State();
}

class _QuizCategoryPage2State extends State<QuizCategoryPage2> {
  List<Category> categories = [];
  CsvService csvService = new CsvService();

  QuestionDb db = QuestionDb.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: db.getCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          // db.initQuestionsTable();
          // db.categoryTable();
          csvService.mapCsvToCategories('assets/misc/test.csv');
          return Loader();
        } else {
          return Scaffold(
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
              children: snapshot.data!
                  .map((category) => CategoryCard(category))
                  .toList(),
              // children: snapshot.data!
              //     .map((category) => CategoryCard(category))
              //     .toList(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.school),
                  label: 'Lernen',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.schedule),
                  label: 'Prüfung',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Statistik',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  CategoryCard(this.category);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => QuizPage4(category: category),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: category.imagePath,
              child: Container(
                height: 100,
                color: Color(int.parse('0xff${category.color}')),
                // color: Colors.red,
                child: Center(
                    child: Container(
                        height: 80,
                        child: Image.asset(
                            'assets/images/${category.imagePath}'))),
              ),
              // child: Image.asset(
              //   'assets/images/${category.imagePath}',
              // ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                    child: Text(
                      category.name,
                      style:
                          TextStyle(height: 1.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

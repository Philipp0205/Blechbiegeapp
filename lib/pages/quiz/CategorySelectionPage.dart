import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_bsp/db/CsvService.dart';
import 'package:open_bsp/models/category.dart';
import 'package:open_bsp/pages/FileInfoCard.dart';
import 'package:open_bsp/pages/QuizPage.dart';

import '../../db/QuestionDb.dart';
import '../loading.dart';

class CategorySelectionPage extends StatefulWidget {
  CategorySelectionPage({Key? key}) : super(key: key);

  @override
  CategorySelectionPageState createState() => CategorySelectionPageState();
}

class CategorySelectionPageState extends State<CategorySelectionPage> {
  List<Category> categories = [];

  CsvService csvService = new CsvService();
  QuestionDb db = QuestionDb.instance;

  @override
  Widget build(BuildContext context) {
    Stream<List<Category>> categoryStream = db.getCategories().asStream();

    return StreamBuilder<List<Category>>(
      stream: categoryStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          // csvService.mapCsvToCategories('assets/misc/test.csv');
          return Loader();
        } else {
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            primary: false,
            padding: const EdgeInsets.all(20.0),
            children: snapshot.data!
                .map((category) => CategoryCard(category))
                .toList(),
          );
        }
      },
    );
  }
}

class _CategoryCardState extends State<CategoryCard> {
  QuestionDb db = QuestionDb.instance;

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
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => QuizPage4(category: widget.category),
            ),
          )
              .then((_) {
            setState(() {});
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.category.imagePath,
              child: Container(
                height: 100,
                color: Color(int.parse('0xff${widget.category.color}')),
                child: Center(
                    child: Container(
                        height: 80,
                        child: Image.asset(
                            'assets/images/${widget.category.imagePath}'))),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                    child: Column(
                      children: [
                        Container(
                          height: 46,
                          child: Text(
                            widget.category.name,
                            style: TextStyle(
                                height: 1.5, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(top: 5, left: 5, right: 5),
                        child: Column(
                          children: [
                            ProgressLine(
                                percentage:
                                    updateCompletionRate(widget.category)),
                          ],
                        ))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int updateCompletionRate(Category category) {
    return (category.completionRate.toDouble() * 100).toInt();
  }
}

class CategoryCard extends StatefulWidget {
  final Category category;

  CategoryCard(this.category);

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

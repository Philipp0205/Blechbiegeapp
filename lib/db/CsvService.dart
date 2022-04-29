import 'dart:io';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_bsp/db/QuestionDb.dart';
import 'package:open_bsp/models/category.dart';

import '../models/question.dart';

class CsvService {
  List<Category> categories = [];

  _loadCsv(String pathToCsv) async {
    final _rawData = await rootBundle.loadString(pathToCsv);
    return CsvToListConverter().convert(_rawData);
  }

  Future<List<Category>> mapCsvToCategories(pathToCsv) async {
    print('mapCsvToCategories');
    final _rawData = await rootBundle.loadString(pathToCsv);

    var d = new FirstOccurrenceSettingsDetector(
        eols: ['\r\n', '\n'], textDelimiters: ['"', "'"]);

    List<List<dynamic>> listData =
        CsvToListConverter(csvSettingsDetector: d).convert(_rawData);
    List<Category> categories = [];

    int index = 0;
    listData.forEach((row) {
      categories.add(new Category(
          id: index, name: row[0], imagePath: row[1], color: row[2], completionRate: row[3]));
      index++;
      print('Question ${row[0]}');
    });
    return categories;
  }

  Future<List<Question>> mapCsvToQuestions(pathToCsv) async {
    List<Question> questions = [];

    final _rawData = await rootBundle.loadString(pathToCsv);

    var d = new FirstOccurrenceSettingsDetector(
        eols: ['\r\n', '\n'], textDelimiters: ['"', "'"]);

    List<List<dynamic>> listData =
        CsvToListConverter(csvSettingsDetector: d).convert(_rawData);

    int index = 0;
    listData.forEach((row) {
      List<Option> options = [
        new Option(true, row[2]),
        new Option(false, row[3]),
        new Option(false, row[4])
      ];
      questions.add(new Question(
          id: index, category: row[5], question: row[1], options: options));
      index++;
    });
    return questions;
  }

  void saveQuestionsToDatabase(List<Question> questions) {
    QuestionDb questionDb = QuestionDb.instance;
    questions.forEach((question) {
      questionDb.insertQuestion(question);
    });
  }

  void saveCategoriesToDatabase(List<Category> categories) {
    QuestionDb questionDb = QuestionDb.instance;
    categories.forEach((category) {
      print(category.name);
      questionDb.insertCategory(category);
    });
  }
}

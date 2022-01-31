import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_bsp/models/category.dart';

class CsvService {
  List<Category> categories = [];

  loadCsv() async {
    final _rawData = await rootBundle.loadString("assets/misc/test.csv");
    List<List<dynamic>> _listData = CsvToListConverter().convert(_rawData);

    _mapCsvToCategories(_listData);

    _listData.forEach((element) {
      element.forEach((element) {});
    });
  }

  _mapCsvToCategories(List<List<dynamic>> csvData) async {
    List<Category> categories = [];

    csvData.forEach((row) {
      row.forEach((column) {
        categories.add(new Category(0, row[0], row[1]));
      });
    });

    print(categories[0].name);
    this.categories = categories;
  }

  List<Category> getCategories() {
    return this.categories;
  }
}

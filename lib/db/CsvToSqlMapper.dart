
import 'package:open_bsp/db/CsvService.dart';
import 'package:open_bsp/db/QuestionDb.dart';

import '../models/question.dart';

class CsvToSqlMapper {
  CsvService csvService = new CsvService();
  QuestionDb questionDb = QuestionDb.instance;


}
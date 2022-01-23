import 'package:open_bsp/models/question.dart';

class Category {
  final int id;
  final String name;
  final String imagePath;
  final List<Question> questions = [];

  Category(this.id, this.name, this.imagePath);

  addQuestion(Question question) {
    this.questions.add(question);
  }

  static jsonToObject(dynamic json) {
    return Category(json["id"], json["name"], json["imagePath"]);
  }
}

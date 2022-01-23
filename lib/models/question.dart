class Question {
  String question = '';
  List<Option> options = [];

  Question(this.options, this.question);

  // Question.fromMap(Map data) {
  //   question = data['question'] ?? '';
  //   options = (data['options'] as List ?? []).map((v) => Option.fromMap(v)).toList();
  // }
}

class Option {
  String value = '';
  bool correct = false;

  Option(this.correct, this.value);

  Option.fromMap(Map data) {
    value = data['value'];
    correct = data['correct'];
  }
}

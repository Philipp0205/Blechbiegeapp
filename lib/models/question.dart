class Question {
  final int id;
  final String category;
  final String question;
  final List<Option> options;

  const Question({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
  });

  @override
  String toString() {
    return 'Question{id: $id, question: $question}';
  }

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'correctAnswer': options[0].value,
      'falseAnswer1': options[1].value,
      'falseAnswer2': options[2].value,
    };
  }
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
import 'package:open_bsp/models/question.dart';

class Category {
  final int id;
  final String name;
  final String imagePath;
  final String color;
  double completionRate = 0;
  int timesCompleted = 0;

  Category({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.color,
    required this.completionRate,
    required this.timesCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'color': color,
      'completion': completionRate,
      'timesCompleted': timesCompleted,
    };
  }

  void setCompletion(double completionRate) {
    this.completionRate = completionRate;
  }

  void setTimesCompleted(int timesCompleted) {
    this.timesCompleted = timesCompleted;
  }
}

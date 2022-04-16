import 'package:open_bsp/models/question.dart';

class Category {
  final int id;
  final String name;
  final String imagePath;
  final String color;

  const Category({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'color': color,
    };
  }
}

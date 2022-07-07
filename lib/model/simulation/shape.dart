import 'dart:ui';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_bsp/model/simulation/shape_type.dart';

import '../line.dart';

part 'shape.g.dart';

/// Represents a simple shape. For example different tools for bending metal
/// sheets.
@HiveType(typeId: 1)
class Shape {
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<Line> lines;
  @HiveField(3)
  final ShapeType type;

  const Shape({required this.name, required this.lines, required this.type});

  Shape copyWith({
    String? name,
    List<Offset>? path,
    List<Line>? lines,
    ShapeType? type,
  }) {
    return Shape(
      name: name ?? this.name,
      lines: lines ?? this.lines,
      type: type ?? this.type
    );
  }
}

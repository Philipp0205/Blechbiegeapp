import 'dart:ui';

import '../../pages/configuration_page/add_shape_bottom_sheet.dart';
import '../Line2.dart';

/// Represents a shape. For example different tools for bending metal
/// sheets.
class Shape {
  final String name;
  final List<Line2> lines;
  final ShapeType type;

  const Shape({required this.name, required this.lines, required this.type});

  Shape copyWith({
    String? name,
    List<Offset>? path,
    List<Line2>? lines,
    ShapeType? type,
  }) {
    return Shape(
      name: name ?? this.name,
      lines: lines ?? this.lines,
      type: type ?? this.type
    );
  }
}

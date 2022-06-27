import 'dart:ui';

import '../../pages/configuration_page/add_shape_bottom_sheet.dart';

/// Represents a shape. For example different tools for bending metal
/// sheets.
class Shape {
  final String name;
  final List<Offset> path;
  final ShapeType type;

  const Shape({required this.name, required this.path, required this.type});

  Shape copyWith({
    String? name,
    List<Offset>? path,
    ShapeType? type,
  }) {
    return Shape(
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type
    );
  }
}

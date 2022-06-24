import 'dart:ui';

/// Represents a shape. For example different tools for bending metal
/// sheets.
class Shape {
  final String name;
  final List<Offset> path;

  const Shape({required this.name, required this.path});

  Shape copyWith({
    String? name,
    List<Offset>? path,
  }) {
    return Shape(
      name: name ?? this.name,
      path: path ?? this.path,
    );
  }
}

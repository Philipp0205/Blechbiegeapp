import 'dart:ui';

/// Model for an edge with is part of a [Segment]
///
/// The [copyWith()] method cann be used to
/// alter parameters of the segment (immutability pattern).
///
/// https://dart.academy/creational-design-patterns-for-dart-and-flutter-builder/
/// https://dart.academy/immutable-data-patterns-in-dart-and-flutter/
class Edge {
  final Offset a;
  final Offset b;

  final bool isSelected;
  final Color color;

  const Edge(
      {required this.a,
      required this.b,
      required this.isSelected,
      required this.color});

  Edge copyWith(Offset a, Offset b, bool isSelected, Color color) {
    return Edge(
        a: a ?? this.a,
        b: b ?? this.b,
        isSelected: isSelected ?? this.isSelected,
        color: color ?? this.color);
  }
}

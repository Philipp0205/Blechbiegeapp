import '../bloc /modes/edge.dart';

/// Model for a drawn segment on the canvas.
/// Only one Edge exists at runtime.
///
/// The [copyWith()] method cann be used to
/// alter parameters of the segment (immutability pattern).
///
/// https://dart.academy/creational-design-patterns-for-dart-and-flutter-builder/
/// https://dart.academy/immutable-data-patterns-in-dart-and-flutter/
class Segment2 {
  final List<Edge> edges;
  final double width;

  Segment2({required this.edges, required this.width});

  Segment2 copyWith({List<Edge>? edges, double? width}) {
    return Segment2(edges: edges ?? this.edges, width: width ?? this.width);
  }
}

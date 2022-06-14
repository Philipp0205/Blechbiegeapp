import 'dart:ui';

import 'package:open_bsp/model/segment_offset.dart';

/// Model for a drawn segment on the canvas.
/// Only one Edge exists at runtime.
///
/// The [copyWith()] method cann be used to
/// alter parameters of the segment (immutability pattern) so not all parameters
/// have to created again when changing the segment.
///
/// https://dart.academy/creational-design-patterns-for-dart-and-flutter-builder/
/// https://dart.academy/immutable-data-patterns-in-dart-and-flutter/
class Segment {
  final List<SegmentOffset> path;
  final double width;
  final Color color;

  Segment({required this.path, required this.width, required this.color});

  Segment copyWith({
    List<SegmentOffset>? path,
    double? width,
    Color? color,
  }) {
    return Segment(
      path: path ?? this.path,
      width: width ?? this.width,
      color: color ?? this.color,
    );
  }
}

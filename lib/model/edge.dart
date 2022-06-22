import 'package:open_bsp/model/segment_offset.dart';

class Edge {
  final SegmentOffset start;
  final SegmentOffset end;
  final double radius;
  final double angle;

  const Edge({
    required this.start,
    required this.end,
    required this.radius,
    required this.angle,
  });

  Edge copyWith({
    SegmentOffset? start,
    SegmentOffset? end,
    double? radius,
    double? angle,
  }) {
    return Edge(
      start: start ?? this.start,
      end: end ?? this.end,
      radius: radius ?? this.radius,
      angle: angle ?? this.angle,
    );
  }
}

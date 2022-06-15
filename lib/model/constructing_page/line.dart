import 'package:open_bsp/model/segment_offset.dart';

/// Represents a line with an [start] offset and an [end] offset.
class Line {
  final SegmentOffset start;
  final SegmentOffset end;

  const Line({required this.start, required this.end});
}

import '../model/segment.dart';

class SegmentsProvider {
  List<Segment> _segments = [];

  List<Segment> get segments => _segments;

  void addSegment(Segment segment) {
    _segments.add(segment);

  }

  void removeSegment(Segment segment) {
    _segments.remove(segment);
  }
}
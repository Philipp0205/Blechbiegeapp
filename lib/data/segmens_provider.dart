import '../model/segment_model.dart';

class SegmentsProvider {
  List<Segment> _segments = [];
  List<Segment> get segments => _segments;

  set segments(List<Segment> value) {
    _segments = value;
  }

  void addSegment(Segment segment) {
    _segments.add(segment);
  }

  void removeSegment(Segment segment) {
    _segments.remove(segment);
  }

  void deleteAllSegments() {
    _segments = [];
  }
}
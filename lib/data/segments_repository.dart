import 'package:open_bsp/data/segmens_provider.dart';

import '../model/segment_model.dart';

class SegmentsRepository {
  final SegmentsProvider _segmentsProvider = new SegmentsProvider();

  List<Segment> getAllSegments() {
    return _segmentsProvider.segments;
  }

  void addSegment(Segment segment) {
    _segmentsProvider.addSegment(segment);
  }

  void deleteAllSegments() {
    _segmentsProvider.deleteAllSegments();
  }
  void removeSegment(Segment segment) {
    _segmentsProvider.removeSegment(segment);
  }


  void setAllSegments(List<Segment> segments) {
    _segmentsProvider.segments = segments;

  }
}
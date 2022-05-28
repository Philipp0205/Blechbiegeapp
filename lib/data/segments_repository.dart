import 'package:open_bsp/data/segmens_provider.dart';

import '../model/segment.dart';

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
}
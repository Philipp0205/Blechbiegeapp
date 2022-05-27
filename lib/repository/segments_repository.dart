import 'package:open_bsp/repository/segments_provider.dart';

import '../model/segment.dart';

/// A repository to handle segement related requests.
class SegmentsResposiory {
  final SegmentsProvider _segmentsProvider = new SegmentsProvider();

  SegmentsResposiory({required SegmentsProvider segmentsProvider});


  List<Segment> getAllSegments() {
    return _segmentsProvider.segments;
  }

  List<Segment> getCurrentSegment() {
    return _segmentsProvider.currentSegment;
  }

  void addSegment(Segment segment) {
    _segmentsProvider.segments.add(segment);
  }


  void addCurrentSegment(Segment segment) {
    _segmentsProvider.segments.add(segment);
  }
}

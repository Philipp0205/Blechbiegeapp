import 'dart:math';

import 'package:open_bsp/model/segment_model.dart';

class LinkedSegment {
  Segment segmentA;
  Segment segmengB;

  List<Point> linkedPoints;

  LinkedSegment(this.segmentA, this.segmengB, this.linkedPoints);
}
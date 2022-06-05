import 'dart:ui';

import 'package:flutter/material.dart';

/// Simple Factory for creating Segments
class SegmentBuilder {
  List<Offset> path = [];
  List<Offset> selectedOffsets = [];
  Color color = Colors.black;
  double width = 5;
}
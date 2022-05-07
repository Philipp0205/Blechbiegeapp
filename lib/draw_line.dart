import 'package:flutter/material.dart';

class Segment {
  final List<Offset> path;
  Offset selectedEdge = new Offset(0, 0);
  Color color;
  bool isSelected = false;
  final double width;

  Segment(this.path, this.color, this.width);
}

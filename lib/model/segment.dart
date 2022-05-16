import 'package:flutter/material.dart';

class Segment {
  final List<Offset> path;
  Offset? selectedEdge;
  Color color;
  bool isSelected = false;
  bool highlightPoints = false;
  final double width;

  Segment(this.path, this.color, this.width);

  void setIsSelected(Offset? selectedEdge) {
    this.isSelected = true;
    this.selectedEdge = selectedEdge;
  }
}

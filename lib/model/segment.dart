import 'package:flutter/material.dart';

class Segment {
  final List<Offset> path;
  List<Offset> highlightedPointsInPath = [];
  Offset? selectedEdge;
  int indexOfSelectedPoint = 0;
  Color color;
  bool isSelected = false;
  bool highlightPoints = false;
  bool isLinked = true;
  final double width;

  Segment(this.path, this.color, this.width);

  void setIsSelected(Offset? selectedEdge) {
    this.isSelected = true;
    this.selectedEdge = selectedEdge;
    this.color = Colors.red;
  }
}

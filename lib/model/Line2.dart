import 'dart:ui';

import 'package:flutter/material.dart';

class Line {
  Offset start;
  Offset end;
  bool isSelected;

  Line({required this.start, required this.end, required this.isSelected});

  Line copyWith({
    Offset? start,
    Offset? end,
    bool? isSelected,
  }) {
    return Line(
      start: start ?? this.start,
      end: end ?? this.end,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

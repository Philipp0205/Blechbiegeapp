import 'dart:ui';

import 'package:flutter/material.dart';

class Line2 {
  Offset start;
  Offset end;
  bool isSelected;

  Line2({required this.start, required this.end, required this.isSelected});

  Line2 copyWith({
    Offset? start,
    Offset? end,
    bool? isSelected,
  }) {
    return Line2(
      start: start ?? this.start,
      end: end ?? this.end,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

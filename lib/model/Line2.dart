import 'dart:ui';

import 'package:flutter/material.dart';

class Line2 {
  Offset start;
  Offset end;
  Color? color = Colors.black;

  Line2({required this.start, required this.end, this.color});

  Line2 copyWith({
    Offset? start,
    Offset? end,
    Color? color,
  }) {
    return Line2(
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
    );
  }
}

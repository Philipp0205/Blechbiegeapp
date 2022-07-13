import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'line.g.dart';

@HiveType(typeId: 2)
class Line {
  @HiveField(1)
  Offset start;
  @HiveField(2)
  Offset end;
  @HiveField(3)
  bool isSelected;

  Line(
      {required this.start,
      required this.end,
      required this.isSelected,
      });

  Line copyWith({
    Offset? start,
    Offset? end,
    bool? isSelected,
    bool? isAdapterLine,
  }) {
    return Line(
      start: start ?? this.start,
      end: end ?? this.end,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

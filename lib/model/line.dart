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

  Map<String, dynamic> toMap() {
    return {
      'start': this.start,
      'end': this.end,
      'isSelected': this.isSelected,
    };
  }

  factory Line.fromMap(Map<String, dynamic> map) {
    return Line(
      start: map['start'] as Offset,
      end: map['end'] as Offset,
      isSelected: map['isSelected'] as bool,
    );
  }
}

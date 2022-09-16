import 'package:hive_flutter/hive_flutter.dart';

import '../line.dart';
import 'tool_type2.dart';

part 'tool.g.dart';

/// Represents a simple shape. For example different tools for bending metal
/// sheets.
@HiveType(typeId: 1)
class Tool {
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<Line> lines;
  @HiveField(3)
  final ToolType2 type;
  @HiveField(4)
  final bool isSelected;
  @HiveField(5)
  final List<Line> adapterLine;
  @HiveField(6)
  final double s;
  @HiveField(7)
  final bool isMirrored;

  const Tool({
    required this.name,
    required this.lines,
    required this.type,
    required this.isSelected,
    required this.adapterLine,
    required this.s,
    required this.isMirrored,
  });

  Tool copyWith({
    String? name,
    List<Line>? lines,
    ToolType2? type,
    bool? isSelected,
    List<Line>? adapterLine,
    double? s,
    bool? isMirrored,
  }) {
    return Tool(
      name: name ?? this.name,
      lines: lines != null ? List.from(lines) : List.from(this.lines),
      type: type ?? this.type,
      isSelected: isSelected ?? this.isSelected,
      adapterLine: adapterLine ?? this.adapterLine,
      s: s ?? this.s,
      isMirrored: isMirrored ?? this.isMirrored,
    );


  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'lines': this.lines,
      'type': this.type,
      'isSelected': this.isSelected,
      'adapterLine': this.adapterLine,
      's': this.s,
      'isMirrored': this.isMirrored,
    };
  }

  factory Tool.fromJson(Map<String, dynamic> map) {
    return Tool(
      name: map['name'] as String,
      lines: map['lines'] as List<Line>,
      type: map['type'] as ToolType2,
      isSelected: map['isSelected'] as bool,
      adapterLine: map['adapterLine'] as List<Line>,
      s: map['s'] as double,
      isMirrored: map['isMirrored'] as bool,
    );
  }
}

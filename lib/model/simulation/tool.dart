import 'dart:ui';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_bsp/model/simulation/tool_type.dart';

import '../line.dart';

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
  final ToolType type;
  @HiveField(4)
  final bool isSelected;

  const Tool({required this.name, required this.lines, required this.type, required this.isSelected});

  Tool copyWith({
    String? name,
    List<Line>? lines,
    ToolType? type,
    bool? isSelected,
  }) {
    return Tool(
      name: name ?? this.name,
      lines: lines ?? this.lines,
      type: type ?? this.type,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

import 'package:hive_flutter/hive_flutter.dart';

import '../line.dart';
import 'enums/tool_category_enum.dart';
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

  const Tool({
    required this.name,
    required this.lines,
    required this.type,
    required this.isSelected,
    required this.adapterLine,
  });



  Tool copyWith({
    String? name,
    List<Line>? lines,
    ToolType2? type,
    bool? isSelected,
    List<Line>? adapterLine,
    ToolCategoryEnum? category,
  }) {
    return Tool(
      name: name ?? this.name,
      lines: lines ?? this.lines,
      type: type ?? this.type,
      isSelected: isSelected ?? this.isSelected,
      adapterLine: adapterLine ?? this.adapterLine,
    );
  }
}

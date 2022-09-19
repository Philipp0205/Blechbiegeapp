import 'package:hive/hive.dart';
import 'package:open_bsp/model/simulation/enums/position_enum.dart';
import 'package:open_bsp/model/simulation/enums/tool_category_enum.dart';
import 'package:open_bsp/model/simulation/tool_type.dart';

part 'tool_type2.g.dart';

@HiveType(typeId: 4)
class ToolType2 {
  @HiveField(1)
  final String name;
  @HiveField(2)
  final ToolType type;
  @HiveField(3)
  final ToolCategoryEnum category;
  @HiveField(4)
  final PositionEnum position;

  const ToolType2(
      {required this.name,
      required this.type,
      required this.category,
      required this.position});

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'type': this.type,
      'category': this.category,
      'position': this.position,
    };
  }

  factory ToolType2.fromJson(Map<String, dynamic> map) {
    return ToolType2(
      name: map['name'] as String,
      type: map['type'] as ToolType,
      category: map['category'] as ToolCategoryEnum,
      position: map['position'] as PositionEnum,
    );
  }
}

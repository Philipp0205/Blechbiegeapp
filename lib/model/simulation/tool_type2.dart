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
}

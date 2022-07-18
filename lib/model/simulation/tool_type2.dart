import 'package:hive/hive.dart';
import 'package:open_bsp/model/simulation/tool_type.dart';

part 'tool_type2.g.dart';

@HiveType(typeId: 4)
class ToolType2 {
  @HiveField(1)
  final String name;
  @HiveField(2)
  final ToolType type;

  const ToolType2({required this.name, required this.type});
}
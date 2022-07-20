import 'package:hive/hive.dart';

part 'tool_category_enum.g.dart';
@HiveType(typeId: 7)
enum ToolCategoryEnum {
  @HiveField(1)
  BEAM,
  @HiveField(2)
  TRACK,
}

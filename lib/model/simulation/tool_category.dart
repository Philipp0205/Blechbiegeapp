import 'package:hive/hive.dart';

part 'tool_category.g.dart';
@HiveType(typeId: 7)
enum ToolCategory {
  @HiveField(1)
  BEAM,
  @HiveField(2)
  TRACK,
}

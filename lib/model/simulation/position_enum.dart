import 'package:hive/hive.dart';

part 'position_enum.g.dart';

@HiveType(typeId: 8)
enum PositionEnum {
  @HiveField(1)
  TOP,
  @HiveField(2)
  BOTTOM,
  @HiveField(3)
  LEFT
}

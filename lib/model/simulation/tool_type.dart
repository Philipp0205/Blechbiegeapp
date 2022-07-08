
import 'package:hive/hive.dart';

part 'tool_type.g.dart';

@HiveType(typeId: 4)
enum ToolType {
  @HiveField(1)
  lowerBeam,
  @HiveField(2)
  upperBeam,
  @HiveField(3)
  bendingBeam }

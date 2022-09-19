import 'package:hive/hive.dart';

part 'tool_type.g.dart';

@HiveType(typeId: 5)
enum ToolType {
  @HiveField(1)
  lowerBeam,
  @HiveField(2)
  upperBeam,
  @HiveField(3)
  bendingBeam,
  @HiveField(4)
  lowerTrack,
  @HiveField(5)
  upperTrack,
  @HiveField(6)
  bendingTrack,
  @HiveField(7)
  plateProfile


}

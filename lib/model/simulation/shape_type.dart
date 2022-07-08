
import 'package:hive/hive.dart';

part 'shape_type.g.dart';

@HiveType(typeId: 4)
enum ShapeType {
  @HiveField(1)
  lowerBeam,
  @HiveField(2)
  upperBeam,
  @HiveField(3)
  bendingBeam }

import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class Offset {
  @HiveField(1)
  final double x;
  @HiveField(2)
  final double y;
  const Offset(this.x, this.y);
}
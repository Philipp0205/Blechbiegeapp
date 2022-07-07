

import 'dart:ui';

import 'package:hive/hive.dart';

class OffsetAdapter extends TypeAdapter<Offset> {
  @override
  final int typeId = 3;

  @override
  Offset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Offset(
      fields[1] as double,
      fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Offset obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.dx)
      ..writeByte(2)
      ..write(obj.dy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OffsetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

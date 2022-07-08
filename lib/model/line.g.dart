// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LineAdapter extends TypeAdapter<Line> {
  @override
  final int typeId = 2;

  @override
  Line read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Line(
      start: fields[1] as Offset,
      end: fields[2] as Offset,
      isSelected: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Line obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.start)
      ..writeByte(2)
      ..write(obj.end)
      ..writeByte(3)
      ..write(obj.isSelected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

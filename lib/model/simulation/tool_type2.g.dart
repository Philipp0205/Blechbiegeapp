// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_type2.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ToolType2Adapter extends TypeAdapter<ToolType2> {
  @override
  final int typeId = 4;

  @override
  ToolType2 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ToolType2(
      name: fields[1] as String,
      type: fields[2] as ToolType,
      category: fields[3] as ToolCategoryEnum,
      position: fields[4] as PositionEnum,
    );
  }

  @override
  void write(BinaryWriter writer, ToolType2 obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.position);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolType2Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

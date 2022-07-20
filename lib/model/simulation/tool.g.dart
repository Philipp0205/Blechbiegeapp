// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ToolAdapter extends TypeAdapter<Tool> {
  @override
  final int typeId = 1;

  @override
  Tool read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tool(
      name: fields[1] as String,
      lines: (fields[2] as List).cast<Line>(),
      type: fields[3] as ToolType2,
      isSelected: fields[4] as bool,
      adapterLine: (fields[5] as List).cast<Line>(),
    );
  }

  @override
  void write(BinaryWriter writer, Tool obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.lines)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.isSelected)
      ..writeByte(5)
      ..write(obj.adapterLine);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

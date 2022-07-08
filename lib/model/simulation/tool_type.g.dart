// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ToolTypeAdapter extends TypeAdapter<ToolType> {
  @override
  final int typeId = 4;

  @override
  ToolType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return ToolType.lowerBeam;
      case 2:
        return ToolType.upperBeam;
      case 3:
        return ToolType.bendingBeam;
      default:
        return ToolType.lowerBeam;
    }
  }

  @override
  void write(BinaryWriter writer, ToolType obj) {
    switch (obj) {
      case ToolType.lowerBeam:
        writer.writeByte(1);
        break;
      case ToolType.upperBeam:
        writer.writeByte(2);
        break;
      case ToolType.bendingBeam:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

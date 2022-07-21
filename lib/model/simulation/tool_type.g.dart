// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ToolTypeAdapter extends TypeAdapter<ToolType> {
  @override
  final int typeId = 5;

  @override
  ToolType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return ToolType.lowerBeam;
      case 2:
        return ToolType.upperBeam;
      case 3:
        return ToolType.bendingBeam;
      case 4:
        return ToolType.lowerTrack;
      case 5:
        return ToolType.upperTrack;
      case 6:
        return ToolType.bendingTrack;
      case 7:
        return ToolType.plateProfile;
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
      case ToolType.lowerTrack:
        writer.writeByte(4);
        break;
      case ToolType.upperTrack:
        writer.writeByte(5);
        break;
      case ToolType.bendingTrack:
        writer.writeByte(6);
        break;
      case ToolType.plateProfile:
        writer.writeByte(7);
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

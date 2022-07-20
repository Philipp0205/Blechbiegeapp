// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PositionEnumAdapter extends TypeAdapter<PositionEnum> {
  @override
  final int typeId = 8;

  @override
  PositionEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return PositionEnum.TOP;
      case 2:
        return PositionEnum.BOTTOM;
      case 3:
        return PositionEnum.LEFT;
      default:
        return PositionEnum.TOP;
    }
  }

  @override
  void write(BinaryWriter writer, PositionEnum obj) {
    switch (obj) {
      case PositionEnum.TOP:
        writer.writeByte(1);
        break;
      case PositionEnum.BOTTOM:
        writer.writeByte(2);
        break;
      case PositionEnum.LEFT:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

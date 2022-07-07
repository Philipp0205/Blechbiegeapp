// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shape_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShapeTypeAdapter extends TypeAdapter<ShapeType> {
  @override
  final int typeId = 4;

  @override
  ShapeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return ShapeType.lowerBeam;
      case 2:
        return ShapeType.upperBeam;
      case 3:
        return ShapeType.bendingBeam;
      default:
        return ShapeType.lowerBeam;
    }
  }

  @override
  void write(BinaryWriter writer, ShapeType obj) {
    switch (obj) {
      case ShapeType.lowerBeam:
        writer.writeByte(1);
        break;
      case ShapeType.upperBeam:
        writer.writeByte(2);
        break;
      case ShapeType.bendingBeam:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShapeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

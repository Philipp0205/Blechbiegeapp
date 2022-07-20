// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_category_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ToolCategoryEnumAdapter extends TypeAdapter<ToolCategoryEnum> {
  @override
  final int typeId = 7;

  @override
  ToolCategoryEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return ToolCategoryEnum.BEAM;
      case 2:
        return ToolCategoryEnum.TRACK;
      default:
        return ToolCategoryEnum.BEAM;
    }
  }

  @override
  void write(BinaryWriter writer, ToolCategoryEnum obj) {
    switch (obj) {
      case ToolCategoryEnum.BEAM:
        writer.writeByte(1);
        break;
      case ToolCategoryEnum.TRACK:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolCategoryEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

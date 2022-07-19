// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ToolCategoryAdapter extends TypeAdapter<ToolCategory> {
  @override
  final int typeId = 7;

  @override
  ToolCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return ToolCategory.BEAM;
      case 2:
        return ToolCategory.TRACK;
      default:
        return ToolCategory.BEAM;
    }
  }

  @override
  void write(BinaryWriter writer, ToolCategory obj) {
    switch (obj) {
      case ToolCategory.BEAM:
        writer.writeByte(1);
        break;
      case ToolCategory.TRACK:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

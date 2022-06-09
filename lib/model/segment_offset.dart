import 'dart:ui';

class SegmentOffset {
  final Offset offset ;
  bool isSelected;

  SegmentOffset({required this.offset, required this.isSelected});

  SegmentOffset copyWith({
    Offset? offset,
    bool? isSelected,
  }) {
    return SegmentOffset(
      offset: offset ?? this.offset,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

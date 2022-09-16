import 'dart:ui';

class DebugOffset {
  final Offset offset;
  final Color color;

  const DebugOffset({required this.offset, required this.color});

  DebugOffset copyWith({
    Offset? offset,
    Color? color,
  }) {
    return DebugOffset(
      offset: offset ?? this.offset,
      color: color ?? this.color,
    );
  }
}


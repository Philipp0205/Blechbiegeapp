import 'dart:ui';

class DebuggingOffset {
  final Offset offset;
  final Color color;

  const DebuggingOffset({required this.offset, required this.color});

  DebuggingOffset copyWith({
    Offset? offset,
    Color? color,
  }) {
    return DebuggingOffset(
      offset: offset ?? this.offset,
      color: color ?? this.color,
    );
  }
}


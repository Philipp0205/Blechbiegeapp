import 'package:equatable/equatable.dart';

import '../../../../model/line.dart';
import '../../../../model/appmodes.dart';

class DrawingWidgetState extends Equatable {
  /// This list should always contains only 1 value but is a List to prevent an
  /// initial null value and the need to handle null values in general.
  /// It is easier to handle an empty list.
  final List<Line> lines;
  final List<Line> linesBeforeUndo;
  final List<Line> selectedLines;
  final Mode mode;
  final bool selectionMode;

  final double currentAngle;
  final double currentLength;

  const DrawingWidgetState({
    required this.mode,
    required this.linesBeforeUndo,
    required this.lines,
    required this.selectedLines,
    required this.selectionMode,
    required this.currentAngle,
    required this.currentLength,
  });

  @override
  List<Object?> get props => [mode, lines, selectedLines, selectionMode];

  DrawingWidgetState copyWith({
    List<Line>? lines,
    List<Line>? linesBeforeUndo,
    List<Line>? selectedLines,
    Mode? mode,
    bool? selectionMode,
    double? currentAngle,
    double? currentLength,
  }) {
    return DrawingWidgetState(
      lines: lines ?? this.lines,
      linesBeforeUndo: linesBeforeUndo ?? this.linesBeforeUndo,
      selectedLines: selectedLines ?? this.selectedLines,
      mode: mode ?? this.mode,
      selectionMode: selectionMode ?? this.selectionMode,
      currentAngle: currentAngle ?? this.currentAngle,
      currentLength: currentLength ?? this.currentLength,
    );
  }
}

class CurrentSegmentInitial extends DrawingWidgetState {
  final List<Line> lines;
  final List<Line> selectedLines;
  final List<Line> linesBeforeUndo;
  final Mode mode;
  final bool selectionMode;

  final double currentAngle;
  final double currentLength;

  CurrentSegmentInitial(
      {required this.selectedLines,
      required this.mode,
      required this.lines,
      required this.linesBeforeUndo,
      required this.selectionMode,
      required this.currentAngle,
      required this.currentLength})
      : super(
          mode: mode,
          lines: lines,
          linesBeforeUndo: linesBeforeUndo,
          selectedLines: selectedLines,
          selectionMode: selectionMode,
          currentAngle: currentAngle,
          currentLength: currentLength,
        );
}

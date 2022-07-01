import 'package:equatable/equatable.dart';

import '../../../model/Line2.dart';
import '../../../model/appmodes.dart';
import '../../../model/segment_widget/segment.dart';

class DrawingWidgetState extends Equatable {
  /// This list should always contains only 1 value but is a List to prevent an
  /// initial null value and the need to handle null values in general.
  /// It is easier to handle an empty list.
  final List<Line2> lines;
  final List<Line2> selectedLines;
  final Mode mode;
  final bool selectionMode;

  const DrawingWidgetState({
    required this.mode,
    required this.lines,
    required this.selectedLines,
    required this.selectionMode,
  });

  DrawingWidgetState copyWith({
    List<Line2>? lines,
    List<Line2>? selectedLines,
    Mode? mode,
    bool? selectionMode,
  }) {
    return DrawingWidgetState(
      lines: lines ?? this.lines,
      selectedLines: selectedLines ?? this.selectedLines,
      mode: mode ?? this.mode,
      selectionMode: selectionMode ?? this.selectionMode,
    );
  }

  @override
  List<Object?> get props => [mode, lines, selectedLines, selectionMode];
}

class CurrentSegmentInitial extends DrawingWidgetState {
  final List<Line2> lines;
  final List<Line2> selectedLines;
  final Mode mode;
  final bool selectionMode;

  CurrentSegmentInitial({
    required this.selectedLines,
    required this.mode,
    required this.lines,
    required this.selectionMode,
  }) : super(
          mode: mode,
          lines: lines,
          selectedLines: selectedLines,
          selectionMode: selectionMode,
        );
}

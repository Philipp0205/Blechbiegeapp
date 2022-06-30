import 'package:equatable/equatable.dart';

import '../../../model/Line2.dart';
import '../../../model/appmodes.dart';
import '../../../model/segment_widget/segment.dart';

class DrawingWidgetState extends Equatable {
  /// This list should always contains only 1 value but is a List to prevent an
  /// initial null value and the need to handle null values in general.
  /// It is easier to handle an empty list.
  final List<Segment> segment;
  final List<Line2> lines;
  final Mode mode;
  final bool selectionMode;

  const DrawingWidgetState({
    required this.segment,
    required this.mode,
    required this.lines,
    required this.selectionMode,
  });

  DrawingWidgetState copyWith({
    List<Segment>? segment,
    List<Line2>? lines,
    List<Line2>? selectedLines,
    Mode? mode,
    bool? selectionMode,
  }) {
    return DrawingWidgetState(
      segment: segment ?? this.segment,
      lines: lines ?? this.lines,
      mode: mode ?? this.mode,
      selectionMode: selectionMode ?? this.selectionMode,
    );
  }

  @override
  List<Object?> get props => [segment, mode, lines, selectionMode];
}

class CurrentSegmentInitial extends DrawingWidgetState {
  final List<Segment> segment;
  final List<Line2> lines;
  final Mode mode;
  final bool selectionMode;

  CurrentSegmentInitial({
    required this.segment,
    required this.mode,
    required this.lines,
    required this.selectionMode,
  }) : super(
            segment: segment,
            mode: mode,
            lines: lines,
            selectionMode: selectionMode,
  );
}

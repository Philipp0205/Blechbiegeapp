import '../../../model/Line2.dart';
import '../../../model/appmodes.dart';
import '../../../model/segment_widget/segment.dart';

abstract class DrawingWidgetState {
  /// This list should always contains only 1 value but is a List to prevent an
  /// initial null value and the need to handle null values in general.
  /// It is easier to handle an empty list.
  final List<Segment> segment;
  final List<Line2> lines;
  final Mode mode;

  const DrawingWidgetState(
      {required this.segment, required this.mode, required this.lines});

  @override
  List<Object?> get props => [segment, mode, lines];
}

class CurrentSegmentInitial extends DrawingWidgetState {
  final List<Segment> segment;
  final List<Line2> lines;
  final Mode mode;

  CurrentSegmentInitial(
      {required this.segment, required this.mode, required this.lines})
      : super(segment: segment, mode: mode, lines: lines);
}

class CurrentSegmentUpdate extends DrawingWidgetState {
  final List<Segment> segment;
  final Mode mode;

  CurrentSegmentUpdate({required this.segment, required this.mode})
      : super(segment: segment, mode: mode, lines: []);
}

class CurrentSegmentSelect extends DrawingWidgetState {
  CurrentSegmentSelect({required List<Segment> segment})
      : super(segment: segment, mode: Mode.defaultMode, lines: []);
}

class CurrentSegmentDelete extends DrawingWidgetState {
  CurrentSegmentDelete()
      : super(segment: [], mode: Mode.defaultMode, lines: []);
}

/// The line drawn on the canvas updates.
class LineUpdate extends DrawingWidgetState {
  final List<Line2> lines;

  LineUpdate({required this.lines})
      : super(segment: [], mode: Mode.defaultMode, lines: lines);
}

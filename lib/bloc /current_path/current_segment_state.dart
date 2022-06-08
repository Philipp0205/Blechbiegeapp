import '../../model/appmodes.dart';
import '../../model/segment2.dart';

abstract class CurrentSegmentState {
  /// This list should always contains only 1 value but is a List to prevent an
  /// initial null value and the need to handle null values in general.
  /// It is easier to handle an empty list.
  final List<Segment2> segment;
  final Mode mode;

  const CurrentSegmentState(
      {required this.segment, required this.mode});
}

class CurrentSegmentInitial extends CurrentSegmentState {
  final List<Segment2> segment;
  final Mode mode;

  const CurrentSegmentInitial({required this.segment, required this.mode})
      : super(segment: segment, mode: mode);
}

class CurrentSegmentUpdate extends CurrentSegmentState {
  final List<Segment2> segment;
  final Mode mode;

  const CurrentSegmentUpdate({required this.segment, required this.mode})
      : super(segment: segment, mode: mode);
}

class CurrentSegmentSelect extends CurrentSegmentState {
  CurrentSegmentSelect(
      {required List<Segment2> segment})
      : super(segment: segment, mode: Mode.defaultMode);
}

class CurrentSegmentDelete extends CurrentSegmentState {
  CurrentSegmentDelete() : super(segment: [], mode: Mode.defaultMode);
}

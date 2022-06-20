import '../../model/appmodes.dart';
import '../../model/segment_widget/segment.dart';

abstract class SegmentWidgetBlocState {
  /// This list should always contains only 1 value but is a List to prevent an
  /// initial null value and the need to handle null values in general.
  /// It is easier to handle an empty list.
  final List<Segment> segment;
  final Mode mode;


  const SegmentWidgetBlocState(
      {required this.segment, required this.mode});


  @override
  List<Object?> get props => [segment, mode];

}

class CurrentSegmentInitial extends SegmentWidgetBlocState {
  final List<Segment> segment;
  final Mode mode;

  const CurrentSegmentInitial({required this.segment, required this.mode})
      : super(segment: segment, mode: mode);
}

class CurrentSegmentUpdate extends SegmentWidgetBlocState {
  final List<Segment> segment;
  final Mode mode;

  const CurrentSegmentUpdate({required this.segment, required this.mode})
      : super(segment: segment, mode: mode);
}

class CurrentSegmentSelect extends SegmentWidgetBlocState {
  CurrentSegmentSelect(
      {required List<Segment> segment})
      : super(segment: segment, mode: Mode.defaultMode);
}

class CurrentSegmentDelete extends SegmentWidgetBlocState {
  CurrentSegmentDelete() : super(segment: [], mode: Mode.defaultMode);
}

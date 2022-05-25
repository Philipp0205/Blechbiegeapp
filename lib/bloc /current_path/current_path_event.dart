part of 'current_path_bloc.dart';

abstract class CurrentPathEvent extends Equatable {
  const CurrentPathEvent();

  @override
  List<Object> get props => [];
}

class OnPanStarted extends CurrentPathEvent{
  final List<Segment> currentSegment;
  const OnPanStarted({required this.currentSegment});
}

class OnPanUpdated extends CurrentPathEvent {
  final List<Segment> currentSegment;
  final Offset offset;

  const OnPanUpdated({required this.currentSegment, required this.offset});
}

class OnSegmentDeleted extends CurrentPathEvent {
  OnSegmentDeleted();
}

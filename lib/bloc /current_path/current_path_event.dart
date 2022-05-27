part of 'current_path_bloc.dart';

abstract class CurrentPathEvent extends Equatable {
  const CurrentPathEvent();

  @override
  List<Object> get props => [];
}

class PanStarted extends CurrentPathEvent{
  final Offset firstDrawnOffset;
  const PanStarted({required this.firstDrawnOffset});
}

class PanUpdated extends CurrentPathEvent {
  final List<Segment> currentSegment;
  final Offset offset;

  const PanUpdated({required this.currentSegment, required this.offset});
}

class PanEnded extends CurrentPathEvent {
  final List<Segment> currentSegment;
  PanEnded({required this.currentSegment});
}

class CurrentSegmentDeleted extends CurrentPathEvent {
  CurrentSegmentDeleted();
}

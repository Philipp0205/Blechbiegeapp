part of 'current_path_bloc/current_path_base_bloc.dart';

abstract class CurrentPathEvent extends Equatable {
  const CurrentPathEvent();

  @override
  List<Object> get props => [];
}

class CurrentPathPanStarted extends CurrentPathEvent {
  final Mode mode;
  final Offset firstDrawnOffset;
  const CurrentPathPanStarted({required this.firstDrawnOffset, required this.mode});
}

class CurrentPathPanUpdated extends CurrentPathEvent {
  final List<Segment> currentSegment;
  final Offset offset;
  final Mode mode;

  const CurrentPathPanUpdated(
      {required this.currentSegment, required this.offset, required this.mode});
}

class CurrentPathPanEnded extends CurrentPathEvent {
  final List<Segment> currentSegment;
  final Mode mode;

  CurrentPathPanEnded({required this.currentSegment, required this.mode});

}

class CurrentPathPanDowned extends CurrentPathEvent {
  final DragDownDetails details;
  final Mode mode;

  CurrentPathPanDowned({required this.details, required this.mode});
}

class CurrentSegmentDeleted extends CurrentPathEvent {
  CurrentSegmentDeleted();
}

class CurrentPathSelectionModePressed extends CurrentPathEvent {
  final Mode mode;

  const CurrentPathSelectionModePressed({required this.mode});
}

part of 'all_segments_bloc.dart';

@immutable
abstract class AllPathsEvent extends Equatable {
  const AllPathsEvent();

  @override
  List<Object> get props => [];
}

class AllSegmentsSegmentAdded extends AllPathsEvent {
  final Segment segment;
  const AllSegmentsSegmentAdded({required this.segment});
}

class AllSegmentsSegmentDeleted extends AllPathsEvent {
  final Segment segment;
  const AllSegmentsSegmentDeleted({required this.segment});
}

class AllSegmentsDeleted extends AllPathsEvent {
  const AllSegmentsDeleted();
}
class AllSegmentsUpdated extends AllPathsEvent {
  const AllSegmentsUpdated();
}

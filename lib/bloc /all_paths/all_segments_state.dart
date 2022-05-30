part of 'all_segments_bloc.dart';

@immutable
abstract class AllPathsState {
  final List<Segment> segments;

  const AllPathsState({required this.segments});
}

class AllSegmentsInitial extends AllPathsState {
  final List<Segment> segments;

  const AllSegmentsInitial({required this.segments}) : super(segments: segments);
}

class SegmentUpdate extends AllPathsState {
  final List<Segment> segments;
  const SegmentUpdate({required this.segments}) : super(segments: segments);
}

class SegmentDelete extends AllPathsState {
  final List<Segment> segments;
  const SegmentDelete({required this.segments}) : super(segments: segments);
}




part of 'all_paths_bloc.dart';

@immutable
abstract class AllPathsState {
  final List<Segment> segments;

  const AllPathsState({required this.segments});
}

class AllPathsInitial extends AllPathsState {
  final List<Segment> segments;

  const AllPathsInitial({required this.segments}) : super(segments: segments);
}


class SegmentsUpdate extends AllPathsState {
  final List<Segment> segments;
  const SegmentsUpdate({required this.segments}) : super(segments: segments);
}




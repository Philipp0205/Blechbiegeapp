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


class AllPathsSegmentsUpdated extends AllPathsState {
  final List<Segment> segments;
  const AllPathsSegmentsUpdated({required this.segments}) : super(segments: segments);
}




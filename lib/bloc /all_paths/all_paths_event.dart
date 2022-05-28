part of 'all_paths_bloc.dart';

@immutable
abstract class AllPathsEvent extends Equatable {
  const AllPathsEvent();

  @override
  List<Object> get props => [];
}

class SegmentAdded extends AllPathsEvent {
  final Segment segment;
  const SegmentAdded({required this.segment});
}

class AllPathsDeleted extends AllPathsEvent {
  const AllPathsDeleted();
}

class AllPathsUpdated extends AllPathsEvent {
  const AllPathsUpdated();
}

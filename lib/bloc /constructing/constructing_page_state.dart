part of 'constructing_page_bloc.dart';

abstract class ConstructingPageState extends Equatable {
  final List<Segment2> segment;

  const ConstructingPageState({required this.segment});

  @override
  List<Object> get props => [segment];
}

class ConstructingPageInitial extends ConstructingPageState {
  final List<Segment2> segment;

  const ConstructingPageInitial({required this.segment})
      : super(segment: segment);
}

class ConstructingPageCreate extends ConstructingPageState {
  final List<Segment2> segment;

  const ConstructingPageCreate({required this.segment})
      : super(segment: segment);
}

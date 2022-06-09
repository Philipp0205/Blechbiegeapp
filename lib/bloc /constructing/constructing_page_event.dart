part of 'constructing_page_bloc.dart';

abstract class ConstructingPageEvent extends Equatable {
  const ConstructingPageEvent();

  @override
  List<Object?> get props => [];
}

class ConstructingPageCreated extends ConstructingPageEvent {
  final List<Segment2> segment;

  const ConstructingPageCreated({required this.segment});
}

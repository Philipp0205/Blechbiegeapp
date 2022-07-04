part of 'shapes_page_bloc.dart';

abstract class ShapesPageEvent extends Equatable {
  const ShapesPageEvent();

  @override
  List<Object> get props => [];
}


/// A new [Shape] gets added to the list
class ShapeAdded extends ShapesPageEvent {
  final Shape shape;
  ShapeAdded({required this.shape});
}
/// A [Shape] gets removed from the list
class ShapeDeleted extends ShapesPageEvent {
  final Shape shape;
  ShapeDeleted({required this.shape});
}


/// A [Shape] gets edited
class ShapeEdited extends ShapesPageEvent {
  final Shape shape;
  ShapeEdited({required this.shape});
}
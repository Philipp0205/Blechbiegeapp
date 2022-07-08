part of 'shapes_page_bloc.dart';

abstract class ShapesPageEvent extends Equatable {
  const ShapesPageEvent();

  @override
  List<Object> get props => [];
}


/// Event which is called when the shape page is created.
class ShapesPageCreated extends ShapesPageEvent {
  final List<Shape> shapes;

  ShapesPageCreated({required this.shapes});
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

class ShapesSavedToDisk extends ShapesPageEvent {
  final List<Shape> shapes;
  ShapesSavedToDisk({required this.shapes});
}
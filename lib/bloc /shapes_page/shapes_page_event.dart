part of 'shapes_page_bloc.dart';

abstract class ShapesPageEvent extends Equatable {
  const ShapesPageEvent();

  @override
  List<Object> get props => [];
}


/// Event which is called when the shape page is created.
class ShapesPageCreated extends ShapesPageEvent {
  final List<Tool> shapes;

  ShapesPageCreated({required this.shapes});
}

/// A new [Tool] gets added to the list
class ShapeAdded extends ShapesPageEvent {
  final Tool shape;
  ShapeAdded({required this.shape});
}
/// A [Tool] gets removed from the list
class ShapeDeleted extends ShapesPageEvent {
  final Tool shape;
  ShapeDeleted({required this.shape});
}

/// A [Tool] gets edited
class ShapeEdited extends ShapesPageEvent {
  final Tool shape;
  ShapeEdited({required this.shape});
}

class ShapesSavedToDisk extends ShapesPageEvent {
  final List<Tool> shapes;
  ShapesSavedToDisk({required this.shapes});
}
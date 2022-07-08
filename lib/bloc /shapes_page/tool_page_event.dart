part of 'tool_page_bloc.dart';

abstract class ToolPageEvent extends Equatable {
  const ToolPageEvent();

  @override
  List<Object> get props => [];
}


/// Event which is called when the shape page is created.
class ShapesPageCreated extends ToolPageEvent {
  final List<Tool> shapes;

  ShapesPageCreated({required this.shapes});
}

/// A new [Tool] gets added to the list
class ShapeAdded extends ToolPageEvent {
  final Tool shape;
  ShapeAdded({required this.shape});
}
/// A [Tool] gets removed from the list
class ShapeDeleted extends ToolPageEvent {
  final Tool shape;
  ShapeDeleted({required this.shape});
}

/// A [Tool] gets edited
class ShapeEdited extends ToolPageEvent {
  final Tool shape;
  ShapeEdited({required this.shape});
}

class ShapesSavedToDisk extends ToolPageEvent {
  final List<Tool> shapes;
  ShapesSavedToDisk({required this.shapes});
}
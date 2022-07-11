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
class ToolAdded extends ToolPageEvent {
  final Tool tool;

  ToolAdded({required this.tool});
}

/// A [Tool] gets removed from the list
class ShapeDeleted extends ToolPageEvent {
  final List<bool> selectedList;

  ShapeDeleted({required this.selectedList});
}

/// A [Tool] gets edited.
/// The [Tool] gets replaced by the new [Tool] in the list.
class ToolEdited extends ToolPageEvent {
  final Tool tool;

  ToolEdited({required this.tool});
}

class ShapesSavedToDisk extends ToolPageEvent {
  final List<Tool> shapes;

  ShapesSavedToDisk({required this.shapes});
}

/// Event that is triggered when [isSelectionMode] is changed.
class SelectionModeChanged extends ToolPageEvent {
  final bool isSelectionMode;

  SelectionModeChanged({required this.isSelectionMode});
}

/// Event triggered when [selectedList] is changed.
/// This event is only triggered when [isSelectionMode] is true.
/// Otherwise it is ignored.
/// This event is also triggered when the [selectedList] is changed by the user.
class SelectedListChanged extends ToolPageEvent {
  final int index;
  final bool value;

  SelectedListChanged({required this.index, required this.value});
}

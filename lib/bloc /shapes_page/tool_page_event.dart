part of 'tool_page_bloc.dart';

abstract class ToolPageEvent extends Equatable {
  const ToolPageEvent();

  @override
  List<Object> get props => [];
}

/// Event which is called when the shape page is created.
class ToolPageCreated extends ToolPageEvent {

  ToolPageCreated();
}

/// A new [Tool] gets added to the list
class ToolAdded extends ToolPageEvent {
  final Tool tool;

  ToolAdded({required this.tool});
}

/// A [Tool] gets removed from the list
class ToolDeleted extends ToolPageEvent {
  final List<Tool> tools;

  ToolDeleted({required this.tools});
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
class SelectedToolsChanged extends ToolPageEvent {
  Tool tool;

  SelectedToolsChanged({required this.tool});
}

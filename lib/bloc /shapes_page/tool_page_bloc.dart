import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../model/simulation/tool.dart';
import '../../persistence/database_provider.dart';
import '../../persistence/repositories/tool_repository.dart';

part 'tool_page_event.dart';

part 'tool_page_state.dart';

class ToolPageBloc extends Bloc<ToolPageEvent, ToolPageState> {
  DatabaseProvider _service = new DatabaseProvider();
  late Box box = Hive.box('shapes');

  ToolPageBloc(this._toolRepository)
      : super(ShapesPageInitial(
            tools: [], isSelectionMode: false, selectedTools: <Tool, bool>{})) {
    on<ShapesPageCreated>(_shapesPageCreated);
    on<ToolAdded>(_addTool);
    on<ToolDeleted>(_deleteTool);
    on<ToolEdited>(_editTool);
    on<SelectionModeChanged>(_toggleSelectionMode);
    on<SelectedToolsChanged>(_changeSelectedList);
  }

  final ToolRepository _toolRepository;

  /// Add new tool to to the database and update the state with the new tool.
  /// The new tool is added to the end of the list.
  /// The new tool is also added to the [selectedList].
  Future<void> _addTool(ToolAdded event, Emitter<ToolPageState> emit) async {
    _toolRepository.addTool(event.tool);
    List<Tool> tools = await _toolRepository.getTools();

    Box box = await _service.createBox('shapes');
    box.add(event.tool);

    emit(state.copyWith(tools: tools));
  }

  /// Delete the tool from the database.
  Future<void> _deleteTool(
      ToolDeleted event, Emitter<ToolPageState> emit) async {
    Map<Tool, bool> selectedTools = event.selectedTools;

    selectedTools.forEach((key, value) {
      if (value) {
        _toolRepository.deleteTool(key);
        selectedTools.remove(key);
        box.delete(key);
      }
    });

    List<Tool> tools = await _toolRepository.getTools();

    emit(state.copyWith(tools: []));
    emit(state.copyWith(tools: tools));
  }

  /// Edit the tool with the given [index] and [tool].
  /// The [index] is the index of the tool in the list of tools.
  /// If multiple tools are selected, the first [tool] is updated.
  Future<void> _editTool(ToolEdited event, Emitter<ToolPageState> emit) async {
    _toolRepository.updateTool(event.tool);
    List<Tool> tools = await _toolRepository.getTools();
    emit(state.copyWith(tools: tools));
  }

  /// Called initially one time when the shapes page is created.
  /// Shapes are loaded from the repository and saved in the state.
  FutureOr<void> _shapesPageCreated(
      ShapesPageCreated event, Emitter<ToolPageState> emit) async {
    List<Tool> tools = await _toolRepository.getTools();

    emit(state.copyWith(tools: tools, isSelectionMode: false));
  }

  /// Called when the selection mode is changed.
  /// The selection mode is changed depending on the current mode.
  void _toggleSelectionMode(
      SelectionModeChanged event, Emitter<ToolPageState> emit) {
    Map<Tool, bool> selectedTools = state.selectedTools;

    // Generate initial selected tools list where all are unselected.
    state.tools.forEach((tool) {
      selectedTools.addEntries([new MapEntry(tool, false)]);
    });

    emit(state.copyWith(
        isSelectionMode: event.isSelectionMode, selectedTools: selectedTools));
  }

  /// Called when the selected list is changed.
  /// The selected list is changed when in selection mode.
  void _changeSelectedList(
      SelectedToolsChanged event, Emitter<ToolPageState> emit) {
    Map<Tool, bool> selectedTools = state.selectedTools;

    if (state.selectedTools.entries
        .where((entry) => entry.key == event.tool)
        .first
        .value) {
      print('unselect tool');
      selectedTools.update(event.tool, (value) => false);
    } else {
      print('selected tool');
      int index = selectedTools.keys.toList().indexOf(event.tool);
      selectedTools.update(event.tool, (value) => true);
    }
  }
}

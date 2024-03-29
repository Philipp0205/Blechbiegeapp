import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:open_bsp/services/json_serializer.dart';

import '../../model/simulation/tool.dart';
import '../../persistence/database_provider.dart';
import '../../persistence/repositories/tool_repository.dart';

part 'tool_page_event.dart';

part 'tool_page_state.dart';

class ToolPageBloc extends Bloc<ToolPageEvent, ToolPageState> {
  late Box box = Hive.box('shapes');

  ToolPageBloc(this._toolRepository)
      : super(ShapesPageInitial(
            tools: [], isSelectionMode: false, selectedTools: <Tool, bool>{})) {
    on<ToolPageCreated>(_shapesPageInit);
    on<ToolAdded>(_addTool);
    on<ToolDeleted>(_deleteTools);
    on<ToolEdited>(_editTool);
    on<SelectionModeChanged>(_toggleSelectionMode);
    on<SelectedToolsChanged>(_changeSelectedList);
    on<ToolDataBackedUp>(_loadBackedUpData);
  }

  final ToolRepository _toolRepository;

  /// Add new tool to to the database and update the state with the new tool.
  /// The new tool is added to the end of the list.
  /// The new tool is also added to the [selectedList].
  Future<void> _addTool(ToolAdded event, Emitter<ToolPageState> emit) async {
    _toolRepository.addTool(event.tool);

    List<Tool> tools = await _toolRepository.getTools();

    emit(state.copyWith(tools: []));
    emit(state.copyWith(tools: tools));
  }

  /// Delete the tools from the database.
  Future<void> _deleteTools(
      ToolDeleted event, Emitter<ToolPageState> emit) async {
    event.tools.forEach((tool) {
      _toolRepository.deleteTool(tool);
    });

    List<Tool> tools = await _toolRepository.getTools();

    emit(state.copyWith(tools: tools));
  }

  /// Edit the tool with the given [index] and [tool].
  /// The [index] is the index of the tool in the list of tools.
  /// If multiple tools are selected, the first [tool] is updated.
  Future<void> _editTool(ToolEdited event, Emitter<ToolPageState> emit) async {
    Tool selectedTool = state.tools.firstWhere((tool) => tool.isSelected);
    _toolRepository.updateTool(selectedTool, event.tool);
    List<Tool> tools = await _toolRepository.getTools();
    emit(state.copyWith(tools: tools));
  }

  /// Called initially one time when the shapes page is created.
  /// Shapes are loaded from the repository and saved in the state.
  FutureOr<void> _shapesPageInit(
      ToolPageCreated event, Emitter<ToolPageState> emit) async {
    Map<Tool, bool> selectedTools = <Tool, bool>{};
    // Generate initial selected tools list where all are unselected.
    List<Tool> tools = await _toolRepository.getTools();

    emit(state.copyWith(tools: tools, isSelectionMode: false));
  }

  /// Called when the selection mode is changed.
  /// The selection mode is changed depending on the current mode.
  void _toggleSelectionMode(
      SelectionModeChanged event, Emitter<ToolPageState> emit) {
    emit(state.copyWith(isSelectionMode: event.isSelectionMode));
  }

  /// Called when the selected list is changed.
  /// The selected list is changed when in selection mode.
  void _changeSelectedList(
      SelectedToolsChanged event, Emitter<ToolPageState> emit) {
    Tool tool = event.tool;

    Tool newTool = tool.isSelected
        ? tool.copyWith(isSelected: false)
        : tool.copyWith(isSelected: true);

    _toolRepository.updateTool(tool, newTool);

    List<Tool> beams = state.tools;
    beams[beams.indexOf(tool)] = newTool;

    emit(state.copyWith(tools: []));
    emit(state.copyWith(tools: beams));
  }

  /// Backup the data to a json file.
  /// The file is saved in the OS directory.
  /// The file name is backup_tools.json.
  void _loadBackedUpData(ToolDataBackedUp event, Emitter<ToolPageState> emit) async {
    _toolRepository.loadBackup();
  }
}

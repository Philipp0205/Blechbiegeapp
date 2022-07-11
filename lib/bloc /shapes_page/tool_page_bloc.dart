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
            tools: [], isSelectionMode: false, selectedList: [])) {
    on<ShapesPageCreated>(_shapesPageCreated);
    on<ToolAdded>(_addTool);
    on<ShapeDeleted>(_deleteTool);
    on<ToolEdited>(_editTool);
    on<SelectionModeChanged>(_toggleSelectionMode);
    on<SelectedListChanged>(_changeSelectedList);
  }

  final ToolRepository _toolRepository;

  /// Add new tool to to the database and update the state with the new tool.
  /// The new tool is added to the end of the list.
  /// The new tool is also added to the [selectedList].
  Future<void> _addTool(ToolAdded event, Emitter<ToolPageState> emit) async {
    _toolRepository.addTool(event.tool);
    List<Tool> toolsFromRepo = await _toolRepository.getTools();

    print('add shape shapes page bloc');
    List<Tool> shapes = state.tools;
    shapes.add(event.tool);

    Box box = await _service.createBox('shapes');
    print('${box.length} shapes are saved');
    box.add(event.tool);

    emit(state.copyWith(tools: toolsFromRepo));
  }

  /// Delete the tool from the database.
  Future<void> _deleteTool(
      ShapeDeleted event, Emitter<ToolPageState> emit) async {
    List<bool> selectedList = event.selectedList;

    selectedList.forEach((element) {
      if (element == true) {
        int index = selectedList.indexOf(element);
        print('delete index: $index');
        _toolRepository.deleteTool(index);
      }
    });

    List<Tool> tools = await _toolRepository.getTools();
    print('godtools: ${tools.length}');

    emit(state.copyWith(tools: []));
    emit(state.copyWith(tools: tools));
  }

  /// Edit the tool with the given [index] and [tool].
  /// The [index] is the index of the tool in the list of tools.
  /// If multiple tools are selected, the first [tool] is updated.
  Future<void> _editTool(ToolEdited event, Emitter<ToolPageState> emit) async {
    List<bool> selectedList = state.selectedList;

    int index = selectedList
        .indexOf(selectedList.firstWhere((element) => element == true));

    _toolRepository.updateTool(index, event.tool);
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
    print('selectionModeChanged ${event.isSelectionMode}');
    List<bool> selectedList =
        List<bool>.generate(state.tools.length, (_) => false);

    emit(state.copyWith(
        isSelectionMode: event.isSelectionMode, selectedList: selectedList));
  }

  /// Called when the selected list is changed.
  /// The selected list is changed when in selection mode.
  void _changeSelectedList(
      SelectedListChanged event, Emitter<ToolPageState> emit) {
    List<bool> selectedList = state.selectedList;
    selectedList[event.index] = event.value;

    emit(state.copyWith(selectedList: []));
    emit(state.copyWith(selectedList: selectedList));
  }
}

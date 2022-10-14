import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_bsp/bloc%20/shapes_page/tool_page_bloc.dart';
import 'package:open_bsp/model/simulation/enums/position_enum.dart';

import '../../model/OffsetAdapter.dart';
import '../../model/line.dart';
import '../../model/segment_widget/segment.dart';
import '../../model/simulation/tool.dart';
import '../../model/simulation/enums/tool_category_enum.dart';
import '../../model/simulation/tool_type.dart';
import '../../model/simulation/tool_type2.dart';
import '../../persistence/repositories/tool_repository.dart';
import '../../services/geometric_calculations_service.dart';

part 'configuration_page_event.dart';

part 'configuration_page_state.dart';

class ConfigPageBloc extends Bloc<ConfigurationPageEvent, ConfigPageState> {
  final GeometricCalculationsService _calculationService =
      new GeometricCalculationsService();

  ConfigPageBloc(this._toolRepository)
      : super(ConstructingPageInitial(
            segment: [],
            lines: [],
            tools: [],
            markAdapterLineMode: false,
            showCoordinates: false,
            showEdgeLengths: false,
            showAngles: false,
            s: 5,
            r: 0,
            toolTypes: [])) {
    on<ConfigPageCreated>(_initializePage);
    on<ConfigCoordinatesShown>(_showCoordinates);
    on<ConfigEdgeLengthsShown>(_showEdgeLengths);
    on<ConfigAnglesShown>(_showAngles);
    on<ConfigCheckboxChanged>(_showDataDependingOnCheckbox);
    on<ConfigSChanged>(_changeThicknes);
    on<ConfigRChanged>(_changeRadius);
    on<ConfigToggleMarkAdapterLineMode>(_toggleAdapterMode);
    on<ConfigMarkAdapterLine>(_markAdapterLine);
    on<ConfigRegisterAdapters>(_registerAdapters);
  }

  final ToolRepository _toolRepository;

  /// When no segment exists an initial segment gets created.
  Future<void> _initializePage(
      ConfigPageCreated event, Emitter<ConfigPageState> emit) async {
    _createToolTypes(emit);

    emit(state.copyWith(lines: event.lines));
  }

  /// Registers all adapters needed to save shape objects in the database.
  void _registerAdapters(
      ConfigRegisterAdapters event, Emitter<ConfigPageState> emit) async {
    _toolRepository.initRepo();
  }

  /// Decides depending on the [CheckBoxEnum] what should be shown.
  void _showDataDependingOnCheckbox(
      ConfigCheckboxChanged event, Emitter<ConfigPageState> emit) {
    switch (event.checkBox) {
      case CheckBoxEnum.coordinates:
        emit(state.copyWith(showCoordinates: event.checkBoxValue));
        break;
      case CheckBoxEnum.lengths:
        emit(state.copyWith(showEdgeLengths: event.checkBoxValue));
        break;
      case CheckBoxEnum.angles:
        emit(state.copyWith(showAngles: event.checkBoxValue));
        break;
    }
  }

  /// Handles event for showing the coordinates of each line on the canvas.
  void _showCoordinates(
      ConfigCoordinatesShown event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(showCoordinates: event.showCoordinates));
  }

  /// Handles event for showing the lengths of each line on the canvas.
  void _showEdgeLengths(
      ConfigEdgeLengthsShown event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(showEdgeLengths: event.showEdgeLengths));
  }

  /// Handles the event for showing the inner angles between liens on the canvas.
  void _showAngles(ConfigAnglesShown event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(showAngles: event.showAngles));
  }

  /// Handles event that changes the thickness of the line.
  void _changeThicknes(ConfigSChanged event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(s: event.s));
  }

  /// Handles the event that changes the radius of the curves that are drawn.j
  void _changeRadius(ConfigRChanged event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(r: event.r));
  }

  /// Toggles the adapter mode of the configuration page.
  /// When the mode is enables the suer can chose one line that is marked as
  /// adapter for that tool and then other tools can be attached to that tool.
  void _toggleAdapterMode(
      ConfigToggleMarkAdapterLineMode event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(markAdapterLineMode: event.adapterLineMode));
  }

  void _markAdapterLine(
      ConfigMarkAdapterLine event, Emitter<ConfigPageState> emit) {
    if (state.markAdapterLineMode == false) return;

    List<Line> lines = state.lines;
    List<Tool> tools = state.tools;

    List<Offset> middlePoints = lines
        .map((line) => _calculationService.getMiddle(line.start, line.end))
        .toList();

    List<Offset> nearestMiddlePoint =
        _calculationService.getNNearestOffsets(event.offset, middlePoints, 1);

    int index = middlePoints.indexOf(nearestMiddlePoint.first);

    Line selectedLine = lines[index];

    Line newLine = selectedLine.isSelected
        ? selectedLine.copyWith(isSelected: false)
        : selectedLine.copyWith(isSelected: true);

    lines
      ..insert(lines.indexOf(selectedLine), newLine)
      ..remove(selectedLine);

    emit(state.copyWith(lines: []));
    emit(state.copyWith(lines: lines));
  }

  /// Create all [ToolType2]s.
  void _createToolTypes(Emitter<ConfigPageState> emit) {
    ToolType2 lowerBeam = new ToolType2(
        name: 'Unterwange',
        category: ToolCategoryEnum.BEAM,
        type: ToolType.lowerBeam,
        position: PositionEnum.BOTTOM);
    ToolType2 upperBeam = new ToolType2(
        name: 'Oberwange',
        category: ToolCategoryEnum.BEAM,
        type: ToolType.upperBeam,
        position: PositionEnum.TOP);
    ToolType2 bendingBeam = new ToolType2(
        name: 'Biegewange',
        category: ToolCategoryEnum.BEAM,
        type: ToolType.bendingBeam,
        position: PositionEnum.LEFT);
    ToolType2 lowerTrack = new ToolType2(
        name: 'Untere Schiene',
        category: ToolCategoryEnum.TRACK,
        type: ToolType.lowerTrack,
        position: PositionEnum.BOTTOM);
    ToolType2 upperTrack = new ToolType2(
        name: 'Obere Schiene',
        type: ToolType.upperTrack,
        category: ToolCategoryEnum.TRACK,
        position: PositionEnum.TOP);
    ToolType2 bendingTrack = new ToolType2(
        name: 'Biegeschiene',
        category: ToolCategoryEnum.TRACK,
        type: ToolType.bendingTrack,
        position: PositionEnum.LEFT);
    ToolType2 plateProfile = new ToolType2(
        name: 'Blech',
        category: ToolCategoryEnum.PLATE_PROFILE,
        type: ToolType.plateProfile,
        position: PositionEnum.RIGHT);

    emit(state.copyWith(toolTypes: []));
    emit(state.copyWith(toolTypes: [
      lowerBeam,
      upperBeam,
      bendingBeam,
      lowerTrack,
      upperTrack,
      bendingTrack,
      plateProfile
    ]));
  }
}

enum CheckBoxEnum { coordinates, lengths, angles }

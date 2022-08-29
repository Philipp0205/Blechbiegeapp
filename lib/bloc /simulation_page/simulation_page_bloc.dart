import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/pages/simulation_page/ticker.dart';
import 'package:open_bsp/model/simulation/tool_type.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';

import 'package:collection/collection.dart';

import '../../model/line.dart';
import '../../model/simulation/tool.dart';
import '../../model/simulation/enums/tool_category_enum.dart';

part 'simulation_page_event.dart';

part 'simulation_page_state.dart';

/// Business logic for the [SimulationPage].
class SimulationPageBloc
    extends Bloc<SimulationPageEvent, SimulationPageState> {
  SimulationPageBloc({required Ticker ticker})
      : _ticker = ticker,
        super(SimulationPageInitial(
            tools: [],
            lines: [],
            selectedBeams: [],
            selectedTracks: [],
            selectedPlates: [],
            rotationAngle: 0,
            debugOffsets: [],
            inCollision: false,
            isSimulationRunning: false,
            duration: 0)) {
    on<SimulationPageCreated>(_setInitialLines);
    on<SimulationToolsChanged>(_setTools);
    on<SimulationToolRotate>(_rotateTool);
    on<SimulationSelectedPlateLineChanged>(_nextLineOfPlate);
    on<SimulationToolMirrored>(_mirrorTool);
    on<SimulationCollisionDetected>(_detectCollision);
    on<SimulationStarted>(_startSimulation);
    on<SimulationStopped>(_stopSimulation);
    on<SimulationTicked>(_onTicked);
  }

  GeometricCalculationsService _calculationsService =
      new GeometricCalculationsService();

  List<Offset> collisionOffsets = [];

  final Ticker _ticker;
  Timer? timer;

  StreamSubscription<int>? _tickerSubscription;

  /// Set the initial lines of the simulation.
  void _setInitialLines(
      SimulationPageCreated event, Emitter<SimulationPageState> emit) {
    emit(state.copyWith(lines: event.lines));
  }

  /// Set the tools of the simulation.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  void _setTools(
      SimulationToolsChanged event, Emitter<SimulationPageState> emit) {
    if (event.tools.isEmpty) return;

    List<Tool> selectedBeams =
        _getToolsByCategory(event.tools, ToolCategoryEnum.BEAM);
    List<Tool> selectedTracks =
        _getToolsByCategory(event.tools, ToolCategoryEnum.TRACK);
    List<Tool> selectedPlates =
        _getToolsByCategory(event.tools, ToolCategoryEnum.PLATE_PROFILE);

    _placeLowerBeam(selectedBeams, event, emit);
    _placeLowerTrackOnLowerBeam(event, selectedTracks, emit);

    _placePlateOnLowerTrack(event, emit, selectedPlates);

    _placeUpperTrackOnPlate2(event, emit, selectedTracks);
    _placeUpperBeamOnUpperTack2(
        event, emit, selectedTracks, selectedBeams);

    // emit(state
    //     .copyWith(selectedBeams: [], selectedTracks: [], selectedPlates: []));
    // emit(state.copyWith(
    //   selectedBeams: selectedBeams,
    //   selectedTracks: selectedTracks,
    //   selectedPlates: selectedPlates,
    // ));
  }

  /// Places the lower beam in the simulation.
  /// This method is called when the [SimulationBeamsChanged] event is emitted.
  void _placeLowerBeam(List<Tool> selectedBeams, SimulationToolsChanged event,
      Emitter<SimulationPageState> emit) {
    Tool lowerBeam = selectedBeams
        .firstWhere((beam) => beam.type.type == ToolType.lowerBeam);

    emit(state.copyWith(
      selectedBeams: [],
    ));
    emit(state.copyWith(
      selectedBeams: [lowerBeam],
    ));
  }

  /// Place a track on a beam.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  /// The track is placed on the beam at the same position as the beam.
  Tool _placeTrackOnBeam(Tool track, Tool beam) {
    print('placeTrackOnBeam');

    Line beamAdapterLine = beam.lines.where((line) => line.isSelected).first;
    Line trackAdapterLine = track.lines.where((line) => line.isSelected).first;

    Offset beamOffset;
    Offset trackOffset;

    beamAdapterLine.start.dy > beamAdapterLine.end.dy
        ? beamOffset = beamAdapterLine.start
        : beamOffset = beamAdapterLine.end;

    trackAdapterLine.start.dy > trackAdapterLine.end.dy
        ? trackOffset = trackAdapterLine.start
        : trackOffset = trackAdapterLine.end;

    Offset newOffset = beamOffset - trackOffset;

    Tool newTool = _moveTool(track, newOffset, true);

    return newTool;
  }

  /// Place the plate on the track with the next edge.
  void _nextLineOfPlate(SimulationSelectedPlateLineChanged event,
      Emitter<SimulationPageState> emit) {
    Tool plate = state.selectedPlates.first;

    _selectNextLineOfPlateAndPlace(plate, emit);
  }

  /// TODO
  void _selectNextLineOfPlateAndPlace(
      Tool plate, Emitter<SimulationPageState> emit) {
    print('selectNextLineOfPlateAndPlace');
    List<Line> lines = plate.lines;
    Line? currentlyPlacedLine =
        lines.firstWhereOrNull((line) => line.isSelected) ?? lines.first;

    int index = plate.lines.indexOf(currentlyPlacedLine);
    lines[index].isSelected = false;

    index < lines.length - 1
        ? lines[index + 1].isSelected = true
        : lines.first.isSelected = true;

    plate = plate.copyWith(lines: lines);
    plate = _rotateUntilSelectedLineHasAngle(plate, [0, 360], 1);

    Tool lowerTrack = state.selectedTracks
        .firstWhere((tool) => tool.type.type == ToolType.lowerTrack);

    Tool placedPlate = _placePlateOnTrack(emit, plate, lowerTrack);

    emit(state.copyWith(selectedPlates: []));
    emit(state.copyWith(selectedPlates: [placedPlate]));
  }

  /// Place plate on lower track.
  Tool _placePlateOnTrack(
      Emitter<SimulationPageState> emit, Tool plate, Tool lowerTrack) {
    List<Offset> trackOffsets =
        lowerTrack.lines.map((line) => line.start).toList() +
            lowerTrack.lines.map((line) => line.end).toList();

    Line? selectedLine =
        plate.lines.firstWhereOrNull((line) => line.isSelected) ??
            plate.lines.first;

    List<Offset> lowestTrackXOffsets =
        _calculationsService.getLowestX(trackOffsets);

    Offset trackOffset =
        _calculationsService.getLowestY(lowestTrackXOffsets).first;

    Offset plateOffset = _calculationsService
        .getLowestX([selectedLine.start, selectedLine.end]).first;

    plateOffset = new Offset(plateOffset.dx, plateOffset.dy + (plate.s / 2));

    Offset moveOffset = plateOffset - trackOffset;

    Tool movedTool = _moveTool(plate, moveOffset, false);
    print('movedTool: ${movedTool.lines.first.start}');
    return movedTool;
  }

  /// Move a tool.
  /// The tool is moved by the given [offset].
  Tool _moveTool(Tool tool, Offset offset, bool positiveDirection) {
    List<Line> lines = tool.lines;
    List<Line> newLines = [];
    lines.forEach((line) {
      if (positiveDirection) {
        newLines.add(
            line.copyWith(start: line.start + offset, end: line.end + offset));
      } else {
        newLines.add(
            line.copyWith(start: line.start - offset, end: line.end - offset));
      }
    });

    return tool.copyWith(lines: newLines);
  }

  List<Tool> _getToolsByCategory(List<Tool> tools, ToolCategoryEnum category) {
    return tools.where((tool) => tool.type.category == category).toList();
  }

  Tool? _getToolByType(List<Tool> tools, ToolType type) {
    return tools.firstWhereOrNull((tool) => tool.type.type == type);
  }

  /// Place upper track on plate with distance s.
  /// The upper track is aligned with the plate.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  /// The upper track is placed on the plate at the same position as the plate.
  Tool _placeUpperTrackOnPlate(Tool upperTrack, Tool plate) {
    double s = plate.s;

    Line selectedLine =
        plate.lines.firstWhereOrNull((line) => line.isSelected) ??
            plate.lines.first;

    List<Offset> trackOffsets =
        upperTrack.lines.map((line) => line.start).toList() +
            plate.lines.map((line) => line.end).toList();

    Offset plateOffset = _calculationsService
        .getLowestX([selectedLine.start, selectedLine.end]).first;

    List<Offset> lowestXTrackOffset =
        _calculationsService.getLowestX(trackOffsets);

    Offset trackOffset =
        _calculationsService.getLowestY(lowestXTrackOffset).first;

    Offset newOffset = trackOffset - plateOffset + new Offset(s - 7, s - 3);

    Tool movedTool = _moveTool(upperTrack, newOffset, false);
    return movedTool;
  }

  /// Rotate a [tool] clockwise around [center] by [degrees].
  Tool _rotateTool2(Tool tool, Offset center, double degrees) {
    return tool.copyWith(
        lines: _calculationsService.rotateLines(tool.lines, center, degrees));
  }

  void _rotateTool(
      SimulationToolRotate event, Emitter<SimulationPageState> emit) {
    Tool rotatedTool = _rotTool(event.tool, event.degrees);

    emit(state.copyWith(selectedPlates: []));
    emit(state.copyWith(selectedPlates: [rotatedTool], collisionOffsets: []));
  }

  // TODO
  Tool _rotTool(Tool tool, double degrees) {
    Line selectedLine = tool.lines.firstWhere((line) => line.isSelected);
    Offset center =
        _calculationsService.getMiddle(selectedLine.start, selectedLine.end);
    List<Line> rotatedLines =
        _calculationsService.rotateLines(tool.lines, center, degrees);

    return tool.copyWith(lines: rotatedLines);
  }

  /// Rotate the given [tool] around the center of the selected line of that
  /// tool until a the given [angle] is reached.
  /// The [stepSize] sets how much the tool is rotated each time.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  Tool _rotateUntilSelectedLineHasAngle(
      Tool tool, List<double> angles, double stepSize) {
    Line selectedLine = tool.lines.firstWhere((line) => line.isSelected);
    Offset center =
        _calculationsService.getMiddle(selectedLine.start, selectedLine.end);

    int steps = (360 / stepSize).floor();

    for (int i = 0; i < steps; i++) {
      tool = _rotateTool2(tool, center, stepSize);
      Line selectedLine = tool.lines.firstWhere((line) => line.isSelected);
      double currentAngle =
          _calculationsService.getAngle(selectedLine.start, selectedLine.end);
      if (angles.contains(currentAngle.round())) {
        return tool;
      }
    }

    return tool;
  }

  /// Mirror a [tool].
  void _mirrorTool(
      SimulationToolMirrored event, Emitter<SimulationPageState> emit) {
    print('_mirrorTool');

    Line selectedLine = event.tool.lines.firstWhere((line) => line.isSelected);

    Offset middle =
        _calculationsService.getMiddle(selectedLine.start, selectedLine.end);

    List<Line> mirroredLines =
        _calculationsService.mirrorLines(event.tool.lines, middle.dx);

    Tool mirroredTool = event.tool.copyWith(lines: mirroredLines);

    Tool lowerTrack = state.selectedTracks
        .firstWhere((tool) => tool.type.type == ToolType.lowerTrack);

    Tool placedPlate = _placePlateOnTrack(emit, mirroredTool, lowerTrack);

    List<Tool> selectedPlates = state.selectedPlates;
    selectedPlates
      ..removeLast()
      ..add(placedPlate);

    emit(state.copyWith(selectedPlates: []));
    emit(state.copyWith(selectedPlates: [mirroredTool]));
  }

  void _detectCollision(
      SimulationCollisionDetected event, Emitter<SimulationPageState> emit) {
    bool result = false;

    collisionOffsets.clear();
    for (int i = 0; i < event.plateOffsets.length; i++) {
      if (event.collisionOffsets.contains(event.plateOffsets[i])) {
        collisionOffsets.add(event.plateOffsets[i]);
      }
    }

    collisionOffsets.isNotEmpty ? result = true : result = false;

    emit(state.copyWith(
        inCollision: result, collisionOffsets: collisionOffsets));
  }

  /// Places the lower track on the on the lower beam.
  /// The lower track is aligned with the lower beam.
  /// The lower track is placed on the lower beam at the same position as the
  /// lower beam.
  ///
  /// When the lower beam does not exist nothing happens.
  ///
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  void _placeLowerTrackOnLowerBeam(SimulationToolsChanged event,
      List<Tool> selectedTracks, Emitter<SimulationPageState> emit) {
    Tool? lowerBeam = _getToolByType(event.tools, ToolType.lowerBeam);
    Tool? lowerTrack = _getToolByType(event.tools, ToolType.lowerTrack);

    if (lowerBeam == null || lowerTrack == null) {
      return;
    }

    Tool newTrack = _placeTrackOnBeam(lowerTrack, lowerBeam);

    int index = selectedTracks.indexOf(lowerTrack);
    selectedTracks
      ..removeAt(index)
      ..insert(index, newTrack);

    // lowerTrack = lowerTrack.copyWith(lines: newTrack.lines);

    emit(state.copyWith(selectedTracks: selectedTracks));
  }

  /// Places the plate profile on the lower track.
  /// The plate profile is aligned with the lower track.
  ///
  /// The plate profile is placed on the lower track at the same position as the
  /// lower track.
  ///
  /// When the lower track or the plate does not exist nothing happens.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  void _placePlateOnLowerTrack(SimulationToolsChanged event,
      Emitter<SimulationPageState> emit, List<Tool> selectedPlates) {
    // Tool? lowerTrack = _getToolByType(event.tools, ToolType.lowerTrack);
    Tool? plate = _getToolByType(event.tools, ToolType.plateProfile);

    Tool? lowerTrack = state.selectedTracks
        .firstWhereOrNull((tool) => tool.type.type == ToolType.lowerTrack);

    if (lowerTrack == null || plate == null) {
      return;
    }

    List<Line> plateLines = plate.lines;
    plateLines.first.isSelected = true;

    plate = plate.copyWith(lines: plateLines);

    Tool placedPlate = _placePlateOnTrack(emit, plate, lowerTrack);

    emit(state.copyWith(selectedPlates: [placedPlate]));
  }

  /// Places the upper track on the plate profile.
  /// The upper track is aligned with the plate profile.
  /// The upper track is placed on the plate profile at the same position as the
  /// plate profile.
  ///
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  void _placeUpperTrackOnPlate2(SimulationToolsChanged event,
      Emitter<SimulationPageState> emit, List<Tool> selectedTracks) {
    Tool? upperTrack = _getToolByType(event.tools, ToolType.upperTrack);
    Tool? plate = state.selectedPlates.first;
    // Tool? plate = _getToolByType(event.tools, ToolType.plateProfile);

    if (upperTrack == null || plate == null) {
      return;
    }

    Tool currentUpperTrack = selectedTracks
        .firstWhere((tool) => tool.type.type == ToolType.upperTrack);

    Tool placedTrack = _placeUpperTrackOnPlate(currentUpperTrack, plate);

    selectedTracks
      ..remove(currentUpperTrack)
      ..add(placedTrack);

    // upperTrack = upperTrack.copyWith(lines: placedTrack.lines);

    emit(state.copyWith(selectedTracks: selectedTracks));
  }

  /// Places the upper beam on upper track.
  /// The upper beam is aligned with the upper track.
  /// The upper beam is placed on the upper track at the same position as the
  /// upper track.
  ///
  /// When the upper track does not exist nothing happens.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  void _placeUpperBeamOnUpperTack2(
      SimulationToolsChanged event,
      Emitter<SimulationPageState> emit,
      List<Tool> selectedTracks,
      selectedBeams) {
    // Tool? upperBeam = _getToolByType(event.tools, ToolType.upperBeam);
    // Tool? upperTrack = _getToolByType(event.tools, ToolType.upperTrack);

    Tool? upperBeam = _getToolByType(selectedBeams, ToolType.upperBeam);
    Tool? upperTrack = _getToolByType(selectedTracks, ToolType.upperTrack);

    if (upperBeam == null || upperTrack == null) {
      return;
    }

    Tool placedBeam = _placeTrackOnBeam(upperBeam, upperTrack);

    Tool currentUpperBeam = selectedBeams
        .firstWhere((tool) => tool.type.type == ToolType.upperBeam);

    selectedBeams
      ..remove(currentUpperBeam)
      ..add(placedBeam);

    emit(state.copyWith(selectedBeams: selectedBeams));
  }

  /// Starts the simulation
  void _startSimulation(
      SimulationStarted event, Emitter<SimulationPageState> emit) {
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.timeInterval.toInt())
        .listen((duration) => add(SimulationTicked(duration: duration)));
    // _initSimulation(
    //     state.selectedPlates.first, emit, event.timeInterval.toInt());

    // emit(state.copyWith(isSimulationRunning: true));
  }

  /// Stops the simulation
  void _stopSimulation(
      SimulationStopped event, Emitter<SimulationPageState> emit) {
    print('stop simulation');
    timer?.cancel();
    emit(state.copyWith(isSimulationRunning: false));
  }

  void _initSimulation(
      Tool tool, Emitter<SimulationPageState> emit, int timeInterval) {
    timer = Timer.periodic(Duration(seconds: timeInterval),
        (Timer t) => {_nextStepInSimulation(tool, emit)});
  }

  Future<void> _nextStepInSimulation(
      Tool tool, Emitter<SimulationPageState> emit) async {}

  void _nextCollision(
      SimulationTicked event, Emitter<SimulationPageState> emit) {
    // print('next collision');
    // Tool plate = state.selectedPlates.first;
    // Tool rotatedPlate = _rotTool(plate, 90);
    // emit(state.copyWith(selectedPlates: [rotatedPlate]));
  }

  void _onTicked(SimulationTicked event, Emitter<SimulationPageState> emit) {
    // emit(
    //   event.duration > 0
    //       ? TimerRunInProgress(event.duration)
    //       : TimerRunComplete(),
    // );
  }
}

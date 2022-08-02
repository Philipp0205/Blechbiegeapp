import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
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
  SimulationPageBloc()
      : super(SimulationPageInitial(
            tools: [],
            lines: [],
            selectedBeams: [],
            selectedTracks: [],
            selectedPlates: [],
            rotationAngle: 0,
            debugOffsets: [])) {
    on<SimulationPageCreated>(_setInitialLines);
    on<SimulationToolsChanged>(_setTools);
    on<SimulationToolRotate>(_rotateTool);
    on<SimulationSelectedPlateLineChanged>(_nextLineOfPlate);
    on<SimulationToolMirrored>(_mirrorTool);
  }

  GeometricCalculationsService _calculationsService =
      new GeometricCalculationsService();

  /// Set the initial lines of the simulation.
  void _setInitialLines(
      SimulationPageCreated event, Emitter<SimulationPageState> emit) {
    emit(state.copyWith(lines: event.lines));
  }

  /// Set the tools of the simulation.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  void _setTools(
      SimulationToolsChanged event, Emitter<SimulationPageState> emit) {
    print('setTools');
    if (event.tools.isEmpty) return;

    List<Tool> selectedBeams =
        _getToolsByCategory(event.tools, ToolCategoryEnum.BEAM);
    List<Tool> selectedTracks =
        _getToolsByCategory(event.tools, ToolCategoryEnum.TRACK);
    List<Tool> selectedPlates =
        _getToolsByCategory(event.tools, ToolCategoryEnum.PLATE_PROFILE);

    Tool? upperBeam = _getToolByType(event.tools, ToolType.upperBeam);
    Tool? lowerBeam = _getToolByType(event.tools, ToolType.lowerBeam);
    Tool? lowerTrack = _getToolByType(event.tools, ToolType.lowerTrack);
    Tool? upperTrack = _getToolByType(event.tools, ToolType.upperTrack);
    Tool? plate = _getToolByType(event.tools, ToolType.plateProfile);

    if (selectedBeams.isNotEmpty) {
      selectedBeams.addAll(_placeLowerBeam(selectedBeams));
    }

    if (plate != null) {}

    if (lowerTrack != null && lowerBeam != null) {
      Tool newTrack = _placeTrackOnBeam(lowerTrack, lowerBeam);

      int index = selectedTracks.indexOf(lowerTrack);
      selectedTracks
        ..removeAt(index)
        ..insert(index, newTrack);

      lowerTrack = lowerTrack.copyWith(lines: newTrack.lines);
    }

    if (lowerTrack != null && plate != null) {
      Tool placedPlate = _placePlateOnTrack(emit, plate, lowerTrack);

      // Should only contain one item anyway.
      selectedPlates
        ..removeLast()
        ..add(placedPlate);

      plate = plate.copyWith(lines: placedPlate.lines);
    }

    if (upperTrack != null && plate != null) {
      Tool placedTrack = _placeUpperTrackOnPlate(upperTrack, plate);

      Tool currentUpperTrack = selectedTracks
          .firstWhere((tool) => tool.type.type == ToolType.upperTrack);
      selectedTracks
        ..remove(currentUpperTrack)
        ..add(placedTrack);

      upperTrack = upperTrack.copyWith(lines: placedTrack.lines);
    }

    if (upperTrack != null && upperBeam != null) {
      print('place upperBeam on upperTrack');
      Tool placedBeam = _placeTrackOnBeam(upperBeam, upperTrack);

      Tool currentUpperBeam = selectedBeams
          .firstWhere((tool) => tool.type.type == ToolType.upperBeam);
      selectedBeams
        ..remove(currentUpperBeam)
        ..add(placedBeam);
    }

    emit(state
        .copyWith(selectedBeams: [], selectedTracks: [], selectedPlates: []));
    emit(state.copyWith(
        selectedBeams: selectedBeams,
        selectedTracks: selectedTracks,
        selectedPlates: selectedPlates));
  }

  /// Places the lower beam in the simulation.
  /// This method is called when the [SimulationBeamsChanged] event is emitted.
  List<Tool> _placeLowerBeam(List<Tool> beams) {
    List<Tool> placedBeams = [];
    Tool lowerBeam =
        beams.firstWhere((beam) => beam.type.type == ToolType.lowerBeam);

    placedBeams.add(lowerBeam);
    return placedBeams;
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

    print(selectedLine);

    List<Offset> lowestTrackXOffsets =
        _calculationsService.getLowestX(trackOffsets);

    Offset trackOffset =
        _calculationsService.getLowestY(lowestTrackXOffsets).first;

    // Offset plateOffset = _calculationsService
    //     .getLowestX([selectedLine.start, selectedLine.end]).first;
    Offset plateOffset = selectedLine.start;

    Offset moveOffset = plateOffset - trackOffset;

    Tool movedTool = _moveTool(plate, moveOffset, false);

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

  /// When the lower beam, lower track and the plat are already placed,
  /// the the upper beam and upper track are placed above them.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  Tool _placeUpperBeamAndTrackOnPlate(
      Tool upperBeam, Tool upperTrack, Tool plate) {
    List<Offset> plateOffsets = plate.lines.map((line) => line.start).toList() +
        plate.lines.map((line) => line.end).toList();

    List<Offset> lowestXOffsets = _calculationsService.getLowestX(plateOffsets);
    Offset plateOffset = _calculationsService.getLowestY(lowestXOffsets).first;

    Offset upperBeamOffset =
        upperBeam.lines.first.start.dx > upperBeam.lines.first.end.dx
            ? upperBeam.lines.first.end
            : upperBeam.lines.first.start;

    Offset newOffset = upperBeamOffset - plateOffset;

    Tool movedTool = _moveTool(upperBeam, newOffset, false);
    return movedTool;
  }

  Tool? _getToolByType(List<Tool> tools, ToolType type) {
    return tools.firstWhereOrNull((tool) => tool.type.type == type);
  }

  /// Place upper track on plate with distance s.
  /// The upper track is aligned with the plate.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  /// The upper track is placed on the plate at the same position as the plate.
  Tool _placeUpperTrackOnPlate(Tool upperTrack, Tool plate) {
    print('placeUpperTrackOnPlate');
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

    Offset newOffset = trackOffset - plateOffset + new Offset(0, s - 2);

    Tool movedTool = _moveTool(upperTrack, newOffset, false);
    return movedTool;
  }

  /// Place upper Beam on plate with distance s.
  /// The upper beam is aligned with the plate.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  /// The upper beam is placed on the plate at the same position as the plate.
  Tool _placeUpperBeamOnUpperTrack(Tool upperBeam, Tool upperTrack) {
    print('placeUpperBeamOnPlate');

    List<Offset> upperBeamOffsets =
        upperBeam.lines.map((line) => line.start).toList() +
            upperBeam.lines.map((line) => line.end).toList();

    List<Offset> lowestXOffsets =
        _calculationsService.getLowestX(upperBeamOffsets);
    Offset plateOffset = _calculationsService.getLowestY(lowestXOffsets).first;

    Offset upperBeamOffset =
        upperBeam.lines.first.start.dx > upperBeam.lines.first.end.dx
            ? upperBeam.lines.first.end
            : upperBeam.lines.first.start;

    Offset newOffset = upperBeamOffset - plateOffset;

    Tool movedTool = _moveTool(upperBeam, newOffset, false);
    return movedTool;
  }

  /// Rotate a [tool] clockwise around [center] by [degrees].
  Tool _rotateTool2(Tool tool, Offset center, double degrees) {
    return tool.copyWith(
        lines: _calculationsService.rotateLines(tool.lines, center, degrees));
  }

  void _rotateTool(
      SimulationToolRotate event, Emitter<SimulationPageState> emit) {
    Line selectedLine = event.tool.lines.firstWhere((line) => line.isSelected);
    Offset center =
        _calculationsService.getMiddle(selectedLine.start, selectedLine.end);
    List<Line> rotatetLines = _calculationsService.rotateLines(
        event.tool.lines, center, event.degrees);

    // Line selectedLine = event.tool.lines.firstWhere((line) => line.isSelected);
    // Offset center =
    //     _calculationsService.getMiddle(selectedLine.start, selectedLine.end);
    // Tool rotatedTool = event.tool.copyWith(
    //     lines: _calculationsService.rotateLines(
    //         event.tool.lines, center, event.degrees));

    emit(state.copyWith(selectedPlates: []));
    emit(state.copyWith(
        selectedPlates: [event.tool.copyWith(lines: rotatetLines)],
        debugOffsets: []));
  }

  /// Rotate the given [tool] around the center of the selected line of that
  /// tool until a the given [angle] is reached.
  /// The [stepSize] sets how much the tool is rotated each time.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  Tool _rotateUntilSelectedLineHasAngle(
      Tool tool, List<double> angles, double stepSize) {
    print('_rotateUntilSelectedLineHasAngle');
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
        print('currentAngle found');
        return tool;
      }
    }

    print('no angle found');
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
}

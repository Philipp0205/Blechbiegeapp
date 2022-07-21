import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
            selectedPlates: [])) {
    on<SimulationPageCreated>(_setInitialLines);
    on<SimulationToolsChanged>(_setTools);
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
    if (event.tools.isEmpty) return;

    List<Tool> selectedBeams =
        _getToolsByCategory(event.tools, ToolCategoryEnum.BEAM);
    List<Tool> selectedTracks =
        _getToolsByCategory(event.tools, ToolCategoryEnum.TRACK);
    List<Tool> selectedPlates =
        _getToolsByCategory(event.tools, ToolCategoryEnum.PLATE_PROFILE);

    Tool? upperBeam = _getToolByType(event.tools, ToolType.upperBeam);
    Tool? lowerBeam = _getToolByType(event.tools, ToolType.lowerBeam);
    Tool? upperTrack = _getToolByType(event.tools, ToolType.upperTrack);
    Tool? lowerTrack = _getToolByType(event.tools, ToolType.lowerTrack);
    Tool? plate = _getToolByType(event.tools, ToolType.plateProfile);

    if (selectedBeams.isNotEmpty) {
      selectedBeams.addAll(_placeLowerBeam(selectedBeams));

      if (upperBeam != null && upperTrack != null) {
        selectedBeams.add(upperBeam);
        // _placeUpperBeamAndTrackOnPlate(upperBeam, upperTrack, upperTrack);
      }
    }

    if (lowerTrack != null && lowerBeam != null) {
      Tool newTrack = _placeTrackOnBeam(lowerTrack, lowerBeam);

      int index = selectedTracks.indexOf(lowerTrack);
      selectedTracks
        ..removeAt(index)
        ..insert(index, newTrack);
    }

    if (lowerTrack != null && plate != null) {
      Tool placesPlate = _placePlateOnTrack(plate, lowerTrack);

      // Should only contain one item anyway.
      selectedPlates
        ..removeLast()
        ..add(placesPlate);
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

  /// Place plate on lower track.
  Tool _placePlateOnTrack(Tool plate, Tool lowerTrack) {
    print('placePlateOnTrack');

    List<Offset> trackOffsets =
        lowerTrack.lines.map((line) => line.start).toList() +
            lowerTrack.lines.map((line) => line.end).toList();

    List<Offset> lowestXOffsets = _calculationsService.getLowestX(trackOffsets);

    Offset trackOffset = _calculationsService.getLowestY(lowestXOffsets).first;

    Offset plateOffset = plate.lines.first.start.dx > plate.lines.first.end.dx
        ? plate.lines.first.end
        : plate.lines.first.start;

    Offset newOffset = plateOffset - trackOffset;

    Tool newTool = _moveTool(plate, newOffset, false);
    return newTool;
  }

  List<Tool> _getToolsByCategory(List<Tool> tools, ToolCategoryEnum category) {
    return tools.where((tool) => tool.type.category == category).toList();
  }

  /// When the lower beam, lower track and the plat are already placed,
  /// the the upper beam and upper track are placed above them.
  /// This method is called when the [SimulationToolsChanged] event is emitted.
  Tool _placeUpperBeamAndTrackOnPlate(
      Tool upperBeam, Tool upperTrack, Tool plate) {
    print('placeUpperBeamOnPlate');

    List<Offset> plateOffsets = plate.lines.map((line) => line.start).toList() +
        plate.lines.map((line) => line.end).toList();

    List<Offset> lowestXOffsets = _calculationsService.getLowestX(plateOffsets);
    Offset plateOffset = _calculationsService.getLowestY(lowestXOffsets).first;

    Offset upperBeamOffset =
        upperBeam.lines.first.start.dx > upperBeam.lines.first.end.dx
            ? upperBeam.lines.first.end
            : upperBeam.lines.first.start;

    Offset newOffset = upperBeamOffset - plateOffset;

    Tool newTool = _moveTool(upperBeam, newOffset, false);
    return newTool;
  }

  Tool? _getToolByType(List<Tool> tools, ToolType type) {
    return tools
        .firstWhereOrNull((tool) => tool.type.type == ToolType.lowerTrack);
  }
}

import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';

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
    if (event.tools.isNotEmpty) {
      List<Tool> selectedBeams = event.tools
          .where((tool) =>
              tool.isSelected && tool.type.category == ToolCategoryEnum.BEAM)
          .toList();

      List<Tool> selectedTracks = event.tools
          .where((tool) =>
              tool.isSelected && tool.type.category == ToolCategoryEnum.TRACK)
          .toList();

      List<Tool> selectedPlates = event.tools
          .where((tool) => tool.type.category == ToolCategoryEnum.PLATE_PROFILE)
          .toList();

      if (selectedTracks.isNotEmpty) {
        Tool newTrack =
            _placeTrackOnBeam(selectedTracks.first, selectedBeams.first);
        selectedTracks
          ..remove(selectedTracks.first)
          ..add(newTrack);
      }

      if (selectedPlates.isNotEmpty) {
        Tool placesPlate =
            _placePlateOnTrack(selectedPlates.first, selectedTracks.first);

        selectedPlates
          ..remove(selectedPlates.first)
          ..add(placesPlate);

        print('plates: ${selectedPlates.length}');
      }

      emit(state
          .copyWith(selectedBeams: [], selectedTracks: [], selectedPlates: []));

      emit(state.copyWith(
          selectedBeams: selectedBeams,
          selectedTracks: selectedTracks,
          selectedPlates: selectedPlates));
    }
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

    Line adapterLine = lowerTrack.lines.where((line) => line.isSelected).first;

    List<Offset> trackOffsets =
        lowerTrack.lines.map((line) => line.start).toList() +
            lowerTrack.lines.map((line) => line.end).toList();

    List<Offset> lowestXOffsets = _calculationsService.getLowestX(trackOffsets);

    Offset trackOffset =
        _calculationsService.getLowestY(lowestXOffsets).first;

    Offset plateOffset = plate.lines.first.start.dx > plate.lines.first.end.dx
        ? plate.lines.first.end
        : plate.lines.first.start;

    Offset newOffset = plateOffset - trackOffset;

    Tool newTool = _moveTool(plate, newOffset, false);
    return newTool;
  }
}

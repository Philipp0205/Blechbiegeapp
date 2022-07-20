import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/line.dart';
import '../../model/simulation/tool.dart';
import '../../model/simulation/tool_category.dart';

part 'simulation_page_event.dart';

part 'simulation_page_state.dart';

/// Business logic for the [SimulationPage].
class SimulationPageBloc
    extends Bloc<SimulationPageEvent, SimulationPageState> {
  SimulationPageBloc()
      : super(SimulationPageInitial(
            tools: [], lines: [], selectedBeams: [], selectedTracks: [])) {
    on<SimulationPageCreated>(_setInitialLines);
    on<SimulationToolsChanged>(_setTools);
  }

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
          .where(
              (tool) => tool.isSelected && tool.type.category == ToolCategory.BEAM)
          .toList();

      List<Tool> selectedTracks = event.tools
          .where(
              (tool) => tool.isSelected && tool.type.category == ToolCategory.TRACK)
          .toList();

      if (selectedTracks.isNotEmpty) {
        Tool newTrack =
            _placeTrackOnBeam(selectedTracks.first, selectedBeams.first);
        selectedTracks.add(newTrack);
      }

      print(
          'selectedBeams: ${selectedBeams.length}, selectedTracks: ${selectedTracks.length}');

      emit(state.copyWith(selectedBeams: [], selectedTracks: []));
      emit(state.copyWith(
          selectedBeams: selectedBeams, selectedTracks: selectedTracks));
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

    Tool newTool = _moveTool(track, newOffset);

    return newTool;
  }

  /// Move a tool.
  /// The tool is moved by the given [offset].
  Tool _moveTool(Tool tool, Offset offset) {
    List<Line> lines = tool.lines;
    List<Line> newLines = [];
    lines.forEach((line) {
      newLines.add(
          line.copyWith(start: line.start + offset, end: line.end + offset));
    });

    return tool.copyWith(lines: newLines);
  }
}

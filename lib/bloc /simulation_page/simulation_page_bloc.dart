import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/line.dart';
import '../../model/simulation/tool.dart';
import '../../model/simulation/tool_category.dart';

part 'simulation_page_event.dart';

part 'simulation_page_state.dart';

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
              (tool) => tool.isSelected && tool.category == ToolCategory.BEAM)
          .toList();

      List<Tool> selectedTracks = event.tools
          .where(
              (tool) => tool.isSelected && tool.category == ToolCategory.TRACK)
          .toList();

      selectedTracks.forEach((track) {
        Tool newTrack = _placeTrackOnBeam(track, selectedBeams.first);
        int index = selectedTracks.indexOf(track);
        selectedTracks
          ..removeAt(0)
          ..insert(index, newTrack);
      });

      print(
          'selectedBeams: ${selectedBeams.length}, selectedTracks: ${selectedTracks.length}');

      emit(state.copyWith(selectedBeams: [], selectedTracks: []));
      emit(state.copyWith(
          selectedBeams: selectedBeams, selectedTracks: selectedTracks));
    }
  }

  Tool _placeTrackOnBeam(Tool track, Tool beam) {
    print('placeTrackOnBeam');
    Line beamAdapterLine = beam.lines.where((line) => line.isSelected).first;
    Line trackAdapterLine = track.lines.where((line) => line.isSelected).first;

    double deltaX = (beamAdapterLine.start.dx - beamAdapterLine.start.dx).abs();
    double deltaY = (beamAdapterLine.start.dy - beamAdapterLine.start.dy).abs();

    Offset newOffsetStart = new Offset(
        trackAdapterLine.start.dx - deltaX, trackAdapterLine.start.dy - deltaY);

    Line newLine = trackAdapterLine.copyWith(start: newOffsetStart);

    List<Line> lines = track.lines;
    int index = lines.indexOf(trackAdapterLine);

    lines
      ..removeAt(index)
      ..insert(index, newLine);

    return track.copyWith(lines: lines);
  }
}

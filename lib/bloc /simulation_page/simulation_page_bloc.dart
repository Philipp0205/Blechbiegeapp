import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/line.dart';
import '../../model/simulation/tool.dart';

part 'simulation_page_event.dart';

part 'simulation_page_state.dart';

class SimulationPageBloc
    extends Bloc<SimulationPageEvent, SimulationPageState> {
  SimulationPageBloc()
      : super(SimulationPageInitial(
            tools: [], lines: [], selectedBeams: [], selectedTracks: [])) {
    on<SimulationPageCreated>(_setInitialLines);
    on<SimulationSelectedToolsChanged>(_setSelectedBeam);
    on<SimulationSelectedTracksChanged>(_setSelectedTracks);
  }

  /// Set the initial lines of the simulation.
  void _setInitialLines(
      SimulationPageCreated event, Emitter<SimulationPageState> emit) {
    emit(state.copyWith(lines: event.lines));
  }

  /// Set the selected beams of the simulation.
  void _setSelectedBeam(
      SimulationSelectedToolsChanged event, Emitter<SimulationPageState> emit) {
    emit(state.copyWith(selectedBeams: event.selectedTools));
  }

  /// Set the selected tracks of the simulation.
  void _setSelectedTracks(SimulationSelectedTracksChanged event,
      Emitter<SimulationPageState> emit) {

    // Tool newTrack = _placeTrackOnBeam(event.selectedTracks.first, state.selectedBeams.first);

    emit(state.copyWith(selectedTracks: event.selectedTracks));
  }

  Tool _placeTrackOnBeam(Tool track, Tool beam) {
    print('placeTrackOnBeam');
    Line beamAdapterLine = beam.lines.where((line) => line.isSelected).first;
    Line trackAdapterLine = track.lines.where((line) => line.isSelected).first;

    double deltaX = (beamAdapterLine.start.dx - beamAdapterLine.start.dx).abs();
    double deltaY = (beamAdapterLine.start.dy - beamAdapterLine.start.dy).abs();

    Offset newOffsetStart = new Offset(trackAdapterLine.start.dx + deltaX, trackAdapterLine.start.dy + deltaY);

    Line newLine = trackAdapterLine.copyWith(start: newOffsetStart);

    List<Line> lines = track.lines;
    int index = lines.indexOf(trackAdapterLine);

    lines..removeAt(index)..insert(index, newLine);

    return track.copyWith(lines: lines);
  }
}

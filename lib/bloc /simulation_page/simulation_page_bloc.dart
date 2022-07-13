import 'dart:async';

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
    on<SimulationSelectedToolsChanged>(_setSelectedTool);
    on<SimulationSelectedTracksChanged>(_setSelectedTracks);
  }

  /// Set the initial lines of the simulation.
  void _setInitialLines(
      SimulationPageCreated event, Emitter<SimulationPageState> emit) {
    emit(state.copyWith(lines: event.lines));
  }

  /// Set the selected beams of the simulation.
  void _setSelectedTool(
      SimulationSelectedToolsChanged event, Emitter<SimulationPageState> emit) {
    emit(state.copyWith(selectedBeams: event.selectedTools));
  }

  /// Set the selected tracks of the simulation.
  void _setSelectedTracks(SimulationSelectedTracksChanged event,
      Emitter<SimulationPageState> emit) {

    emit(state.copyWith(selectedTracks: event.selectedTracks));
  }

  void _placeTrackOnBeam(Tool track, Tool beam) {


  }
}

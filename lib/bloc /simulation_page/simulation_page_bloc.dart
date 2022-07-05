import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/Line2.dart';
import '../../model/simulation/shape.dart';

part 'simulation_page_event.dart';

part 'simulation_page_state.dart';

class SimulationPageBloc
    extends Bloc<SimulationPageEvent, SimulationPageState> {
  SimulationPageBloc() : super(SimulationPageInitial(shapes: [], lines: [])) {
    on<SimulationPageCreated>(_setInitialLines);
  }

  void _setInitialLines(SimulationPageCreated event, Emitter<SimulationPageState> emit) {
    emit(state.copyWith(lines: event.lines));
  }
}

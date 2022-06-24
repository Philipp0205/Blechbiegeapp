import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'simulation_page_event.dart';
part 'simulation_page_state.dart';

class SimulationPageBloc extends Bloc<SimulationPageEvent, SimulationPageState> {
  SimulationPageBloc() : super(SimulationPageInitial()) {
    on<SimulationPageEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

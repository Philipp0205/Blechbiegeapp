import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_bsp/model/Line2.dart';

import '../../model/simulation/shape.dart';

part 'simulation_page_event.dart';
part 'simulation_page_state.dart';

class SimulationPageBloc extends Bloc<SimulationPageEvent, SimulationPageState> {
  SimulationPageBloc() : super(SimulationPageInitial(lowerBeam: , bendingBeam: , upperBeam: )) {
    on<SimulationPageEvent>((event, emit) {
      // TODO: implement event handler
    });
  }

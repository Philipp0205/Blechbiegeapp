import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/segment.dart';

part 'current_path_event.dart';

part 'current_path_state.dart';

class CurrentPathBloc extends Bloc<CurrentPathEvent, CurrentPathState> {
  CurrentPathBloc()
      : super(CurrentSegmentInitial(currentSegment: [
          new Segment([new Offset(0, 0)], Colors.black, 5)
        ])) {
    on<OnPanStarted>(_onCurrentPathStarted);
    on<OnPanUpdated>(_onCurrentPathUpdated);
    on<OnSegmentDeleted>(_onSegmentDeleted);
  }

  void _onCurrentPathStarted(
      OnPanStarted event, Emitter<CurrentPathState> emit) {
    print('_onCurrentPathStarted');
    // emit(CurrentSegment(event.currentSegment));
  }

  void _onCurrentPathUpdated(
      OnPanUpdated event, Emitter<CurrentPathState> emit) {

    List<Offset> path = List.from(event.currentSegment.first.path);
    path.add(event.offset);

    List<Segment> segment = [new Segment(path, Colors.black, 5)];

    if (event.currentSegment.first.path.first == new Offset(0, 0)) {
      print('path remofe initial offset $path');
      segment.first.path.removeAt(0);
    }

    emit(CurrentSegmentUpdated(segment: segment));
  }


  void _onSegmentDeleted(
      OnSegmentDeleted event, Emitter<CurrentPathState> emit) {

    Segment segment = new Segment([new Offset(0, 0)], Colors.black, 5);
    emit(CurrentSegmentUpdated(segment: [segment]));
  }
}

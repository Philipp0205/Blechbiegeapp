import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../model/segment_widget/segment.dart';
import '../../model/segment_offset.dart';

part 'configuration_page_event.dart';

part 'configuration_page_state.dart';

class ConfigurationPageBloc
    extends Bloc<ConfigurationPageEvent, ConstructingPageState> {
  // ConstructingPageBloc() : super(ConstructingPageCreate(segment: [])) {
  ConfigurationPageBloc()
      : super(ConstructingPageInitial(
            segment: [],
            showCoordinates: false,
            showEdgeLengths: false,
            showAngles: false,
            color: Colors.black,
            s: 5,
            r: 20)) {
    on<ConfigPageCreated>(_setInitialSegment);
    on<ConfigCoordinatesShown>(_showCoordinates);
    on<ConfigEdgeLengthsShown>(_showEdgeLengths);
    on<ConfigAnglesShown>(_showAngles);
    on<ConfigCheckboxChanged>(_showDataDependingOnCheckbox);
    on<ConfigSChanged>(_changeThicknes);
    on<ConfigRChanged>(_changeRadius);
  }

  // section Draw initial segment
  /*
  *   ____                        _       _ _   _       _                                        _   
  *  |  _ \ _ __ __ ___      __  (_)_ __ (_) |_(_) __ _| |   ___  ___  __ _ _ __ ___   ___ _ __ | |_ 
  *  | | | | '__/ _` \ \ /\ / /  | | '_ \| | __| |/ _` | |  / __|/ _ \/ _` | '_ ` _ \ / _ \ '_ \| __|
  *  | |_| | | | (_| |\ V  V /   | | | | | | |_| | (_| | |  \__ \  __/ (_| | | | | | |  __/ | | | |_ 
  *  |____/|_|  \__,_| \_/\_/    |_|_| |_|_|\__|_|\__,_|_|  |___/\___|\__, |_| |_| |_|\___|_| |_|\__|
  *                                                                   |___/                          
  */

  void _setInitialSegment(
      ConfigPageCreated event, Emitter<ConstructingPageState> emit) {
    List<SegmentOffset> result = cropSegmentToArea(event.segment.first);

    emit(state.copyWith(segment: [event.segment.first.copyWith(path: result)]));
    // emit(ConstructingPageCreate(
    //     segment: [event.segment.first.copyWith(path: result)]));
  }

  List<SegmentOffset> cropSegmentToArea(Segment segment) {
    Map<int, double> xValues = {};
    Map<int, double> yValues = {};

    List<SegmentOffset> path = segment.path;

    path.forEach((o) {
      xValues.addEntries([MapEntry(path.indexOf(o), o.offset.dx)]);
      yValues.addEntries([MapEntry(path.indexOf(o), o.offset.dy)]);
    });

    var xEntries = xValues.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    var yEntries = yValues.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    xValues
      ..clear()
      ..addEntries(xEntries);
    yValues
      ..clear()
      ..addEntries(yEntries);

    print('');

    SegmentOffset smallestX = segment.path[xValues.entries.last.key];
    SegmentOffset smallestY = segment.path[yValues.entries.last.key];
    SegmentOffset highestX = segment.path[xValues.entries.first.key];
    SegmentOffset highestY = segment.path[yValues.entries.first.key];

    List<SegmentOffset> result = [];

    path.forEach((o) {
      Offset offset =
          new Offset(o.offset.dx, o.offset.dy - (highestY.offset.dy - 40));

      result.add(o.copyWith(offset: offset));
    });

    return result;
  }

  // section Segment details
  /*
  *   ____                                  _          _      _        _ _
  *  / ___|  ___  __ _ _ __ ___   ___ _ __ | |_     __| | ___| |_ __ _(_) |___
  *  \___ \ / _ \/ _` | '_ ` _ \ / _ \ '_ \| __|   / _` |/ _ \ __/ _` | | / __|
  *   ___) |  __/ (_| | | | | | |  __/ | | | |_   | (_| |  __/ || (_| | | \__ \
  *  |____/ \___|\__, |_| |_| |_|\___|_| |_|\__|   \__,_|\___|\__\__,_|_|_|___/
  *              |___/
  */
  void _showCoordinates(ConfigCoordinatesShown event,
      Emitter<ConstructingPageState> emit) {
    emit(state.copyWith(showCoordinates: event.showCoordinates));
  }

  void _showEdgeLengths(ConfigEdgeLengthsShown event,
      Emitter<ConstructingPageState> emit) {
    emit(state.copyWith(showEdgeLengths: event.showEdgeLengths));
  }

  void _showAngles(
      ConfigAnglesShown event, Emitter<ConstructingPageState> emit) {
    emit(state.copyWith(showAngles: event.showAngles));
  }

  void _showDataDependingOnCheckbox(ConfigCheckboxChanged event,
      Emitter<ConstructingPageState> emit) {
    switch (event.checkBox) {
      case CheckBoxEnum.coordinates:
        emit(state.copyWith(showCoordinates: event.checkBoxValue));
        break;
      case CheckBoxEnum.lengths:
        emit(state.copyWith(showEdgeLengths: event.checkBoxValue));
        break;
      case CheckBoxEnum.angles:
        emit(state.copyWith(showAngles: event.checkBoxValue));
        break;
    }
  }

  void _changeThicknes(
      ConfigSChanged event, Emitter<ConstructingPageState> emit) {
    emit(state.copyWith(s: event.s));
  }

  void _changeRadius(ConfigRChanged event, Emitter<ConstructingPageState> emit) {
    emit(state.copyWith(r: event.r));
  }
}

enum CheckBoxEnum { coordinates, lengths, angles }

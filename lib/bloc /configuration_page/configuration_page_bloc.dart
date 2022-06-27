import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../model/segment_widget/segment.dart';
import '../../model/segment_offset.dart';
import '../../model/simulation/shape.dart';

part 'configuration_page_event.dart';

part 'configuration_page_state.dart';

class ConfigPageBloc extends Bloc<ConfigurationPageEvent, ConfigPageState> {
  // ConstructingPageBloc() : super(ConstructingPageCreate(segment: [])) {
  ConfigPageBloc()
      : super(ConstructingPageInitial(
            segment: [],
            shapes: [],
            showCoordinates: false,
            showEdgeLengths: false,
            showAngles: false,
            s: 5,
            r: 20)) {
    on<ConfigPageCreated>(_setInitialSegment);
    on<ConfigCoordinatesShown>(_showCoordinates);
    on<ConfigEdgeLengthsShown>(_showEdgeLengths);
    on<ConfigAnglesShown>(_showAngles);
    on<ConfigCheckboxChanged>(_showDataDependingOnCheckbox);
    on<ConfigSChanged>(_changeThicknes);
    on<ConfigRChanged>(_changeRadius);
    on<ConfigShapeAdded>(_saveShape);
  }

  /// When no segment exists an initial segment gets created.
  void _setInitialSegment(
      ConfigPageCreated event, Emitter<ConfigPageState> emit) {
    List<SegmentOffset> result = _cropSegmentToArea(event.segment.first);

    emit(state.copyWith(segment: [event.segment.first.copyWith(path: result)]));
  }

  /// Moves a segment on the y-axis to fit another canvas and not overshoot it.
  List<SegmentOffset> _cropSegmentToArea(Segment segment) {
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

    SegmentOffset highestY = segment.path[yValues.entries.first.key];

    List<SegmentOffset> result = [];

    path.forEach((o) {
      Offset offset =
          new Offset(o.offset.dx, o.offset.dy - (highestY.offset.dy - 40));

      result.add(o.copyWith(offset: offset));
    });

    return result;
  }

  /// Decides depending on the [CheckBoxEnum] what should be shown.
  void _showDataDependingOnCheckbox(
      ConfigCheckboxChanged event, Emitter<ConfigPageState> emit) {
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

  /// Handles event for showing the coordinates of each line on the canvas.
  void _showCoordinates(
      ConfigCoordinatesShown event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(showCoordinates: event.showCoordinates));
  }

  /// Handles event for showing the lengths of each line on the canvas.
  void _showEdgeLengths(
      ConfigEdgeLengthsShown event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(showEdgeLengths: event.showEdgeLengths));
  }

  /// Handles the event for showing the inner angles between liens on the canvas.
  void _showAngles(ConfigAnglesShown event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(showAngles: event.showAngles));
  }

  /// Handles event that changes the thickness of the line.
  void _changeThicknes(ConfigSChanged event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(s: event.s));
  }

  /// Handles the event that changes the radius of the curves that are drawn.j
  void _changeRadius(ConfigRChanged event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(r: event.r));
  }

  /// Saves a to the state (no DB involved here).
  void _saveShape(ConfigShapeAdded event, Emitter<ConfigPageState> emit) {
    List<Shape> shapes = state.shapes;
    shapes.add(event.shape);
    emit(state.copyWith(shapes: shapes));
  }

}

enum CheckBoxEnum { coordinates, lengths, angles }

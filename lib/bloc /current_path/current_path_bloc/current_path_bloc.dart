import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/segments_repository.dart';
import '../../../model/appmodes.dart';
import '../../../model/segment.dart';

part '../current_path_event.dart';

part '../current_path_state.dart';

class CurrentPathBloc extends Bloc<CurrentPathEvent, CurrentPathState> {
  final SegmentsRepository segmentsRepository;

  CurrentPathBloc(this.segmentsRepository)
      : super(CurrentSegmentInitial(currentSegment: [])) {
    on<CurrentPathPanStarted>(_onCurrentPanStarted);
    on<CurrentPathPanUpdated>(_onCurrentPathUpdated);
    on<CurrentPathPanEnded>(_onPanEnd);
    on<CurrentPathPanDowned>(_onPanDown);
    on<CurrentSegmentDeleted>(_deleteCurrentSegment);
  }

  /// Creates currently drawn segment
  void _onCurrentPanStarted(
      CurrentPathPanStarted event, Emitter<CurrentPathState> emit) {
    switch (event.mode) {
      case Mode.defaultMode:
        _onPanStarteDefaultMode(event, emit);
        break;
      case Mode.pointMode:
        // TODO: Handle this case.
        break;
      case Mode.selectionMode:
        // TODO: Handle this case.
        break;
    }
  }

  void _onPanStarteDefaultMode(
      CurrentPathPanStarted event, Emitter<CurrentPathState> emit) {
    print('_onPanStartedDefaultMode');
    Segment segment = new Segment([event.firstDrawnOffset], Colors.black, 5);
    emit(CurrentSegmentUpdate(segment: [segment]));
  }

  void _onCurrentPathUpdated(
      CurrentPathPanUpdated event, Emitter<CurrentPathState> emit) {
    switch (event.mode) {
      case Mode.defaultMode:
        _onPanUpdateDefaultMode(event, emit);
        break;
      case Mode.pointMode:
        // TODO: Handle this case.
        break;
      case Mode.selectionMode:
        // TODO: Handle this case.
        break;
    }
  }

  void _onPanUpdateDefaultMode(
      CurrentPathPanUpdated event, Emitter<CurrentPathState> emit) {
    List<Offset> path = [event.currentSegment.first.path.first, event.offset];
    List<Segment> segment = [new Segment(path, Colors.black, 5)];
    emit(CurrentSegmentUpdate(segment: segment));
  }

  void _onPanEnd(CurrentPathPanEnded event, Emitter<CurrentPathState> emit) {
    switch (event.mode) {
      case Mode.defaultMode:
        _onPanEndDefaultMode(event, emit);
        break;
      case Mode.pointMode:
        // TODO: Handle this case.
        break;
      case Mode.selectionMode:
        // TODO: Handle this case.
        break;
    }
  }

  void _onPanEndDefaultMode(CurrentPathPanEnded event, Emitter<CurrentPathState> emit) {
    segmentsRepository.addSegment(event.currentSegment.first);
    emit(CurrentSegmentUpdate(segment: [event.currentSegment.first]));
    emit(CurrentSegmentDelete());
  }

  void _deleteCurrentSegment(
      CurrentSegmentDeleted event, Emitter<CurrentPathState> emit) {
    print('_deleteCurrentSegment');
    emit(CurrentSegmentDelete());
  }

  void _onPanDown(
      CurrentPathPanDowned event, Emitter<CurrentPathState> emit) {
    print('onpandowned');

    if (event.mode == Mode.selectionMode) {
      if (state.currentSegment.length > 0 ) {
        state.currentSegment.first.color = Colors.black;

      }
      Segment lowestDistanceLine = getNearestSegment(event.details);
      lowestDistanceLine.color = Colors.red;

      emit(CurrentSegmentUpdate(segment: [lowestDistanceLine]));
      print('currentsegment ${state.currentSegment.length}');
    }
  }

  Segment getNearestSegment(DragDownDetails details) {
    Map<Segment, double> distances = {};

    segmentsRepository.getAllSegments().forEach((line) {
      distances.addEntries([MapEntry(line, getDistanceToLine(details, line))]);
    });

    var mapEntries = distances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    distances
      ..clear()
      ..addEntries(mapEntries);

    return distances.keys.toList().first;
  }

  /*
       Distance(point1, currPoint)
     + Distance(currPoint, point2)
    == Distance(point1, point2)

    https://stackoverflow.com/questions/11907947/how-to-check-if-a-point-lies-on-a-line-between-2-other-points/11912171#11912171
  */
  double getDistanceToLine(DragDownDetails details, Segment line) {
    Point currentPoint =
        new Point(details.globalPosition.dx, details.globalPosition.dy);
    Point startPoint = new Point(line.path.first.dx, line.path.first.dy);
    Point endPoint = new Point(line.path.last.dx, line.path.last.dy);

    return startPoint.distanceTo(currentPoint) +
        currentPoint.distanceTo(endPoint) -
        startPoint.distanceTo(endPoint);
  }
}

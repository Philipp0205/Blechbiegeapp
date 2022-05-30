import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../data/segments_repository.dart';
import '../../model/appmodes.dart';
import '../../model/segment.dart';
import 'current_segment_event.dart';
import 'current_segment_state.dart';

class CurrentSegmentBloc
    extends Bloc<CurrentSegmentEvent, CurrentSegmentState> {
  final SegmentsRepository repository;

  CurrentSegmentBloc(this.repository)
      : super(
      CurrentSegmentInitial(currentSegment: [], mode: Mode.defaultMode)) {
    /// Pan Events
    on<CurrentSegmentPanStarted>(_onPanStart);
    on<CurrentSegmentPanUpdated>(_onPanUpdate);
    on<CurrentSegmentPanEnded>(_onPanEnd);
    on<CurrentSegmentPanDowned>(_onPanDown);

    /// Events regarding mode and current selected segment
    on<CurrentSegmentModeChanged>(_changeMode);
    on<CurrentSegmentDeleted>(_deleteSegment);
    on<CurrentSegmentUnselected>(_unselectSegment);
  }

  /// Creates currently drawn segment
  void _onPanStart(CurrentSegmentPanStarted event,
      Emitter<CurrentSegmentState> emit) {
    switch (event.mode) {
      case Mode.defaultMode:
        _onPanStartDefaultMode(event, emit);
        break;
      case Mode.pointMode:
        _onPanStartPointMode(event, emit);
        break;
      case Mode.selectionMode:
      // TODO: Handle this case.
        break;
    }
  }

  void _onPanStartDefaultMode(CurrentSegmentPanStarted event,
      Emitter<CurrentSegmentState> emit) {
    Segment segment = new Segment([event.firstDrawnOffset], Colors.black, 5);
    emit(CurrentPathSegmentUpdate(segment: [segment], mode: Mode.defaultMode));
  }

  void _onPanStartPointMode(CurrentSegmentPanStarted event,
      Emitter<CurrentSegmentState> emit) {
    _changeSelectedSegmentDependingOnNewOffset(event.firstDrawnOffset, emit);
  }

  void _onPanUpdate(CurrentSegmentPanUpdated event,
      Emitter<CurrentSegmentState> emit) {
    switch (event.mode) {
      case Mode.defaultMode:
        _onPanUpdateDefaultMode(event, emit);
        break;
      case Mode.pointMode:
        break;
      case Mode.selectionMode:
      // TODO: Handle this case.
        break;
    }
  }

  void _onPanUpdateDefaultMode(CurrentSegmentPanUpdated event,
      Emitter<CurrentSegmentState> emit) {
    if (event.currentSegment.length > 0) {
      List<Offset> path = [event.currentSegment.first.path.first, event.offset];
      List<Segment> segment = [new Segment(path, Colors.black, 5)];
      emit(CurrentPathSegmentUpdate(segment: segment, mode: Mode.defaultMode));
    }
  }

  void _onPanEnd(CurrentSegmentPanEnded event,
      Emitter<CurrentSegmentState> emit) {
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

  void _onPanEndDefaultMode(CurrentSegmentPanEnded event,
      Emitter<CurrentSegmentState> emit) {
    repository.addSegment(event.currentSegment.first);
    emit(CurrentPathSegmentUpdate(
        segment: [event.currentSegment.first], mode: Mode.defaultMode));
    emit(CurrentSegmentDelete());
    print('${repository
        .getAllSegments()
        .length} segments in repo');
  }

  void _deleteSegment(CurrentSegmentDeleted event,
      Emitter<CurrentSegmentState> emit) {
    repository.removeSegment(state.currentSegment.first);
    emit(CurrentSegmentDelete());
  }

  void _onPanDown(CurrentSegmentPanDowned event,
      Emitter<CurrentSegmentState> emit) {
    if (event.mode == Mode.selectionMode) {
      if (state.currentSegment.length > 0) {
        state.currentSegment.first
          ..color = Colors.black
          ..isSelected = false;
      }
      Segment lowestDistanceLine = getNearestSegment(event.details);
      lowestDistanceLine
        ..color = Colors.red
        ..isSelected = true;

      emit(CurrentPathSegmentUpdate(
          segment: [lowestDistanceLine], mode: Mode.selectionMode));
    }
  }

  Segment getNearestSegment(DragDownDetails details) {
    Map<Segment, double> distances = {};

    repository.getAllSegments().forEach((line) {
      distances.addEntries([MapEntry(line, getDistanceToLine(details, line))]);
    });

    var mapEntries = distances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    distances
      ..clear()
      ..addEntries(mapEntries);

    return distances.keys
        .toList()
        .first;
  }

  /*
       Distance(point1, currPoint)
     + Distance(currPoint, point2)
    == Distance(point1, point2)

    https://stackoverflow.com/questions/11907947/how-to-check-if-a-point-lies-on-a-line-between-2-other-points/11912171#11912171
  */
  double getDistanceToLine(DragDownDetails details, Segment line) {
    Point currentPoint =
    new Point(details.globalPosition.dx, details.globalPosition.dy - 80);
    Point startPoint = new Point(line.path.first.dx, line.path.first.dy);
    Point endPoint = new Point(line.path.last.dx, line.path.last.dy);

    return startPoint.distanceTo(currentPoint) +
        currentPoint.distanceTo(endPoint) -
        startPoint.distanceTo(endPoint);
  }

  void _changeMode(CurrentSegmentModeChanged event,
      Emitter<CurrentSegmentState> emit) {
    emit(CurrentPathSegmentUpdate(
        segment: state.currentSegment, mode: event.mode));
  }

  void _unselectSegment(CurrentSegmentUnselected event,
      Emitter<CurrentSegmentState> emit) {
    if (state.currentSegment.length > 0) {
      state.currentSegment.first.color = Colors.black;
      emit(CurrentPathSegmentUpdate(
          segment: state.currentSegment, mode: Mode.defaultMode));
    }
  }

  void _changeSelectedSegmentDependingOnNewOffset(Offset offset,
      Emitter<CurrentSegmentState> emit) {
    List<Offset> offsets = state.currentSegment.first.path;
    Segment segment = state.currentSegment.first;

    if (segment.selectedEdge != null) {
      if (segment.selectedEdge == segment.path.first) {
        offsets
          ..removeAt(0)
          ..insert(0, offset);
      } else {
        offsets
          ..removeLast()
          ..add(offset);
      }
      Segment newSegment = new Segment(offsets, Colors.black, 5);
      newSegment.selectedEdge = offset;
      updateSegmentPointMode(newSegment, offset, emit);
    }
  }

  void updateSegmentPointMode(Segment segment, Offset offset,
      Emitter<CurrentSegmentState> emit) {
    segment
      ..highlightPoints = true
      ..isSelected = true
      ..color = Colors.red;

    emit(CurrentPathSegmentUpdate(segment: [segment], mode: Mode.pointMode));
  }
}
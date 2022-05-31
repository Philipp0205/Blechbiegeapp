import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/bloc%20/current_path/current_segment_event.dart';
import 'package:open_bsp/bloc%20/current_path/current_segment_state.dart';
import 'package:open_bsp/data/segments_repository.dart';
import 'package:open_bsp/model/appmodes.dart';
import 'package:open_bsp/model/segment.dart';

class SegmentWidgetBloc extends Bloc<CurrentSegmentEvent, CurrentSegmentState> {
  final SegmentsRepository repository;

  SegmentWidgetBloc(this.repository)
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
  void _onPanStart(
      CurrentSegmentPanStarted event, Emitter<CurrentSegmentState> emit) {
    switch (event.mode) {
      case Mode.defaultMode:
        _onPanStartDefaultMode(event, emit);
        break;
      case Mode.pointMode:
        _onPanStartPointMode(event, emit);
        break;
      case Mode.editSegmentMode:
        // TODO: Handle this case.
        break;
      case Mode.selectionMode:
        // TODO: Handle this case.
        break;
    }
  }

  void _onPanStartDefaultMode(
      CurrentSegmentPanStarted event, Emitter<CurrentSegmentState> emit) {
    if (state.currentSegment.length > 0) {
      List<Offset> offsets = state.currentSegment.first.path;
      Offset nearestOffset = getNearestOffset(event.firstDrawnOffset, offsets);

      int indexNearestOffset = offsets.indexOf(nearestOffset);
      offsets.insert(indexNearestOffset + 1, nearestOffset);
      Segment segment = new Segment(offsets, Colors.black, 5);
      segment.selectedEdge = nearestOffset;

      emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.defaultMode));
    } else {
      Segment segment = new Segment(
          [event.firstDrawnOffset, event.firstDrawnOffset], Colors.black, 5);
      segment.selectedEdge = event.firstDrawnOffset;
      emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.defaultMode));
    }
  }

  void _onPanStartPointMode(
      CurrentSegmentPanStarted event, Emitter<CurrentSegmentState> emit) {
    print('onpanstart pointmode');
    _changeSelectedSegmentDependingOnNewOffset(event.firstDrawnOffset, emit);
  }

  void _onPanUpdate(
      CurrentSegmentPanUpdated event, Emitter<CurrentSegmentState> emit) {
    switch (event.mode) {
      case Mode.defaultMode:
        _onPanUpdateDefaultMode(event, emit);
        break;
      case Mode.pointMode:
        _onPanUpdatePointMode(event, emit);
        break;
      case Mode.selectionMode:
        // TODO: Handle this case.
        break;
      case Mode.editSegmentMode:
        // TODO: Handle this case.
        break;
    }
  }

  void _onPanUpdateDefaultMode(
      CurrentSegmentPanUpdated event, Emitter<CurrentSegmentState> emit) {
    if (state.currentSegment.first.selectedEdge != null) {
      List<Offset> path = state.currentSegment.first.path;
      int indexCurrentOffset =
          path.indexOf(state.currentSegment.first.selectedEdge!);
      path
      ..removeAt(indexCurrentOffset)
        ..insert(indexCurrentOffset, event.offset);
      Segment segment = new Segment(path, Colors.black, 5);
      segment.selectedEdge = event.offset;
      emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.defaultMode));
    }
  }

  void _onPanUpdatePointMode(
      CurrentSegmentPanUpdated event, Emitter<CurrentSegmentState> emit) {
    _changeSelectedSegmentDependingOnNewOffset(event.offset, emit);
  }

  void _onPanEnd(
      CurrentSegmentPanEnded event, Emitter<CurrentSegmentState> emit) {
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
      case Mode.editSegmentMode:
        // TODO: Handle this case.
        break;
    }
  }

  void _onPanEndDefaultMode(
      CurrentSegmentPanEnded event, Emitter<CurrentSegmentState> emit) {
    // repository.addSegment(event.currentSegment.first);
    emit(CurrentSegmentUpdate(
        segment: [event.currentSegment.first], mode: Mode.defaultMode));
    // emit(CurrentSegmentDelete());
    // print('${repository.getAllSegments().length} segments in repo');
  }

  void _deleteSegment(
      CurrentSegmentDeleted event, Emitter<CurrentSegmentState> emit) {
    repository.removeSegment(state.currentSegment.first);
    emit(CurrentSegmentDelete());
  }

  void _onPanDown(
      CurrentSegmentPanDowned event, Emitter<CurrentSegmentState> emit) {
    switch (event.mode) {
      case Mode.defaultMode:
        // TODO: Handle this case.
        break;
      case Mode.pointMode:
        _onPanDownPointMode(event, emit);
        break;
      case Mode.selectionMode:
        _onPanDownSelectionMode(event, emit);
        break;
      case Mode.editSegmentMode:
        // TODO: Handle this case.
        break;
    }
  }

  void _onPanDownSelectionMode(
      CurrentSegmentPanDowned event, Emitter<CurrentSegmentState> emit) {
    if (state.currentSegment.length > 0) {
      state.currentSegment.first
        ..color = Colors.black
        ..isSelected = false;
    }
    Segment lowestDistanceLine = getNearestSegment(event.details);
    lowestDistanceLine
      ..color = Colors.red
      ..isSelected = true;

    emit(CurrentSegmentUpdate(
        segment: [lowestDistanceLine], mode: Mode.selectionMode));
  }

  void _onPanDownPointMode(
      CurrentSegmentPanDowned event, Emitter<CurrentSegmentState> emit) {
    Point point = new Point(
        event.details.globalPosition.dx, event.details.globalPosition.dy - 80);
    _selectPoint(point, emit);
  }

  Offset getNearestOffset(Offset offset, List<Offset> offsets) {
    Map<Offset, double> distances = {};
    offsets.forEach((currentOffset) {
      distances.addEntries(
          [MapEntry(currentOffset, (currentOffset - offset).distance)]);
    });

    var mapEntries = distances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    distances
      ..clear()
      ..addEntries(mapEntries);

    return distances.keys.toList().first;
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
        new Point(details.globalPosition.dx, details.globalPosition.dy - 80);
    Point startPoint = new Point(line.path.first.dx, line.path.first.dy);
    Point endPoint = new Point(line.path.last.dx, line.path.last.dy);

    return startPoint.distanceTo(currentPoint) +
        currentPoint.distanceTo(endPoint) -
        startPoint.distanceTo(endPoint);
  }

  void _changeMode(
      CurrentSegmentModeChanged event, Emitter<CurrentSegmentState> emit) {
    emit(CurrentSegmentUpdate(segment: state.currentSegment, mode: event.mode));
  }

  void _unselectSegment(
      CurrentSegmentUnselected event, Emitter<CurrentSegmentState> emit) {
    if (state.currentSegment.length > 0) {
      state.currentSegment.first
        ..color = Colors.black
        ..isSelected = false;
      emit(CurrentSegmentUpdate(
          segment: state.currentSegment, mode: Mode.defaultMode));
    }
  }

  void _changeSelectedSegmentDependingOnNewOffset(
      Offset offset, Emitter<CurrentSegmentState> emit) {
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

  void updateSegmentPointMode(
      Segment segment, Offset offset, Emitter<CurrentSegmentState> emit) {
    segment
      ..highlightPoints = true
      ..isSelected = true
      ..color = Colors.red;

    emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.pointMode));
  }

  void _selectPoint(Point point, Emitter<CurrentSegmentState> emit) {
    print('_selectPoint');

    Segment segment = state.currentSegment.first;
    Point currentPoint = point,
        edgeA = new Point(segment.path.first.dx, segment.path.first.dy),
        edgeB = new Point(segment.path.last.dx, segment.path.last.dy);

    double threshold = 100,
        distanceToA = currentPoint.distanceTo(edgeA),
        distanceToB = currentPoint.distanceTo(edgeB);

    if (distanceToA < distanceToB && distanceToA < threshold) {
      print('segment: ${segment.path}');
      segment.selectedEdge = new Offset(edgeA.x.toDouble(), edgeA.y.toDouble());
      emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.pointMode));
    } else if (distanceToB < distanceToA && distanceToB < threshold) {
      print('segment: ${segment.path}');
      segment.selectedEdge = new Offset(edgeB.x.toDouble(), edgeB.y.toDouble());
      emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.pointMode));
    } else {}
  }
}

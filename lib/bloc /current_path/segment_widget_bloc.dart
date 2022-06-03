import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/bloc%20/all_paths/all_segments_bloc.dart';
import 'package:open_bsp/bloc%20/current_path/current_segment_event.dart';
import 'package:open_bsp/bloc%20/current_path/current_segment_state.dart';
import 'package:open_bsp/bloc%20/current_path/geomettric_calculations_service.dart';
import 'package:open_bsp/data/segments_repository.dart';
import 'package:open_bsp/model/appmodes.dart';
import 'package:open_bsp/model/segment.dart';

import 'geomettric_calculations_service.dart';

class SegmentWidgetBloc extends Bloc<SegmentWidgetEvent, CurrentSegmentState> {
  final SegmentsRepository repository;
  GeometricCalculationsService _calculationService =
      new GeometricCalculationsService();

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
    on<SegmentDeleted>(_deleteSegment);
    on<SegmentPartDeleted>(_deleteSegmentPart);
    on<SegmentPartLengthChanged>(_changeSegmentPartLength);
    on<CurrentSegmentUnselected>(_unselectSegment);
    on<SegmentPartAngleChanged>(_changeSegmentAngle);
  }

  /// Similar to [GestureDetector]: 'Triggered when a pointer has contacted the
  /// screen with a primary button and has begun to move.'
  ///
  /// Depending on the App's [Mode] the behavior is different.
  void _onPanStart(
      CurrentSegmentPanStarted event, Emitter<CurrentSegmentState> emit) {
    switch (event.mode) {
      case Mode.defaultMode:
        state.currentSegment.isEmpty
            ? _onPanStartDefaultInitial(event, emit)
            : _onPanStartDefault(event, emit);
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

  /// Similar to [GestureDetector]: 'A pointer that is in contact with the
  /// screen with a primary button and moving has moved again.'
  ///
  /// Depending on the App's [Mode] the behavior is different.
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

  /// Creates initial segment if now segment was drawn on the screen before.
  void _onPanStartDefaultInitial(
      CurrentSegmentPanStarted event, Emitter<CurrentSegmentState> emit) {
    Segment segment = new Segment(
        [event.firstDrawnOffset, event.firstDrawnOffset], Colors.black, 5);
    segment.selectedEdge = event.firstDrawnOffset;
    emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.defaultMode));
  }

  /// Extends segment starting from the nearest offset from pointer.
  void _onPanStartDefault(
      CurrentSegmentPanStarted event, Emitter<CurrentSegmentState> emit) {
    List<Offset> path = state.currentSegment.first.path;
    path.add(event.firstDrawnOffset);
    Segment segment = new Segment(path, Colors.black, 5);
  }

  void _onPanStartPointMode(
      CurrentSegmentPanStarted event, Emitter<CurrentSegmentState> emit) {
    print('onpanstart pointmode');
    // _changeSelectedSegmentDependingOnNewOffset(event.firstDrawnOffset, emit);
  }

  void _onPanUpdateDefaultMode(
      CurrentSegmentPanUpdated event, Emitter<CurrentSegmentState> emit) {
    List<Offset> path = state.currentSegment.first.path;

    int indexOfSelectedPoint = state.currentSegment.first.indexOfSelectedPoint;

    path
      ..removeLast()
      ..add(event.offset);
    Segment segment = new Segment(path, Colors.black, 5);
    segment.indexOfSelectedPoint = indexOfSelectedPoint;
    emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.defaultMode));
  }

  void _onPanUpdatePointMode(
      CurrentSegmentPanUpdated event, Emitter<CurrentSegmentState> emit) {
    // _changeSelectedSegmentDependingOnNewOffset(event.offset, emit);
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

  void _deleteSegment(SegmentDeleted event, Emitter<CurrentSegmentState> emit) {
    emit(CurrentSegmentDelete());
  }

  void _deleteSegmentPart(
      SegmentPartDeleted event, Emitter<CurrentSegmentState> emit) {
    List<Offset> path = state.currentSegment.first.path;
    List<Offset> selectedPoints = state.currentSegment.first.selectedOffsets;

    path.remove(selectedPoints.last);
    selectedPoints.removeLast();

    Segment segment = new Segment(path, Colors.black, 5);
    segment.selectedOffsets = selectedPoints;
    emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.selectionMode));
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
    Offset offset = new Offset(
        event.details.globalPosition.dx, event.details.globalPosition.dy - 100);
    Offset nearestOffset = _calculationService
        .getNNearestOffsets(offset, state.currentSegment.first.path, 1)
        .first;

    List<Offset> path = state.currentSegment.first.path;
    List<Offset> highlightedPoints = state.currentSegment.first.selectedOffsets;

    int index = path.indexOf(nearestOffset);

    // TODO schlechter Code.
    if (highlightedPoints.contains(nearestOffset)) {
      print('highlichted points container nearest offset ... ');
      highlightedPoints.remove(nearestOffset);
    } else if (highlightedPoints.isNotEmpty && highlightedPoints.length <= 2) {
      print('points.length = ${highlightedPoints.length}');
      if (nearestOffset == path.last) {
        print('nearest offset ist last');
        if (highlightedPoints.contains(path[index - 1])) {
          highlightedPoints.add(nearestOffset);
        }
      } else if (nearestOffset == path.first) {
        print('nearest offset ist first');
        if (highlightedPoints.contains(path[index + 1])) {
          highlightedPoints.add(nearestOffset);
        }
      } else {
        print('nearest offset is neither');
        if (highlightedPoints.contains(path[index + 1]) ||
            highlightedPoints.contains(path[index - 1])) {
          highlightedPoints.add(nearestOffset);
        }
      }
    } else if (highlightedPoints.length == 0) {
      print('firest selected offset');
      highlightedPoints.add(nearestOffset);
    }

    if (highlightedPoints.length == 2) {
      double angle = _calculationService.getAngle(
          highlightedPoints.first, highlightedPoints.last);
      print('angle between ${highlightedPoints.first} and '
          '${highlightedPoints.last} is $angle');
    }

    // if (nearestOffset != path.last) {
    //   highlightedPoints = [
    //     nearestOffset,
    //     path[path.indexOf(nearestOffset) + 1]
    //   ];
    // }

    Segment segment = new Segment(path, Colors.black, 5);
    segment.selectedOffsets = highlightedPoints;

    emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.selectionMode));
  }

  void _onPanDownPointMode(
      CurrentSegmentPanDowned event, Emitter<CurrentSegmentState> emit) {
    Point point = new Point(
        event.details.globalPosition.dx, event.details.globalPosition.dy - 80);
    _selectPoint(point, emit);
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

  void _changeSegmentPartLength(
      SegmentPartLengthChanged event, Emitter<CurrentSegmentState> emit) {
    List<Offset> path = state.currentSegment.first.path;
    List<Offset> offsets = state.currentSegment.first.selectedOffsets;
    int indexInPath = path.indexOf(offsets.last);
    double currentLength =
        (offsets[offsets.length - 2] - offsets.last).distance;

    Offset offset = _calculationService.extendSegment(
        [offsets[offsets.length - 2], offsets.last],
        (event.length - currentLength));

    path
      ..removeAt(indexInPath)
      ..insert(indexInPath, offset);

    Segment segment = new Segment(path, Colors.black, 5);
    offsets
      ..removeLast()
      ..add(offset);

    segment.selectedOffsets = offsets;
    emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.selectionMode));
  }

  void _changeSegmentAngle(
      SegmentPartAngleChanged event, Emitter<CurrentSegmentState> emit) {
    print('changeSegmentAngle');

    List<Offset> path = state.currentSegment.first.path;
    List<Offset> offsets = state.currentSegment.first.selectedOffsets;

    Offset newOffset = _calculationService.calculatePointWithAngle(
        offsets.first, event.length, event.angle);

    int index = path.indexOf(offsets.last);
    path
      ..removeAt(index)
      ..insert(index, newOffset);
    offsets
      ..removeLast()
      ..add(newOffset);

    Segment segment = new Segment(path, Colors.black, 5);
    segment.selectedOffsets = offsets;
    emit(CurrentSegmentUpdate(segment: [segment], mode: Mode.selectionMode));
  }
}

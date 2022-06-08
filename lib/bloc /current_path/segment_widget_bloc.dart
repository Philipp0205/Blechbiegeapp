import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/bloc%20/current_path/current_segment_event.dart';
import 'package:open_bsp/bloc%20/current_path/current_segment_state.dart';
import 'package:open_bsp/bloc%20/current_path/geometric_calculations_service.dart';
import 'package:open_bsp/data/segments_repository.dart';
import 'package:open_bsp/model/appmodes.dart';
import 'package:open_bsp/model/segment_model.dart';
import 'package:open_bsp/model/segment_offset.dart';

import '../../model/segment2.dart';
import 'geometric_calculations_service.dart';

class SegmentWidgetBloc extends Bloc<SegmentWidgetEvent, CurrentSegmentState> {
  final SegmentsRepository repository;
  GeometricCalculationsService _calculationService =
      new GeometricCalculationsService();

  SegmentWidgetBloc(this.repository)
      : super(CurrentSegmentInitial(segment: [], mode: Mode.defaultMode)) {
    /// Pan Events
    on<CurrentSegmentPanStarted>(_onPanStart);
    on<CurrentSegmentPanUpdated>(_onPanUpdate);
    on<CurrentSegmentPanEnded>(_onPanEnd);
    on<CurrentSegmentPanDowned>(_onPanDown);

    /// Events for mode editing the segment
    on<CurrentSegmentModeChanged>(_changeMode);
    on<SegmentDeleted>(_deleteSegment);
    on<SegmentPartDeleted>(_deleteSegmentPart);
    on<SegmentPartLengthChanged>(_changeSegmentPartLength);
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
        state.segment.isEmpty
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

  /// Creates segment if now segment was drawn on the screen before.
  void _onPanStartDefaultInitial(
      CurrentSegmentPanStarted event, Emitter<CurrentSegmentState> emit) {
    SegmentOffset offset = new SegmentOffset(offset: event.firstDrawnOffset);
    Segment2 segment2 =
        new Segment2(path: [offset, offset], width: 5, color: Colors.black);

    Segment segment = new Segment(
        [event.firstDrawnOffset, event.firstDrawnOffset], Colors.black, 5);
    segment.selectedEdge = event.firstDrawnOffset;
    emit(CurrentSegmentUpdate(segment: [segment2], mode: Mode.defaultMode));
  }

  /// Extends segment starting from the nearest offset from pointer.
  void _onPanStartDefault(
      CurrentSegmentPanStarted event, Emitter<CurrentSegmentState> emit) {
    List<SegmentOffset> path2 = state.segment.first.path;
    path2.add(new SegmentOffset(offset: event.firstDrawnOffset));

    emit(CurrentSegmentUpdate(
        segment: [state.segment.first.copyWith(path2)],
        mode: Mode.defaultMode));
  }

  void _onPanStartPointMode(
      CurrentSegmentPanStarted event, Emitter<CurrentSegmentState> emit) {}

  void _onPanUpdateDefaultMode(
      CurrentSegmentPanUpdated event, Emitter<CurrentSegmentState> emit) {
    List<SegmentOffset> path2 = state.segment.first.path;

    path2
      ..removeLast()
      ..add(new SegmentOffset(offset: event.offset));

    emit(CurrentSegmentUpdate(
        segment: [event.segment.copyWith(path2)], mode: Mode.defaultMode));
  }

  void _onPanUpdatePointMode(
      CurrentSegmentPanUpdated event, Emitter<CurrentSegmentState> emit) {}

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
    emit(CurrentSegmentUpdate(
        segment: [event.segment2], mode: Mode.defaultMode));
  }

  void _deleteSegment(SegmentDeleted event, Emitter<CurrentSegmentState> emit) {
    emit(CurrentSegmentDelete());
  }

  /// Deletes a part of a [Segment2]. To make a delete happen at least two
  /// offsets in a segment have to be selected.
  void _deleteSegmentPart(
      SegmentPartDeleted event, Emitter<CurrentSegmentState> emit) {
    List<SegmentOffset> offsets = state.segment.first.path;
    offsets.removeLast();

    emit(CurrentSegmentUpdate(
        segment: [state.segment.first.copyWith(offsets)],
        mode: Mode.selectionMode));
  }

  /// Different actions on pan down depending on the mode.
  /// If the selection mode is selected the user can select one ore more
  /// offsets of the segment.
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

  /// Similar to onPanDown in [GestureDetector]: 'A pointer has contacted the
  /// screen with a primary button and might begin to move.'
  ///
  /// In selection mode the nearest point of the segment gets added (or removed)
  /// from the selectedOffsets of a [Segment].
  void _onPanDownSelectionMode(
      CurrentSegmentPanDowned event, Emitter<CurrentSegmentState> emit) {
    Offset panDownOffset = new Offset(
        event.details.globalPosition.dx, event.details.globalPosition.dy - 100);

    List<SegmentOffset> path = state.segment.first.path;
    List<Offset> offsets = path.map((e) => e.offset).toList();
    Offset nearestOffset =
        _calculationService.getNNearestOffsets(panDownOffset, offsets, 1).first;

    path.forEach((segmentOffset) {
      if (segmentOffset.offset == nearestOffset) {
        segmentOffset.isSelected
            ? segmentOffset.isSelected = false
            : segmentOffset.isSelected = true;
      }
    });

    emit(CurrentSegmentUpdate(
        segment: [state.segment.first.copyWith(path)],
        mode: Mode.selectionMode));
  }

  void _onPanDownPointMode(
      CurrentSegmentPanDowned event, Emitter<CurrentSegmentState> emit) {
    Point point = new Point(
        event.details.globalPosition.dx, event.details.globalPosition.dy - 80);
    _selectOffset(point, emit);
  }

  void _changeMode(
      CurrentSegmentModeChanged event, Emitter<CurrentSegmentState> emit) {
    emit(
        CurrentSegmentUpdate(segment: [state.segment.first], mode: event.mode));
  }

  /// Selects nearest [Offset] of the [Segment] depending on the
  /// coordinates of [point].
  void _selectOffset(Point point, Emitter<CurrentSegmentState> emit) {
    // Point currentPoint = point,
    //
    // double threshold = 100,
    //     distanceToA = currentPoint.distanceTo(edgeA),
    //     distanceToB = currentPoint.distanceTo(edgeB);
    //
    // if (distanceToA < distanceToB && distanceToA < threshold) {
    //   print('segment: ${segment.path}');
    //   segment.selectedEdge = new Offset(edgeA.x.toDouble(), edgeA.y.toDouble());
    //   emit(CurrentSegmentUpdate(
    //       segment: [segment], segment2: state.segment2!, mode: Mode.pointMode));
    // } else if (distanceToB < distanceToA && distanceToB < threshold) {
    //   print('segment: ${segment.path}');
    //   segment.selectedEdge = new Offset(edgeB.x.toDouble(), edgeB.y.toDouble());
    //   emit(CurrentSegmentUpdate(
    //       segment: [segment], segment2: state.segment2!, mode: Mode.pointMode));
    // } else {}
  }

  /// Changes the length of a part of a segment.
  /// At lest two [selectedOffsets] in a [Segment] have to be present for a
  /// length change.
  void _changeSegmentPartLength(
      SegmentPartLengthChanged event, Emitter<CurrentSegmentState> emit) {
    print('changeSegmentPartLength');
    List<SegmentOffset> path = state.segment.first.path;

    List<SegmentOffset> selected =
        path.where((element) => element.isSelected).toList();

    double currentLength =
        (selected.first.offset - selected.last.offset).distance;

    Offset offset2 = _calculationService.extendSegment(
        selected.map((e) => e.offset).toList(), event.length - currentLength);

    SegmentOffset segmentOffset = new SegmentOffset(offset: offset2);
    segmentOffset.isSelected = true;

    int index = path.indexOf(selected.last);
    path
      ..remove(selected.last)
      ..insert(index, segmentOffset);

    emit(CurrentSegmentUpdate(
        segment: [state.segment.first.copyWith(path)],
        mode: Mode.selectionMode));
  }

  /// Changes the angle of a part of a [Segment].
  /// The segment has to have at least two [selectedOffsets] to
  /// change the angle.
  void _changeSegmentAngle(
      SegmentPartAngleChanged event, Emitter<CurrentSegmentState> emit) {
    print('changeSegmentAngle');

    List<SegmentOffset> path = state.segment.first.path;

    List<SegmentOffset> selectedOffsets =
        path.where((o) => o.isSelected).toList();

    List<Offset> offsets = selectedOffsets.map((e) => e.offset).toList();

    Offset newOffset = _calculationService.calculatePointWithAngle(
        offsets.first, event.length, event.angle);

    SegmentOffset segmentOffset = new SegmentOffset(offset: newOffset);
    segmentOffset.isSelected = true;

    int index = path.indexOf(selectedOffsets.last);
    path
      ..remove(selectedOffsets.last)
      ..insert(index, segmentOffset);

    emit(CurrentSegmentUpdate(
        segment: [state.segment.first.copyWith(path)],
        mode: Mode.selectionMode));
  }
}

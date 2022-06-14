import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/bloc%20/segment_widget/current_segment_event.dart';
import 'package:open_bsp/bloc%20/segment_widget/current_segment_state.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';
import 'package:open_bsp/model/appmodes.dart';
import 'package:open_bsp/model/segment_offset.dart';

import '../../model/segment.dart';
import '../../services/geometric_calculations_service.dart';

class SegmentWidgetBloc extends Bloc<SegmentWidgetEvent, SegmentWidgetBlocState> {
  GeometricCalculationsService _calculationService =
      new GeometricCalculationsService();

  SegmentWidgetBloc()
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
      CurrentSegmentPanStarted event, Emitter<SegmentWidgetBlocState> emit) {
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
      CurrentSegmentPanUpdated event, Emitter<SegmentWidgetBlocState> emit) {
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
      CurrentSegmentPanStarted event, Emitter<SegmentWidgetBlocState> emit) {
    SegmentOffset offset =
        new SegmentOffset(offset: event.firstDrawnOffset, isSelected: false);
    Segment segment2 =
        new Segment(path: [offset, offset], width: 5, color: Colors.black);


    emit(CurrentSegmentUpdate(segment: [segment2], mode: Mode.defaultMode));
  }

  /// Extends segment starting from the nearest offset from pointer.
  void _onPanStartDefault(
      CurrentSegmentPanStarted event, Emitter<SegmentWidgetBlocState> emit) {
    List<SegmentOffset> path2 = state.segment.first.path;
    path2.add(
        new SegmentOffset(offset: event.firstDrawnOffset, isSelected: false));

    emit(CurrentSegmentUpdate(
        segment: [state.segment.first.copyWith(path: path2)],
        mode: Mode.defaultMode));
  }

  void _onPanStartPointMode(
      CurrentSegmentPanStarted event, Emitter<SegmentWidgetBlocState> emit) {}

  void _onPanUpdateDefaultMode(
      CurrentSegmentPanUpdated event, Emitter<SegmentWidgetBlocState> emit) {
    List<SegmentOffset> path2 = state.segment.first.path;

    path2
      ..removeLast()
      ..add(new SegmentOffset(offset: event.offset, isSelected: false));

    emit(CurrentSegmentUpdate(
        segment: [event.segment.copyWith(path: path2)], mode: Mode.defaultMode));
  }

  void _onPanUpdatePointMode(
      CurrentSegmentPanUpdated event, Emitter<SegmentWidgetBlocState> emit) {}

  void _onPanEnd(
      CurrentSegmentPanEnded event, Emitter<SegmentWidgetBlocState> emit) {
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
      CurrentSegmentPanEnded event, Emitter<SegmentWidgetBlocState> emit) {
    emit(CurrentSegmentUpdate(
        segment: [event.segment2], mode: Mode.defaultMode));
  }

  void _deleteSegment(SegmentDeleted event, Emitter<SegmentWidgetBlocState> emit) {
    emit(CurrentSegmentDelete());
  }

  /// Deletes a part of a [Segment]. To make a delete happen at least two
  /// offsets in a segment have to be selected.
  void _deleteSegmentPart(
      SegmentPartDeleted event, Emitter<SegmentWidgetBlocState> emit) {
    List<SegmentOffset> offsets = state.segment.first.path;
    offsets.removeLast();

    emit(CurrentSegmentUpdate(
        segment: [state.segment.first.copyWith(path: offsets)],
        mode: Mode.selectionMode));
  }

  /// Different actions on pan down depending on the mode.
  /// If the selection mode is selected the user can select one ore more
  /// offsets of the segment.
  void _onPanDown(
      CurrentSegmentPanDowned event, Emitter<SegmentWidgetBlocState> emit) {
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
      CurrentSegmentPanDowned event, Emitter<SegmentWidgetBlocState> emit) {
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
        segment: [state.segment.first.copyWith(path: path)],
        mode: Mode.selectionMode));
  }

  void _onPanDownPointMode(
      CurrentSegmentPanDowned event, Emitter<SegmentWidgetBlocState> emit) {
    Point point = new Point(
        event.details.globalPosition.dx, event.details.globalPosition.dy - 80);
  }

  void _changeMode(
      CurrentSegmentModeChanged event, Emitter<SegmentWidgetBlocState> emit) {
    emit(
        CurrentSegmentUpdate(segment: [state.segment.first], mode: event.mode));

  }

  /// Changes the length of a part of a segment.
  /// At lest two [selectedOffsets] in a [Segment] have to be present for a
  /// length change.
  void _changeSegmentPartLength(
      SegmentPartLengthChanged event, Emitter<SegmentWidgetBlocState> emit) {
    print('changeSegmentPartLength');
    List<SegmentOffset> path = state.segment.first.path;

    List<SegmentOffset> selected =
        path.where((element) => element.isSelected).toList();

    double currentLength =
        (selected.first.offset - selected.last.offset).distance;

    Offset offset2 = _calculationService.extendSegment(
        selected.map((e) => e.offset).toList(), event.length - currentLength);

    int index = path.indexOf(selected.last);

    path
      ..remove(selected.last)
      ..insert(index, selected.last.copyWith(offset: offset2));

    emit(CurrentSegmentUpdate(
        segment: [state.segment.first.copyWith(path: path)],
        mode: Mode.selectionMode));
  }

  /// Changes the angle of a part of a [Segment].
  /// The segment has to have at least two [selectedOffsets] to
  /// change the angle.
  void _changeSegmentAngle(
      SegmentPartAngleChanged event, Emitter<SegmentWidgetBlocState> emit) {
    print('changeSegmentAngle');

    List<SegmentOffset> path = state.segment.first.path;

    List<SegmentOffset> selectedOffsets =
        path.where((o) => o.isSelected).toList();

    List<Offset> offsets = selectedOffsets.map((e) => e.offset).toList();

    Offset newOffset = _calculationService.calculatePointWithAngle(
        offsets.first, event.length, event.angle);

    int index = path.indexOf(selectedOffsets.last);
    path
      ..remove(selectedOffsets.last)
      ..insert(index, selectedOffsets.last.copyWith(offset: newOffset));

    emit(CurrentSegmentUpdate(
        segment: [state.segment.first.copyWith(path: path)],
        mode: Mode.selectionMode));
  }
}

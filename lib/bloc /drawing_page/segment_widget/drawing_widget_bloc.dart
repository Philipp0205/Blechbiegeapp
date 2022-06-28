import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/bloc%20/drawing_page/segment_widget/drawing_widget_event.dart';
import 'package:open_bsp/bloc%20/drawing_page/segment_widget/drawing_widget_state.dart';
import 'package:open_bsp/model/Line2.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';
import 'package:open_bsp/model/appmodes.dart';
import 'package:open_bsp/model/segment_offset.dart';

import '../../../model/segment_widget/segment.dart';
import '../../../services/geometric_calculations_service.dart';

///
class DrawingWidgetBloc extends Bloc<DrawingWidgetEvent, DrawingWidgetState> {
  GeometricCalculationsService _calculationService =
      new GeometricCalculationsService();

  DrawingWidgetBloc()
      : super(CurrentSegmentInitial(
            segment: [],
            mode: Mode.defaultMode,
            lines: [
              new Line2(start: new Offset(0, 0), end: new Offset(0, 0))
            ])) {
    /// Pan Events
    on<CurrentSegmentPanDowned>(_onPanDown);

    /// New Pan Events
    on<LineDrawingStarted>(_createNewLine);
    on<LineDrawingUpdated>(_updateLine);
    on<LineDrawingPanDown>(_selectLine);

    /// Events for mode editing the segment
    on<CurrentSegmentModeChanged>(_changeMode);
    on<SegmentDeleted>(_deleteSegment);
    on<SegmentPartDeleted>(_deleteSegmentPart);
    on<SegmentPartLengthChanged>(_changeSegmentPartLength);
    on<SegmentPartAngleChanged>(_changeSegmentAngle);
  }

  void _deleteSegment(SegmentDeleted event, Emitter<DrawingWidgetState> emit) {
    emit(CurrentSegmentDelete());
  }

  /// Deletes a part of a [Segment]. To make a delete happen at least two
  /// offsets in a segment have to be selected.
  void _deleteSegmentPart(
      SegmentPartDeleted event, Emitter<DrawingWidgetState> emit) {
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
      CurrentSegmentPanDowned event, Emitter<DrawingWidgetState> emit) {
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
      CurrentSegmentPanDowned event, Emitter<DrawingWidgetState> emit) {
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
      CurrentSegmentPanDowned event, Emitter<DrawingWidgetState> emit) {
    Point point = new Point(
        event.details.globalPosition.dx, event.details.globalPosition.dy - 80);
  }

  void _changeMode(
      CurrentSegmentModeChanged event, Emitter<DrawingWidgetState> emit) {
    emit(
        CurrentSegmentUpdate(segment: [state.segment.first], mode: event.mode));
  }

  /// Changes the length of a part of a segment.
  /// At lest two [selectedOffsets] in a [Segment] have to be present for a
  /// length change.
  void _changeSegmentPartLength(
      SegmentPartLengthChanged event, Emitter<DrawingWidgetState> emit) {
    print('changeSegmentPartLength');
    List<SegmentOffset> path = state.segment.first.path;

    List<SegmentOffset> selected =
        path.where((element) => element.isSelected).toList();

    double currentLength =
        (selected.first.offset - selected.last.offset).distance;

    Offset offset2 = _calculationService
        .changeLengthOfSegment(selected.first.offset, selected.last.offset,
            event.length - currentLength, true, false)
        .first;

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
      SegmentPartAngleChanged event, Emitter<DrawingWidgetState> emit) {
    List<SegmentOffset> path = state.segment.first.path;
    List<SegmentOffset> selectedSegmentOffsets =
        path.where((offset) => offset.isSelected).toList();

    List<Offset> selectedOffsets =
        selectedSegmentOffsets.map((e) => e.offset).toList();

    double newAngle = 0;

    if (selectedOffsets.first == path.first.offset) {
      newAngle = event.angle;
    } else {
      int i = path.indexOf(selectedSegmentOffsets.first);
      double prevAngle = 0;

      prevAngle =
          _calculationService.getAngle(path[i - 1].offset, path[i].offset);

      newAngle = prevAngle + event.angle;
    }

    Offset newOffset = _calculationService.calculatePointWithAngle(
        selectedOffsets.first, event.length, newAngle);

    int index = path.indexOf(selectedSegmentOffsets.last);
    path
      ..remove(selectedSegmentOffsets.last)
      ..insert(index, selectedSegmentOffsets.last.copyWith(offset: newOffset));

    emit(CurrentSegmentUpdate(
        segment: [state.segment.first.copyWith(path: path)],
        mode: Mode.selectionMode));
  }

  /// When the user start dragging the finger over the screen a new [Line2]
  /// gets created.
  ///
  /// Similar to [GestureDetector]: 'Triggered when a pointer has contacted the
  /// screen with a primary button and has begun to move.'
  void _createNewLine(
      LineDrawingStarted event, Emitter<DrawingWidgetState> emit) {
    if (state.mode == Mode.defaultMode) {
      List<Line2> lines = state.lines;

      Line2 line =
          new Line2(start: event.firstDrawnOffset, end: event.firstDrawnOffset);

      if (lines.isNotEmpty) line = line.copyWith(start: lines.last.end);

      lines.add(line);
      emit(LineUpdate(lines: lines));
    }
  }

  /// The line that is currently drawn gets update. The user drags the finger
  /// across the screen.
  ///
  /// Similar to [GestureDetector]: 'A pointer that is in contact with the
  /// screen with a primary button and moving has moved again.'
  void _updateLine(LineDrawingUpdated event, Emitter<DrawingWidgetState> emit) {
    if (state.mode == Mode.defaultMode) {
      List<Line2> lines = state.lines;
      lines.last = lines.last.copyWith(end: event.updatedOffset);

      emit(LineUpdate(lines: lines));
    }
  }

  void _selectLine(LineDrawingPanDown event, Emitter<DrawingWidgetState> emit) {
    if (state.mode == Mode.selectionMode) {
      List<Line2> lines = state.lines;
      List<Offset> offsets = lines.map((e) => e.start).toList();
      List<Offset> ends = lines.map((e) => e.end).toList();

      offsets.addAll(ends);

      Offset nearestOffset = _calculationService
          .getNNearestOffsets(event.panDownOffset, offsets, 1)
          .first;

      Line2 selectedLine = lines.firstWhere((element) =>
          element.start == nearestOffset || element.end == nearestOffset);
      int index = lines.indexOf(selectedLine);
      selectedLine = selectedLine.copyWith(color: Colors.red);

      lines
        ..removeAt(index)
        ..insert(index, selectedLine);
    }
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/drawing/bloc/drawing_widget/bloc/drawing_widget_event.dart';
import 'package:open_bsp/drawing/bloc/drawing_widget/bloc/drawing_widget_state.dart';
import 'package:open_bsp/model/line.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';
import 'package:open_bsp/model/appmodes.dart';

import '../../../../model/segment_widget/segment.dart';

///
class DrawingWidgetBloc extends Bloc<DrawingWidgetEvent, DrawingWidgetState> {
  GeometricCalculationsService _calculationService =
      new GeometricCalculationsService();

  DrawingWidgetBloc()
      : super(CurrentSegmentInitial(
          lines: [],
          selectedLines: [],
          linesBeforeUndo: [],
          mode: Mode.defaultMode,
          selectionMode: false,
          currentAngle: 0,
          currentLength: 0,
        )) {
    /// New Pan Events
    on<LineDrawingStarted>(_addNewLine);
    on<LineDrawingUpdated>(_updateLine);
    on<LineDrawingPanDown>(_selectLine);
    on<LinesDeleted>(_deleteLines);

    /// Selected line changes
    on<LineDrawingInnerAngleChanged>(_changeLineInnerAngle);
    on<LineDrawingAngleChanged>(_changeAngle);
    on<LineDrawingLengthChanged>(_changeLineLength);

    on<LineDrawingSelectionModeSelected>(_toggleSelectionMode);

    /// Events for mode editing the segment
    on<CurrentSegmentModeChanged>(_changeMode);
    on<LineDrawingUndo>(_undo);
    on<LineDrawingRedo>(_redo);
    on<LinesReplaced>(_onReplaceLines);
  }

  void _deleteLines(LinesDeleted event, Emitter<DrawingWidgetState> emit) {
    print('delete lines');
    emit(state.copyWith(lines: []));
  }

  void _changeMode(
      CurrentSegmentModeChanged event, Emitter<DrawingWidgetState> emit) {
    // emit(
    //     CurrentSegmentUpdate(segment: [state.segment.first], mode: event.mode));
  }

  /// Changes the length of a part of a segment.
  /// At lest two [selectedOffsets] in a [Segment] have to be present for a
  /// length change.
  void _changeLineLength(
      LineDrawingLengthChanged event, Emitter<DrawingWidgetState> emit) {
    print('changeSegmentPartLength');

    List<Line> lines = state.lines;
    Line selectedLine = lines.where((line) => line.isSelected).toList().last;

    double currentLength = (selectedLine.start - selectedLine.end).distance;

    Offset offset2 = _calculationService
        .changeLengthOfSegment(selectedLine.start, selectedLine.end,
            event.length - currentLength, true, false)
        .first;

    Line newSelectedLine = selectedLine.copyWith(end: offset2);

    int index = lines.indexOf(selectedLine);

    lines
      ..insert(index, newSelectedLine)
      ..remove(selectedLine);

    if (lines.length > index + 1) {
      Line nextLine = lines[index + 1];
      Line newNextLine = nextLine.copyWith(start: offset2);

      lines
        ..insert(index + 1, newNextLine)
        ..remove(nextLine);
    }

    emit(state.copyWith(lines: []));
    emit(state.copyWith(lines: lines));
  }

  /// Changes the angle of a part of a [Segment].
  /// The segment has to have at least two [selectedOffsets] to
  /// change the angle.
  void _changeLineInnerAngle(
      LineDrawingInnerAngleChanged event, Emitter<DrawingWidgetState> emit) {
    List<Line> lines = state.lines;
    List<Line> selectedLines = state.selectedLines;

    int index = lines.indexOf(selectedLines.last);

    double angleOfFirstLine = _calculationService.getAngle(
        selectedLines.first.start, selectedLines.first.end);

    double newAngle = angleOfFirstLine + event.angle;
    print('newAngle: $newAngle');

    Offset newOffset = _calculationService.calculatePointWithAngle(
        selectedLines.last.start, event.length, newAngle);

    Line newLine = selectedLines.last.copyWith(end: newOffset);

    selectedLines
      ..remove(selectedLines.last)
      ..add(newLine);

    lines
      ..removeAt(index)
      ..insert(index, newLine);

    emit(state.copyWith(lines: []));
    emit(state.copyWith(lines: lines));
  }

  /// When the user start dragging the finger over the screen a new [Line]
  /// gets created.
  ///
  /// Similar to [GestureDetector]: 'Triggered when a pointer has contacted the
  /// screen with a primary button and has begun to move.'
  void _addNewLine(LineDrawingStarted event, Emitter<DrawingWidgetState> emit) {
    if (state.selectionMode == false) {
      List<Line> lines = state.lines;

      Line line = new Line(
        start: event.firstDrawnOffset,
        end: event.firstDrawnOffset,
        isSelected: false,
      );

      if (lines.isNotEmpty) line = line.copyWith(start: lines.last.end);

      lines.add(line);
      emit(state.copyWith(lines: lines, linesBeforeUndo: lines));
    }
  }

  /// The line that is currently drawn gets update. The user drags the finger
  /// across the screen.
  ///
  /// Similar to [GestureDetector]: 'A pointer that is in contact with the
  /// screen with a primary button and moving has moved again.'
  void _updateLine(LineDrawingUpdated event, Emitter<DrawingWidgetState> emit) {
    if (state.selectionMode == false) {
      List<Line> lines = state.lines;
      lines.last = lines.last.copyWith(end: event.updatedOffset);

      /// A bit of  a work around. For some reason no state update is registered
      /// if only a value of the list changes.
      emit(state.copyWith(lines: []));
      emit(state.copyWith(lines: lines));
    }
  }

  /// Selects the line nearest to the selected offset.
  void _selectLine(LineDrawingPanDown event, Emitter<DrawingWidgetState> emit) {
    // Check if selection Mode (Checkbox) is active.
    if (state.selectionMode == false) {
      return;
    }

    List<Line> lines = state.lines;
    List<Line> selectedLines = state.selectedLines;

    /// Unselect previous selected lines.
    selectedLines.forEach((line) {
      line.isSelected = false;
    });

    List<Offset> middlePoints = lines
        .map((line) => _calculationService.getMiddle(line.start, line.end))
        .toList();

    List<Offset> nearestMiddlePoint = _calculationService.getNNearestOffsets(
        event.panDownOffset, middlePoints, 1);

    int index = middlePoints.indexOf(nearestMiddlePoint.first);
    Line selectedLine = lines[index];

    selectedLine = _toggleLineSelection(selectedLine);

    lines
      ..removeAt(index)
      ..insert(index, selectedLine);

    selectedLines = lines.where((line) => line.isSelected).toList();

    double angle =
        _calculationService.getAngle(selectedLine.start, selectedLine.end);

    double length = (selectedLine.start - selectedLine.end).distance;

    emit(state.copyWith(lines: [], selectedLines: []));
    emit(state.copyWith(
        lines: lines, selectedLines: selectedLines, currentAngle: angle, currentLength: length));
  }

  Line _toggleLineSelection(Line line) {
    return line.copyWith(isSelected: !line.isSelected);
  }

  /// Changes the selection mode
  void _toggleSelectionMode(LineDrawingSelectionModeSelected event,
      Emitter<DrawingWidgetState> emit) {
    emit(state.copyWith(selectionMode: event.selectionMode));
  }

  /// Undo option.
  /// Removes the last drawn line.
  void _undo(LineDrawingUndo event, Emitter<DrawingWidgetState> emit) {
    print('undo');
    List<Line> lines = state.lines;
    List<Line> linesBeforeUndo = state.lines;
    lines.removeLast();

    emit(state.copyWith(lines: [], linesBeforeUndo: []));
    emit(state.copyWith(lines: lines, linesBeforeUndo: linesBeforeUndo));
  }

  /// Redo option.
  /// Adds the last removed line again.
  void _redo(LineDrawingRedo event, Emitter<DrawingWidgetState> emit) {
    List<Line> history = state.linesBeforeUndo;
    List<Line> lines = state.lines;

    int index = lines.indexOf(lines.last);

    if (history.length > index) {
      print('redo possible history: ${history.length}, liens: ${lines.length}');
      print('index $index');
      lines.add(history[index + 1]);
    }

    emit(state.copyWith(lines: []));
    emit(state.copyWith(lines: lines));
  }

  /// Changes the angle of a single line.
  /// This means the angle is changed without looking at other lines.
  void _changeAngle(
      LineDrawingAngleChanged event, Emitter<DrawingWidgetState> emit) {
    List<Line> lines = state.lines;

    Line selectedLine =
        state.lines.where((line) => line.isSelected).toList().first;

    Offset newOffset = _calculationService.calculatePointWithAngle(
        selectedLine.start, event.length, event.angle);

    Line newLine = selectedLine.copyWith(end: newOffset);

    int index = lines.indexOf(selectedLine);

    lines
      ..insert(index, newLine)
      ..remove(selectedLine);

    if (lines.length > index + 1) {
      Line nextLine = lines[index + 1];
      lines
        ..removeAt(index + 1)
        ..insert(index + 1, nextLine.copyWith(start: newOffset));
    }

    emit(state.copyWith(lines: []));
    emit(state.copyWith(lines: lines));
  }

  void _onReplaceLines(LinesReplaced event, Emitter<DrawingWidgetState> emit) {
    emit(state.copyWith(lines: event.lines));
  }
}

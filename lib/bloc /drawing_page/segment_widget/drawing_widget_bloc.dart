import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/bloc%20/drawing_page/segment_widget/drawing_widget_event.dart';
import 'package:open_bsp/bloc%20/drawing_page/segment_widget/drawing_widget_state.dart';
import 'package:open_bsp/model/Line2.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';
import 'package:open_bsp/model/appmodes.dart';

import '../../../model/segment_widget/segment.dart';
import '../../../services/geometric_calculations_service.dart';

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
        )) {
    /// New Pan Events
    on<LineDrawingStarted>(_addNewLine);
    on<LineDrawingUpdated>(_updateLine);
    on<LineDrawingPanDown>(_selectLine);
    on<SegmentDeleted>(_deleteLines);

    /// Selected line changes
    on<LineDrawingAngleChanged>(_changeLineAngle);
    on<LineDrawingLengthChanged>(_changeLineLength);

    on<LineDrawingSelectionModeSelected>(_toggleSelectionMode);

    /// Events for mode editing the segment
    on<CurrentSegmentModeChanged>(_changeMode);
    on<SegmentPartDeleted>(_deleteSegmentPart);
    on<LineDrawingUndo>(_undo);
    on<LineDrawingRedo>(_redo);
  }

  void _deleteLines(SegmentDeleted event, Emitter<DrawingWidgetState> emit) {
    print('delete lines');
    emit(state.copyWith(lines: []));
  }

  /// Deletes a part of a [Segment]. To make a delete happen at least two
  /// offsets in a segment have to be selected.
  void _deleteSegmentPart(
      SegmentPartDeleted event, Emitter<DrawingWidgetState> emit) {
    // List<SegmentOffset> offsets = state.segment.first.path;
    // offsets.removeLast();

    // emit(CurrentSegmentUpdate(
    //     segment: [state.segment.first.copyWith(path: offsets)],
    //     mode: Mode.selectionMode));
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
    Line selectedLine = lines.where((line) => line.isSelected).toList().first;

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
  void _changeLineAngle(
      LineDrawingAngleChanged event, Emitter<DrawingWidgetState> emit) {
    Line selectedLine =
        state.lines.where((line) => line.isSelected).toList().first;

    List<Line> selectedLines = state.selectedLines;

    Offset newOffset = _calculationService.calculatePointWithAngle(
        selectedLine.start, event.length, event.angle);

    List<Line> lines = state.lines;
    Line newLine = selectedLine.copyWith(end: newOffset);

    int index = lines.indexOf(selectedLine);

    selectedLines
      ..remove(selectedLines)
      ..add(newLine);

    lines
      ..insert(index, newLine)
      ..remove(selectedLine);

    if (lines.length > index + 1) {
      Line nextLine = lines[index + 1];
      Line newNextLine = nextLine.copyWith(start: newOffset);

      lines
        ..insert(lines.indexOf(nextLine), newNextLine)
        ..remove(nextLine);
    }

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
          isSelected: false);

      if (lines.isNotEmpty) line = line.copyWith(start: lines.last.end);

      print('${lines.length} lines before');
      lines.add(line);
      print('${lines.length} lines after');
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

    emit(state.copyWith(lines: [], selectedLines: []));
    emit(state.copyWith(lines: lines, selectedLines: selectedLines));
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
}

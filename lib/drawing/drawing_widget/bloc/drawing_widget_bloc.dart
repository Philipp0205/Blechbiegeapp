import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/drawing/drawing.dart';
import 'package:open_bsp/drawing/drawing_widget/bloc/drawing_widget_event.dart';
import 'package:open_bsp/drawing/drawing_widget/bloc/drawing_widget_state.dart';
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
    on<LineDrawingStarted>(_onLineDrawingStarted);
    on<LineDrawingUpdated>(_onLineDrawingUpdated);
    on<LineDrawingPanDown>(_onLineDrawingPanDown);

    on<LinesDeleted>(_onLinesDeleted);

    /// Selected line changes
    on<LineDrawingAngleChanged>(_onAngleChanged);
    on<LineDrawingLengthChanged>(_onLineLengthChanged);

    /// Selection mode
    on<LineDrawingSelectionModeSelected>(_onToggleSelectionMode);

    /// Events for mode editing the segment
    on<CurrentSegmentModeChanged>(_onModechanged);

    /// Undo and Redo
    on<LineDrawingUndo>(_onUndo);
    on<LineDrawingRedo>(_onRedo);

    /// ???
    on<LinesReplaced>(_onReplaceLines);
  }

  /// Deletes all lines of the [SegmentWidget].
  /// Emits a new [SegmentWidgetState] with an empty list of [Line]s.
  void _onLinesDeleted(LinesDeleted event, Emitter<DrawingWidgetState> emit) {
    emit(state.copyWith(lines: []));
  }

  void _onModechanged(
      CurrentSegmentModeChanged event, Emitter<DrawingWidgetState> emit) {
    // emit(
    //     CurrentSegmentUpdate(segment: [state.segment.first], mode: event.mode));
  }

  /// Changes the length of a part of a segment.
  /// At lest two [selectedOffsets] in a [Segment] have to be present for a
  /// length change.
  void _onLineLengthChanged(
      LineDrawingLengthChanged event, Emitter<DrawingWidgetState> emit) {
    List<Line> lines = state.lines;
    Line selectedLine = lines.where((line) => line.isSelected).toList().last;

    double lengthOfSelectedLine =
        (selectedLine.start - selectedLine.end).distance;

    Offset movedOffset = _calculationService
        .changeLengthOfLine(selectedLine.start, selectedLine.end,
            event.length - lengthOfSelectedLine, true, true)
        .first;

    Line changedLine = selectedLine.copyWith(end: movedOffset);

    int index = lines.indexOf(selectedLine);

    lines[lines.indexOf(selectedLine)] = changedLine;

    if (lines.length > index + 1) {
      // Line nextLine = lines[index + 1];
      // Line newNextLine = nextLine.copyWith(start: movedOffset);
      //
      // lines
      //   ..insert(index + 1, newNextLine)
      //   ..remove(nextLine);

      lines = _changeFollowingLines(selectedLine, lines, movedOffset);
    }

    emit(state.copyWith(lines: []));
    emit(state.copyWith(lines: lines));
  }

  /// If a line gets changed all following lines should change as well BUT
  /// should keep length and angle.
  List<Line> _changeFollowingLines(
      Line changedLine, List<Line> lines, Offset movedOffset) {
    print('change following lines');

    // Remove all lines from lines after currentLine
    List<Line> linesAfterCurrentLine =
        lines.sublist(lines.indexOf(changedLine), lines.length);

    linesAfterCurrentLine.forEach((line) {
      Line lineBefore = lines[lines.indexOf(line) - 1];

      double angle = _calculationService.getInnerAngle(line, lineBefore);
      double length = (line.start - line.end).distance;

      print("Angle: $angle");

      lines[lines.indexOf(line)] = line.copyWith(
        start: movedOffset,
        end: _calculationService.calculatePointWithAngle(
            movedOffset, length, angle),
      );
    });
    return lines;
  }

  /// When the user start dragging the finger over the screen a new [Line]
  /// gets created.
  ///
  /// Similar to [GestureDetector]: 'Triggered when a pointer has contacted the
  /// screen with a primary button and has begun to move.'
  void _onLineDrawingStarted(
      LineDrawingStarted event, Emitter<DrawingWidgetState> emit) {
    if (state.selectionMode == false) {
      List<Line> lines = state.lines;

      Line line = new Line(
        start: event.firstDrawnOffset,
        end: event.firstDrawnOffset,
        isSelected: false,
      );

      if (lines.isNotEmpty) line = line.copyWith(start: lines.last.end);

      lines.add(line);
      emit(state.copyWith(lines: [], linesBeforeUndo: []));
      emit(state.copyWith(lines: lines, linesBeforeUndo: lines));
    }
  }

  /// The line that is currently drawn gets update. The user drags the finger
  /// across the screen.
  ///
  /// Similar to [GestureDetector]: 'A pointer that is in contact with the
  /// screen with a primary button and moving has moved again.'
  void _onLineDrawingUpdated(
      LineDrawingUpdated event, Emitter<DrawingWidgetState> emit) {
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
  void _onLineDrawingPanDown(
      LineDrawingPanDown event, Emitter<DrawingWidgetState> emit) {
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

    double angle =
        _calculationService.getAngle(selectedLine.start, selectedLine.end);

    double newAngle = 0;

    // Get line before and after the selected line.
    if (index > 0) {
      Line previousLine = lines[index - 1];
      double angleOfPrevLine =
          _calculationService.getAngle(previousLine.start, previousLine.end);

      // Higher angle minus lower angle
      newAngle = angle - angleOfPrevLine;
    } else {
      newAngle = angle;
    }

    lines
      ..removeAt(index)
      ..insert(index, selectedLine);

    selectedLines = lines.where((line) => line.isSelected).toList();

    double length = (selectedLine.start - selectedLine.end).distance;

    emit(state.copyWith(lines: [], selectedLines: []));
    emit(state.copyWith(
        lines: lines,
        selectedLines: selectedLines,
        currentAngle: newAngle,
        currentLength: length));
  }

  Line _toggleLineSelection(Line line) {
    return line.copyWith(isSelected: !line.isSelected);
  }

  /// Changes the selection mode
  void _onToggleSelectionMode(LineDrawingSelectionModeSelected event,
      Emitter<DrawingWidgetState> emit) {
    emit(state.copyWith(selectionMode: event.selectionMode));
  }

  /// Undo option.
  /// Removes the last drawn line in the [DrawingWidget].
  void _onUndo(LineDrawingUndo event, Emitter<DrawingWidgetState> emit) {
    List<Line> lines = state.lines;
    List<Line> linesBeforeUndo = state.linesBeforeUndo.toList();

    if (lines.length == 1) {
      return;
    }

    if (lines.length > state.linesBeforeUndo.length) {
      linesBeforeUndo = state.lines;
    }

    lines.removeLast();

    emit(state.copyWith(lines: [], linesBeforeUndo: []));
    emit(state.copyWith(lines: lines, linesBeforeUndo: linesBeforeUndo));
  }

  /// Redo option.
  /// Adds the last removed line in the [DrawingWidget].
  void _onRedo(LineDrawingRedo event, Emitter<DrawingWidgetState> emit) {
    List<Line> history = state.linesBeforeUndo;
    List<Line> lines = state.lines.toList();

    int index = lines.isNotEmpty ? lines.indexOf(lines.last) : 0;

    if (history.length > index) {
      lines.add(history[index + 1]);
    }

    emit(state.copyWith(lines: []));
    emit(state.copyWith(lines: lines));
  }

  /// Changes the angle of a single line.
  /// This means the angle is changed without looking at other lines.
  void _onAngleChanged(
      LineDrawingAngleChanged event, Emitter<DrawingWidgetState> emit) {
    List<Line> lines = state.lines;

    Line selectedLine =
        state.lines.where((line) => line.isSelected).toList().first;
    int indexOfSelectedLine = lines.indexOf(selectedLine);

    // Ugly
    double newAngle = 0;
    Line previousLine = selectedLine;
    if (indexOfSelectedLine != 0) {
      previousLine = lines[indexOfSelectedLine - 1];
      double angleOfPrevLine =
          _calculationService.getAngle(previousLine.start, previousLine.end);
      newAngle = angleOfPrevLine + event.angle;
    } else {
      newAngle = event.angle;
      previousLine = selectedLine;
    }

    Offset newOffset = _calculationService.calculatePointWithAngle(
        selectedLine.start, event.length, newAngle);

    Line newLine = selectedLine.copyWith(end: newOffset);

    lines
      ..insert(indexOfSelectedLine, newLine)
      ..remove(selectedLine);

    if (lines.length > indexOfSelectedLine + 1) {
      Line nextLine = lines[indexOfSelectedLine + 1];
      lines
        ..removeAt(indexOfSelectedLine + 1)
        ..insert(indexOfSelectedLine + 1, nextLine.copyWith(start: newOffset));
    }

    emit(state.copyWith(lines: []));
    emit(state.copyWith(lines: lines));
  }

  void _onReplaceLines(LinesReplaced event, Emitter<DrawingWidgetState> emit) {
    emit(state.copyWith(lines: event.lines));
  }
}

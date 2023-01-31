import 'package:flutter/cupertino.dart';

import '../../../../model/appmodes.dart';
import '../../../../model/line.dart';

/// Handles all events of the [SegmentWidget].
abstract class DrawingWidgetEvent {
  const DrawingWidgetEvent();
}

class CurrentSegmentPanDowned extends DrawingWidgetEvent {
  final DragDownDetails details;

  CurrentSegmentPanDowned({required this.details});
}

/// Deletes all lines of the [SegmentWidget].
class LinesDeleted extends DrawingWidgetEvent {
  LinesDeleted();
}

class CurrentSegmentModeChanged extends DrawingWidgetEvent {
  final Mode mode;

  const CurrentSegmentModeChanged({required this.mode});
}

class CurrentSegmentUnselected extends DrawingWidgetEvent {
  const CurrentSegmentUnselected();
}


/// Triggers when [length] of a lines gets changed. 
class LineDrawingLengthChanged extends DrawingWidgetEvent {
  final double length;

  const LineDrawingLengthChanged({required this.length});
}

/// Event when the [angle] of a line is changed.
/// Takes two [Lines]s into accounts.
class LineDrawingInnerAngleChanged extends DrawingWidgetEvent {
  final double angle;
  final double length;

  const LineDrawingInnerAngleChanged({required this.angle, required this.length});
}

/// Event when the [angle] of a line is changed.
/// Takes one [Lines]s into accounts.
class LineDrawingAngleChanged extends DrawingWidgetEvent {
  final double angle;
  final double length;

  const LineDrawingAngleChanged({required this.angle, required this.length});
}

/// The user starts to draw a line.
/// Triggered with [onPanStart] of the [GestureDetector].
class LineDrawingStarted extends DrawingWidgetEvent {
  final Offset firstDrawnOffset;

  const LineDrawingStarted({required this.firstDrawnOffset});
}

/// The user updates the line (drags finger across the screen).
/// Triggered with [onPanUpdate] of the [GestureDetector].
class LineDrawingUpdated extends DrawingWidgetEvent {
  final Offset updatedOffset;
  const LineDrawingUpdated({required this.updatedOffset});
}

/// Event happens when the user tabs on the screen once.
/// Triggered with [onPanDown] of the [GestureDetector].
class LineDrawingPanDown extends DrawingWidgetEvent {
  final Offset panDownOffset;
  const LineDrawingPanDown({required this.panDownOffset});
}

/// The selection mode was selected by the suer in the [DrawingPage].
/// Event got handed down from the [DrawingPage] through a listener in the
/// [DrawingWidget].
class LineDrawingSelectionModeSelected extends DrawingWidgetEvent {
  final bool selectionMode;
  LineDrawingSelectionModeSelected({required this.selectionMode});
}

/// Undo (delete) the last drawn line.
class LineDrawingUndo extends DrawingWidgetEvent {
  LineDrawingUndo();
}

/// Redo (recover) the last drawn line. Is possible with multiple lines as well.
class LineDrawingRedo extends DrawingWidgetEvent {
  LineDrawingRedo();
}

/// Event that triggers when user presses undo button.
/// Undo is only possible if there is a line to undo.
class LineDrawingUndoPossible extends DrawingWidgetEvent {
  LineDrawingUndoPossible();
}

/// Event that that updates the [lines] of the widget.
class LinesReplaced extends DrawingWidgetEvent {
  final List<Line> lines;

  const LinesReplaced({required this.lines});
}




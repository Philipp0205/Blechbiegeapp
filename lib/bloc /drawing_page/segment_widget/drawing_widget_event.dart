import 'package:flutter/cupertino.dart';
import 'package:open_bsp/model/segment_widget/segment.dart';

import '../../../model/appmodes.dart';

/// Handles all events of the [SegmentWidget].
abstract class DrawingWidgetEvent {
  const DrawingWidgetEvent();
}

class CurrentSegmentPanDowned extends DrawingWidgetEvent {
  final DragDownDetails details;
  final Mode mode;

  CurrentSegmentPanDowned({required this.details, required this.mode});
}

class SegmentDeleted extends DrawingWidgetEvent {
  SegmentDeleted();
}

class SegmentPartDeleted extends DrawingWidgetEvent {
  SegmentPartDeleted();
}

class CurrentSegmentModeChanged extends DrawingWidgetEvent {
  final Mode mode;

  const CurrentSegmentModeChanged({required this.mode});
}

class CurrentSegmentUnselected extends DrawingWidgetEvent {
  const CurrentSegmentUnselected();
}

class SegmentPartLengthChanged extends DrawingWidgetEvent {
  final double length;

  const SegmentPartLengthChanged({required this.length});
}

class SegmentPartAngleChanged extends DrawingWidgetEvent {
  final double angle;
  final double length;

  const SegmentPartAngleChanged({required this.angle, required this.length});
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




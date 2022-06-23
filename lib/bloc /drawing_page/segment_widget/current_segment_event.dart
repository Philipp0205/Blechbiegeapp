import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_bsp/model/segment_widget/segment.dart';

import '../../../model/appmodes.dart';

abstract class SegmentWidgetEvent {
  const SegmentWidgetEvent();
}

class CurrentSegmentPanStarted extends SegmentWidgetEvent {
  final Mode mode;
  final Offset firstDrawnOffset;

  const CurrentSegmentPanStarted(
      {required this.firstDrawnOffset, required this.mode});
}

class CurrentSegmentPanUpdated extends SegmentWidgetEvent {
  final Segment segment;
  final Offset offset;
  final Mode mode;

  const CurrentSegmentPanUpdated(
      {required this.segment, required this.offset, required this.mode});
}

class CurrentSegmentPanEnded extends SegmentWidgetEvent {
  final Segment segment2;
  final Mode mode;

  CurrentSegmentPanEnded({required this.segment2, required this.mode});


}

class CurrentSegmentPanDowned extends SegmentWidgetEvent {
  final DragDownDetails details;
  final Mode mode;

  CurrentSegmentPanDowned({required this.details, required this.mode});
}

class SegmentDeleted extends SegmentWidgetEvent {
  SegmentDeleted();
}

class SegmentPartDeleted extends SegmentWidgetEvent {
  SegmentPartDeleted();
}

class CurrentSegmentModeChanged extends SegmentWidgetEvent {
  final Mode mode;

  const CurrentSegmentModeChanged({required this.mode});
}

class CurrentSegmentUnselected extends SegmentWidgetEvent {
  const CurrentSegmentUnselected();
}

class SegmentPartLengthChanged extends SegmentWidgetEvent {
  final double length;

  const SegmentPartLengthChanged({required this.length});
}

class SegmentPartAngleChanged extends SegmentWidgetEvent {
  final double angle;
  final double length;

  const SegmentPartAngleChanged({required this.angle, required this.length});
}

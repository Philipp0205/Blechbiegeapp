import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_bsp/bloc%20/current_path/current_segment_state.dart';

import '../../model/appmodes.dart';
import '../../model/segment.dart';

abstract class CurrentSegmentEvent extends Equatable {
  const CurrentSegmentEvent();

  @override
  List<Object> get props => [];
}

class CurrentSegmentPanStarted extends CurrentSegmentEvent {
  final Mode mode;
  final Offset firstDrawnOffset;
  const CurrentSegmentPanStarted({required this.firstDrawnOffset, required this.mode});
}

class CurrentSegmentPanUpdated extends CurrentSegmentEvent {
  final List<Segment> currentSegment;
  final Offset offset;
  final Mode mode;

  const CurrentSegmentPanUpdated(
      {required this.currentSegment, required this.offset, required this.mode});
}

class CurrentSegmentPanEnded extends CurrentSegmentEvent {
  final List<Segment> currentSegment;
  final Mode mode;

  CurrentSegmentPanEnded({required this.currentSegment, required this.mode});

}

class CurrentSegmentPanDowned extends CurrentSegmentEvent {
  final DragDownDetails details;
  final Mode mode;

  CurrentSegmentPanDowned({required this.details, required this.mode});
}

class SegmentPartDeleted extends CurrentSegmentEvent {
  SegmentPartDeleted();
}

class CurrentSegmentModeChanged extends CurrentSegmentEvent {
  final Mode mode;

  const CurrentSegmentModeChanged({required this.mode});
}

class CurrentSegmentUnselected extends CurrentSegmentEvent {
  const CurrentSegmentUnselected();
}



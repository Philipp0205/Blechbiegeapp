
import 'package:equatable/equatable.dart';

import '../../model/appmodes.dart';
import '../../model/segment.dart';

abstract class CurrentSegmentState extends Equatable {
  final List<Segment> currentSegment;
  final Mode mode;

  const CurrentSegmentState({required this.currentSegment, required this.mode});

  @override
  List<Object> get props => [currentSegment];
}

class CurrentSegmentInitial extends CurrentSegmentState {
  final List<Segment> currentSegment;
  final Mode mode;

  const CurrentSegmentInitial({required this.currentSegment, required this.mode})
      : super(currentSegment: currentSegment, mode: mode);
}

class CurrentPathSegmentUpdate extends CurrentSegmentState {
  final List<Segment> segment;
  final Mode mode;

  const CurrentPathSegmentUpdate({required this.segment, required this.mode})
      : super(currentSegment: segment, mode: mode);
}

class CurrentSegmentSelect extends CurrentSegmentState {

  CurrentSegmentSelect({required List<Segment> currentSegment}) : super(currentSegment: currentSegment, mode: Mode.defaultMode);
}

class CurrentSegmentDelete extends CurrentSegmentState {

  CurrentSegmentDelete() : super(currentSegment: [], mode: Mode.defaultMode);


}



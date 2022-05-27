import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/segments_repository.dart';
import '../../model/appmodes.dart';
import '../../model/segment.dart';

part 'current_path_event.dart';

part 'current_path_state.dart';

class CurrentPathBloc extends Bloc<CurrentPathEvent, CurrentPathState> {

  final SegmentsRepository segmentsRepository;

  CurrentPathBloc(this.segmentsRepository) : super(CurrentSegmentInitial(currentSegment: [])) {
    on<PanStarted>(_onCurrentPathStarted);
    on<PanUpdated>(_onCurrentPathUpdated);
    on<PanEnded>(_onPanEnded);
    on<PanDowned>(_onPanDowned);
    on<CurrentSegmentDeleted>(_deleteCurrentSegment);
  }
  /// Creates currently drawn segment
  void _onCurrentPathStarted(PanStarted event, Emitter<CurrentPathState> emit) {
    Segment segment = new Segment([event.firstDrawnOffset], Colors.black, 5);
    emit(CurrentSegmentUpdate(segment: [segment]));
  }

  void _onCurrentPathUpdated(PanUpdated event, Emitter<CurrentPathState> emit) {
    List<Offset> path = [event.currentSegment.first.path.first, event.offset];

    List<Segment> segment = [new Segment(path, Colors.black, 5)];

    emit(CurrentSegmentUpdate(segment: segment));
  }

  void _onPanEnded(PanEnded event, Emitter<CurrentPathState> emit) {
    segmentsRepository.addSegment(event.currentSegment.first);
    print('${segmentsRepository.getAllSegments().length} segments in repo');
    emit(CurrentSegmentUpdate(segment: [event.currentSegment.first]));
  }

  void _deleteCurrentSegment(
      CurrentSegmentDeleted event, Emitter<CurrentPathState> emit) {
    emit(CurrentSegmentUpdate(segment: []));
  }

  void _onPanDowned(
      PanDowned event, Emitter<CurrentPathState> emit) {
    print('_onPanDowned');
    if (state is CurrentSegmentSelect) {


    }
  }

}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/repository/segments_repository.dart';

import '../../model/segment.dart';

part 'current_path_event.dart';

part 'current_path_state.dart';

class CurrentPathBloc extends Bloc<CurrentPathEvent, CurrentPathState> {
  CurrentPathBloc({required SegmentsResposiory segmentsRepository})
      : this._segmentsResposiory = segmentsRepository,
        super(CurrentSegmentInitial(currentSegment: [])) {
    on<PanStarted>(_onCurrentPathStarted);
    on<PanUpdated>(_onCurrentPathUpdated);
    on<PanEnded>(_onPanEnded);
    on<CurrentSegmentDeleted>(_deleteCurrentSegment);
  }
  final SegmentsResposiory _segmentsResposiory;

  /// Creates currently drawn segment
  void _onCurrentPathStarted(PanStarted event, Emitter<CurrentPathState> emit) {

    print('currentpath started all segments from repo: ${_segmentsResposiory.getAllSegments().first.path}');


    Segment segment = new Segment([event.firstDrawnOffset], Colors.black, 5);
    emit(CurrentSegmentUpdate(segment: [segment]));
  }

  void _onCurrentPathUpdated(PanUpdated event, Emitter<CurrentPathState> emit) {
    List<Offset> path = List.from(event.currentSegment.first.path);
    path.add(event.offset);

    List<Segment> segment = [new Segment(path, Colors.black, 5)];

    emit(CurrentSegmentUpdate(segment: segment));
  }

  void _onPanEnded(PanEnded event, Emitter<CurrentPathState> emit) {
    List<Offset> currentPath = event.currentSegment.first.path;
    Segment straigtSegment =
        new Segment([currentPath.first, currentPath.last], Colors.black, 5);
    emit(CurrentSegmentUpdate(segment: [straigtSegment]));
  }

  void _deleteCurrentSegment(
      CurrentSegmentDeleted event, Emitter<CurrentPathState> emit) {
    emit(CurrentSegmentUpdate(segment: []));
  }
}

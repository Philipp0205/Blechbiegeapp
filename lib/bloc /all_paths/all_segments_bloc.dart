import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../data/segments_repository.dart';
import '../../model/segment.dart';

part 'all_segments_event.dart';

part 'all_segments_state.dart';

class AllSegmentsBloc extends Bloc<AllPathsEvent, AllPathsState> {
  final SegmentsRepository segmentsRepository;

  AllSegmentsBloc(this.segmentsRepository)
      : super(AllSegmentsInitial(segments: [])) {
    on<AllSegmentsSegmentAdded>(_onSegmentAdded);
    on<AllSegmentsDeleted>(_onDeleted);
    on<AllSegmentsUpdated>(_onSegmentsUpdated);
    on<AllSegmentsSegmentDeleted>(_onSegmentDelted);
  }
  

  void _onSegmentAdded(
      AllSegmentsSegmentAdded event, Emitter<AllPathsState> emit) {
    segmentsRepository.addSegment(event.segment);
    List<Segment> segments = segmentsRepository.getAllSegments();
    // segments.add(event.segment);

    emit(SegmentUpdate(segments: segments));
  }

  void _onDeleted(AllSegmentsDeleted event, Emitter<AllPathsState> emit) {
    segmentsRepository.deleteAllSegments();
    emit(SegmentUpdate(segments: segmentsRepository.getAllSegments()));
  }

  void _onSegmentsUpdated(
      AllSegmentsUpdated event, Emitter<AllPathsState> emit) {
    emit(SegmentUpdate(segments: segmentsRepository.getAllSegments()));
  }

  void _onSegmentDelted(
      AllSegmentsSegmentDeleted event, Emitter<AllPathsState> emit) {
    segmentsRepository.removeSegment(event.segment);

  }
}

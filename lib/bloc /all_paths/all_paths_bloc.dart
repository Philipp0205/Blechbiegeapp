import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../data/segments_repository.dart';
import '../../model/segment.dart';

part 'all_paths_event.dart';

part 'all_paths_state.dart';

class AllPathsBloc extends Bloc<AllPathsEvent, AllPathsState> {
  final SegmentsRepository segmentsRepository;
  AllPathsBloc(this.segmentsRepository) : super(AllPathsInitial(segments: [])) {
    on<SegmentAdded>(_onSegmentAdded);
    on<AllPathsDeleted>(_onDeleted);
    on<AllPathsUpdated>(_onSegmentsUpdated);
  }
  
  void _onSegmentAdded(SegmentAdded event, Emitter<AllPathsState> emit) {
    print('added segment ${event.segment.path}');
    segmentsRepository.addSegment(event.segment);
    List<Segment> segments = segmentsRepository.getAllSegments();
    // segments.add(event.segment);

    emit(AllPathsSegmentsUpdated(segments: segments));
  }


  void _onDeleted(AllPathsDeleted event, Emitter<AllPathsState> emit) {
    print('allpaths: _onDeleted');
    segmentsRepository.deleteAllSegments();
    emit(AllPathsSegmentsUpdated(segments: segmentsRepository.getAllSegments()));
  }


  void _onSegmentsUpdated(AllPathsUpdated event, Emitter<AllPathsState> emit) {
    print('_onSegmentsUpdated');
    emit(AllPathsSegmentsUpdated(segments: segmentsRepository.getAllSegments()));

  }
}

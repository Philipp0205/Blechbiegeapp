import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../model/segment.dart';

part 'all_paths_event.dart';

part 'all_paths_state.dart';

class AllPathsBloc extends Bloc<AllPathsEvent, AllPathsState> {
  AllPathsBloc() : super(AllPathsInitial(segments: [])) {
    on<SegmentAdded>(_onSegmentAdded);
    on<AllPathsDeleted>(_onDeleted);
  }
  
  void _onSegmentAdded(SegmentAdded event, Emitter<AllPathsState> emit) {
    print('_onSegmentAdded');
    List<Segment> segments = state.segments;
    segments.add(event.segment);

    emit(SegmentsUpdate(segments: segments));
  }

  void _onDeleted(AllPathsDeleted event, Emitter<AllPathsState> emit) {
    print('allpaths: _onDeleted');
    emit(SegmentsUpdate(segments: []));


  }
}

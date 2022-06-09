import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:open_bsp/model/segment_model.dart';

import '../../model/segment2.dart';
import '../../model/segment_offset.dart';

part 'constructing_page_event.dart';

part 'constructing_page_state.dart';

class ConstructingPageBloc
    extends Bloc<ConstructingPageEvent, ConstructingPageState> {
  ConstructingPageBloc() : super(ConstructingPageCreate(segment: [])) {
    on<ConstructingPageCreated>(_setInitialSegment);
  }

  void _setInitialSegment(
      ConstructingPageCreated event, Emitter<ConstructingPageState> emit) {
    List<SegmentOffset> result = cropSegmentToArea(event.segment.first);
    emit(ConstructingPageCreate(segment: [event.segment.first.copyWith(path: result)]));
  }

  List<SegmentOffset> cropSegmentToArea(Segment2 segment) {
    Map<int, double> xValues = {};
    Map<int, double> yValues = {};

    List<SegmentOffset> path = segment.path;

    path.forEach((o) {
      xValues.addEntries([MapEntry(path.indexOf(o), o.offset.dx)]);
      yValues.addEntries([MapEntry(path.indexOf(o), o.offset.dy)]);
    });

    var xEntries = xValues.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    var yEntries = yValues.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    xValues
      ..clear()
      ..addEntries(xEntries);
    yValues
      ..clear()
      ..addEntries(yEntries);

    print('');

    SegmentOffset smallestX = segment.path[xValues.entries.last.key];
    SegmentOffset smallestY = segment.path[yValues.entries.last.key];
    SegmentOffset highestX = segment.path[xValues.entries.first.key];
    SegmentOffset highestY = segment.path[yValues.entries.first.key];

    List<SegmentOffset> result = [];

    path.forEach((o) {
      print('old y ${o.offset.dy}');
      print('new y ${o.offset.dy - (smallestY.offset.dy -20)}');
      Offset offset =
          new Offset(o.offset.dx, o.offset.dy - (highestY.offset.dy - 40));

      result.add(o.copyWith(offset: offset));
    });

    return result;
  }
}

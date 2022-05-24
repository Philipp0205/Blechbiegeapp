import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/segment.dart';

class SegmentDataService extends ChangeNotifier {
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;

  List<Segment> _segments = [];
  Segment _currentlyDrawnSegment =
  new Segment([new Offset(0, 0)], Colors.black, 5.0);

  List<Segment> get segments => _segments;

  Segment get currentlyDrawnSegment => _currentlyDrawnSegment;

  StreamController<List<Segment>> segmentsStreamController =
  StreamController<List<Segment>>.broadcast();

  StreamController<Segment> currentSegmentStreamController =
  StreamController<Segment>.broadcast();

  set segments(List<Segment> value) {
    _segments = value;
    notifyListeners();
  }

  set currentlyDrawnSegment(Segment value) {
    _currentlyDrawnSegment = value;
    notifyListeners();
  }

  void updateSegmentsStreamController() {
    segmentsStreamController.add(segments);
    notifyListeners();
  }

  void updateCurrentSegmentLineStreamController() {
    currentSegmentStreamController.add(currentlyDrawnSegment);
    notifyListeners();
  }

  void changeSegment(Segment oldSegment, Segment newSegment) {
    segments
      ..remove(oldSegment)
      ..add(newSegment);
    updateSegmentsStreamController();
    
    currentlyDrawnSegment = newSegment;
    updateCurrentSegmentLineStreamController();
  }

  void setCurrentlyDrawnSegment(offset) {
    currentlyDrawnSegment = new Segment(offset, selectedColor, selectedWidth);
    updateCurrentSegmentLineStreamController();

  }
}


import 'dart:async';

import 'package:flutter/material.dart';

import '../model/appmodes.dart';
import '../model/segment.dart';

class SketcherDataViewModel extends ChangeNotifier {
  List<Segment> segments = [];
  Segment segment =
  new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
  Segment selectedSegment =
  new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);

  Modes selectedMode = Modes.defaultMode;


  StreamController<List<Segment>> linesStreamController =
  StreamController<List<Segment>>.broadcast();

  StreamController<Segment> currentLineStreamController =
  StreamController<Segment>.broadcast();

  void clear() {
    segments = [];
    segment = new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
    selectedSegment =
    new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
    selectedMode = Modes.defaultMode;
    notifyListeners();
  }

  void addToCurrentLineStreamController(Segment segment) {
    currentLineStreamController.add(segment);
    notifyListeners();
  }

  void addToLinesStreamController(List<Segment> segments) {
    linesStreamController.add(segments);
    notifyListeners();
  }
}
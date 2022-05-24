import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../model/segment.dart';

class AllPathsViewModel extends ChangeNotifier {
  List<Segment> _segments = [];
  List<Segment> get segments => _segments;

  StreamController<List<Segment>> linesStreamController =
      StreamController<List<Segment>>.broadcast();

  void deleteSegment(Segment segment) {
    segments.remove(segment);
    updateLinesStreamController();
  }

  void updateLinesStreamController() {
    linesStreamController.add(segments);
    notifyListeners();
  }

  void addSegment(Segment segment) {
    this.segments.add(segment);
    this.linesStreamController.add(segments);
    print('segments.length in add segments ${segments.length}');
    notifyListeners();
  }

  Segment getNearestSegment(DragDownDetails details) {
    Map<Segment, double> distances = {};
    print('segments length distance ${segments.length}');

    segments.forEach((line) {
      distances.addEntries([MapEntry(line, getDistanceToLine(details, line))]);
    });

    var mapEntries = distances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    distances
      ..clear()
      ..addEntries(mapEntries);

    return distances.keys.toList().first;
  }

  /*
       Distance(point1, currPoint)
     + Distance(currPoint, point2)
    == Distance(point1, point2)

    https://stackoverflow.com/questions/11907947/how-to-check-if-a-point-lies-on-a-line-between-2-other-points/11912171#11912171
   */
  double getDistanceToLine(DragDownDetails details, Segment line) {
    Point currentPoint =
        new Point(details.globalPosition.dx, details.globalPosition.dy);
    Point startPoint = new Point(line.path.first.dx, line.path.first.dy);
    Point endPoint = new Point(line.path.last.dx, line.path.last.dy);

    return startPoint.distanceTo(currentPoint) +
        currentPoint.distanceTo(endPoint) -
        startPoint.distanceTo(endPoint);
  }

  void clear() {
    _segments = [];

    notifyListeners();
  }
}

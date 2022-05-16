import 'dart:async';
import 'dart:math';

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

  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;

  void setSegment(Segment segment) {
    this.segment = segment;
    notifyListeners();
  }

  void addToPathOfSegment(Offset offset) {
    List<Offset> path = List.from(this.segment.path)..add(offset);
    segment = Segment(path, selectedColor, selectedWidth);
    currentLineStreamController.add(segment);
    notifyListeners();
  }

  void setSelectedSegment(Segment segment, Offset selectedPoint) {
    segment.setIsSelected(selectedPoint);
    this.selectedSegment = segment;
    segment.isSelected = true;
    
    
    notifyListeners();
  }

  void updateSegment(Segment segment) {
    segments.add(segment);
    currentLineStreamController.add(segment);
    linesStreamController.add(segments);
    updateLinesStreamController();
    notifyListeners();
  }


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
    updateLinesStreamController();
    notifyListeners();
  }

  void updateLinesStreamController() {
    print('updateLinesStreamController');
    linesStreamController.add(segments);
    notifyListeners();
  }

  void removeFromCurrentLinStreamController(Segment segment) {}

  void addToLinesStreamController(List<Segment> segments) {
    linesStreamController.add(segments);
    notifyListeners();
  }

  void clearSegmentSelection(Segment segment) {
    segment.isSelected = false;
    segment.highlightPoints = false;
    updateLinesStreamController();

  }

  void extendSegment(Segment line, double length) {
    // deleteLine(line);
    Point pointA = new Point(line.path.first.dx, line.path.first.dy);
    Point pointB = new Point(line.path.last.dx, line.path.last.dy);

    double lengthAB = pointA.distanceTo(pointB);

    double x = pointB.x + (pointB.x - pointA.x) / lengthAB * length;
    double y = pointB.y + (pointB.y - pointA.y) / lengthAB * length;

    Offset pointC = new Offset(x, y);
    Segment newLine =
        new Segment([line.path.first, pointC], selectedColor, selectedWidth);

    segment = newLine;
    notifyListeners();
  }

  void deleteSegment(Segment segment) {
    print('deleteSegment');
    print('selectedSegment ${selectedSegment.path}');
    print('segmentToDelete ${segment.path}');
    Segment segmentToDelete = segments
        .firstWhere((currentSegment) => currentSegment.path == segment.path);
    segments.remove(segmentToDelete);
    linesStreamController.add(segments);
    notifyListeners();
  }

  void setSelectedMode(Modes mode) {
    this.selectedMode = mode;
    notifyListeners();
  }

  void saveLine(Segment line) {
    this.segments.add(selectedSegment);
    deleteSegment(selectedSegment);
  }

  void selectSegment(DragDownDetails details) {
    print('selectSegment');
    Segment lowestDistanceLine = getNearestSegment(details);
    lowestDistanceLine.color = Colors.red;
    changeSelectedSegment(lowestDistanceLine);
  }

  void changeSelectedSegment(Segment segment) {
    print('changeSelectedSegment');
    if (selectedSegment != segment) {
      selectedSegment.isSelected = false;
      segment.isSelected = true;
      selectedSegment.color = Colors.black;
      selectedSegment = segment;
      linesStreamController.add(segments);
      notifyListeners();
    }
  }

  Segment getNearestSegment(DragDownDetails details) {
    Map<Segment, double> distances = {};

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

  void selectPoint(DragStartDetails details) {
    print('Select edge2');
    Point currentPoint =
    new Point(details.globalPosition.dx, details.globalPosition.dy),
        edgeA = new Point(
            selectedSegment.path.first.dx, selectedSegment.path.first.dy),
        edgeB = new Point(
            selectedSegment.path.last.dx, selectedSegment.path.last.dy);

    double threshold = 50;
    double distanceToA = currentPoint.distanceTo(edgeA);
    double distanceToB = currentPoint.distanceTo(edgeB);

    print('currentPoint : ${currentPoint.x} / ${currentPoint.y}');
    print('Point first: ${edgeA.x} / ${edgeA.y}');
    print('Point last: ${edgeB.x} / ${edgeB.y}');
    print('distance to first: $distanceToA');
    print('distance to last: $distanceToB');

    if (distanceToA < distanceToB &&
        (distanceToA < threshold || distanceToB < threshold)) {
      selectedSegment.selectedEdge =
      new Offset(edgeA.x.toDouble(), edgeA.y.toDouble());
      print('selectedEdge is first');
    } else {
      selectedSegment.selectedEdge =
      new Offset(edgeB.x.toDouble(), edgeB.y.toDouble());
      print('selectedEdge is last');
    }
  }
}

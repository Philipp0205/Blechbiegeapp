import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';

import '../model/appmodes.dart';
import '../model/segment.dart';

class SketcherController extends ChangeNotifier {
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
    deleteSegment(selectedSegment);
    this.segment = segment;
    segments.add(segment);
    currentLineStreamController.add(segment);
    linesStreamController.add(segments);
    this.selectedSegment = segment;
    updateLinesStreamController();
    segment.setIsSelected(null);
    this.selectedSegment = segment;
    segment.isSelected = true;
    notifyListeners();
  }

  void updateSelectedSegmentPointMode(Segment segment, Offset offset) {
    segment.highlightPoints = true;
    segment.isSelected = true;
    segment.color = Colors.red;

    deleteSegment(selectedSegment);
    this.segment = segment;
    segments.add(segment);
    currentLineStreamController.add(segment);
    linesStreamController.add(segments);
    updateLinesStreamController();
    this.selectedSegment = segment;
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

  void updateCurrenLineStreamController() {}

  void addToLinesStreamController(List<Segment> segments) {
    linesStreamController.add(segments);
    notifyListeners();
  }

  void clearSegmentSelection(Segment segment) {
    print('clearSegmentSelectoin');
    segment.isSelected = false;
    segment.color = Colors.black;
    segment.highlightPoints = false;
    updateLinesStreamController();
    notifyListeners();
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
      selectedSegment.color = Colors.red;
      selectedSegment.isSelected = false;
      selectedSegment.color = Colors.black;

      segment.isSelected = true;
      segment.color = Colors.red;
      selectedSegment = segment;
      linesStreamController.add(segments);
      updateLinesStreamController();
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

  void selectPoint(Point point) {
    Point currentPoint = point,
        edgeA = new Point(
            selectedSegment.path.first.dx, selectedSegment.path.first.dy),
        edgeB = new Point(
            selectedSegment.path.last.dx, selectedSegment.path.last.dy);

    double threshold = 100,
        distanceToA = currentPoint.distanceTo(edgeA),
        distanceToB = currentPoint.distanceTo(edgeB);

    if (distanceToA < distanceToB && distanceToA < threshold) {
      selectedSegment.selectedEdge =
          new Offset(edgeA.x.toDouble(), edgeA.y.toDouble());
    } else if (distanceToB < distanceToA && distanceToB < threshold) {
      selectedSegment.selectedEdge =
          new Offset(edgeB.x.toDouble(), edgeB.y.toDouble());
    } else {
      print('onPanSelected outside threshold');
      toggleSelectionMode();
    }
    notifyListeners();
  }

  void toggleSelectionMode() {
    print('toggleSelectionMode');
    selectedMode = Modes.selectionMode;
    clearSegmentSelection(selectedSegment);
    notifyListeners();
  }

  void toggleEdgeMode() {
    selectedMode = Modes.pointMode;
    notifyListeners();
  }

  void toggleDefaultMode() {
    Offset offset = new Offset(0, 0);
    selectedSegment.selectedEdge = offset;
    selectedSegment.isSelected = false;
    selectedMode = Modes.defaultMode;
    notifyListeners();
  }

  void straightenSegments() {
    List<Segment> straightSegments = [];

    segments.forEach((line) {
      straightSegments.add(new Segment(
          [line.path.first, line.path.last], selectedColor, selectedWidth));
    });

    clearCurrentLine();
    this.segments = straightSegments;

    notifyListeners();
  }

  void clearCurrentLine() {
    segment = Segment([new Offset(0, 0)], selectedColor, selectedWidth);
    currentLineStreamController.add(segment);
  }

  void addSegment(Segment segment) {
    this.segments.add(segment);
  }

  Segment linkSegments(Segment segment, double threshold) {
    print('linkSegments');

    Offset firstOffset = segment.path.first;
    Offset lastOffset = segment.path.last;

    this.segments.forEach((currentSegment) {
      if (currentSegment.path != segment.path) {
        if ((segment.path.first - currentSegment.path.first).distance <
            threshold) {
          print('condition 1');
          firstOffset = currentSegment.path.first;
        }
        if ((segment.path.first - currentSegment.path.last).distance <
            threshold) {
          print('condition 2');
          firstOffset = currentSegment.path.last;
        }

        if ((segment.path.last - currentSegment.path.first).distance <
            threshold) {
          lastOffset = currentSegment.path.first;
        }
        if ((segment.path.last - currentSegment.path.last).distance <
            threshold) {
          print('condition 3');
          lastOffset = currentSegment.path.last;
        }
      }
    });
    segment.path
      ..first = firstOffset
      ..last = lastOffset;
    return segment;
  }

  Offset linkPoints(Offset offset, double threshold) {
    print('linkPoints');
    Offset result = offset;
    this.segments.forEach((currentSegment) {
      if (currentSegment != this.selectedSegment) {
        if ((currentSegment.path.first - offset).distance < threshold) {
          result = currentSegment.path.first;
        } else if ((currentSegment.path.last - offset).distance < threshold) {
          result = currentSegment.path.last;
        }
      }
    });
    notifyListeners();
    return result;
  }
}

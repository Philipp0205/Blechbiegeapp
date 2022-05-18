import 'dart:async';
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
    segment
      ..highlightPoints = true
      ..isSelected = true
      ..color = Colors.red;

    deleteSegment(selectedSegment);
    this.segment = segment;
    segments.add(segment);
    currentLineStreamController.add(segment);
    linesStreamController.add(segments);
    updateLinesStreamController();
    this.selectedSegment = segment;
    notifyListeners();
  }

  void updateSelectedSegmentPointModeAfterMerge(Segment segment, Offset offset) {
    deleteSegment(this.selectedSegment);
    segment
      ..highlightPoints = true
      ..isSelected = true
      ..color = Colors.red;

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
    linesStreamController.add(segments);
    notifyListeners();
  }

  void updateCurrenLineStreamController() {}

  void addToLinesStreamController(List<Segment> segments) {
    linesStreamController.add(segments);
    notifyListeners();
  }

  void clearSegmentSelection(Segment segment) {
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
    Segment lowestDistanceLine = getNearestSegment(details);
    lowestDistanceLine.color = Colors.red;
    changeSelectedSegment(lowestDistanceLine);
  }

  void changeSelectedSegment(Segment segment) {
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
      toggleSelectionMode();
    }
    notifyListeners();
  }

  void toggleSelectionMode() {
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

  Segment straigthenSegment(Segment segment) {
    clearCurrentLine();
    return new Segment([segment.path.first, segment.path.last], selectedColor, selectedWidth);

  }

  void clearCurrentLine() {
    segment = Segment([new Offset(0, 0)], selectedColor, selectedWidth);
    currentLineStreamController.add(segment);
  }

  void addSegment(Segment segment) {
    this.segments.add(segment);
    notifyListeners();
  }

  Segment linkSegments(Segment segment, double threshold) {
    Offset firstOffset = segment.path.first;
    Offset lastOffset = segment.path.last;

    this.segments.forEach((currentSegment) {
      if (currentSegment.path != segment.path) {
        if ((segment.path.first - currentSegment.path.first).distance <
            threshold) {
          firstOffset = currentSegment.path.first;
        }
        if ((segment.path.first - currentSegment.path.last).distance <
            threshold) {
          firstOffset = currentSegment.path.last;
        }

        if ((segment.path.last - currentSegment.path.first).distance <
            threshold) {
          lastOffset = currentSegment.path.first;
        }
        if ((segment.path.last - currentSegment.path.last).distance <
            threshold) {
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

  Segment? mergeSegmentsIfNear(Segment segment, double threshold) {
    Segment? result;
    this.segments.forEach((currentSegment) {
      if (currentSegment.path != segment.path) {
        [currentSegment.path.first, currentSegment.path.last]
            .forEach((offsetOfCurrentSegment) {
          [segment.path.first, segment.path.last].forEach((offsetOfSegment) {
            if ((offsetOfCurrentSegment - offsetOfSegment).distance <
                threshold) {
              result = mergeSegments(currentSegment, segment,
                  offsetOfCurrentSegment, offsetOfSegment);
            }
          });
        });
      }
    });
    return result;
  }

  /// Merges segmentB into segmentA
  Segment mergeSegments(Segment segmentA, Segment segmentB,
      Offset offsetToMergeSegmentA, Offset offsetToMergeSegmentB) {
    print('merge Segments');

    print('segmentA ${segmentA.path}');
    print('segmentB ${segmentB.path}');

    if (offsetToMergeSegmentA == segmentA.path.first &&
        offsetToMergeSegmentB == segmentB.path.first) {
      segmentA.path.insert(0, segmentB.path.first);
      updateSegment(segmentA);
      return segmentA;
    }
    if (offsetToMergeSegmentA == segmentA.path.first &&
        offsetToMergeSegmentB == segmentB.path.last) {
      segmentA.path.insert(0, segmentA.path.first);
      updateSegment(segmentA);
      return segmentA;
    }
    if (offsetToMergeSegmentA == segmentA.path.last &&
        offsetToMergeSegmentB == segmentB.path.last) {
      segmentA.path.add(segmentB.path.first);
      updateSegment(segmentA);
      return segmentA;
    }
    if (offsetToMergeSegmentA == segmentA.path.last &&
        offsetToMergeSegmentB == segmentB.path.first) {
      segmentA.path.add(segmentA.path.last);
      updateSegment(segmentA);
      return segmentA;
    }
    return segmentA;
  }
}

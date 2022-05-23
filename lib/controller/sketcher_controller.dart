import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../model/appmodes.dart';
import '../model/segment.dart';

class SketcherController extends ChangeNotifier {
  List<Segment> segments = [];

  Segment currentlyDrawnSegment =
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

  void setCurrentlyDrawnSegment(Offset offset) {
    this.currentlyDrawnSegment =
        new Segment([offset], selectedColor, selectedWidth);
    notifyListeners();
  }

  void addToPathOfCurrentlyDrawnSegment(Offset offset) {
    List<Offset> path = List.from(this.currentlyDrawnSegment.path)..add(offset);
    currentlyDrawnSegment = Segment(path, selectedColor, selectedWidth);
    currentLineStreamController.add(currentlyDrawnSegment);
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
    // this.currentlyDrawnSegment = segment;
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

  void updateSegmentPointMode(Segment segment, Offset offset) {
    segment
      ..highlightPoints = true
      ..isSelected = true
      ..color = Colors.red;

    deleteSegment(this.selectedSegment);
    this.segments.add(segment);
    currentLineStreamController.add(segment);
    this.currentlyDrawnSegment = segment;
    this.selectedSegment = segment;
    this.linesStreamController.add(segments);
    updateLinesStreamController();
    notifyListeners();
  }

  void clear() {
    segments = [];
    currentlyDrawnSegment =
        new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
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

  void clearSegmentSelection(Segment segment) {
    segment.isSelected = false;
    segment.color = Colors.black;
    segment.highlightPoints = false;
    updateLinesStreamController();
    notifyListeners();
  }

  void clearSegment() {
    this.currentlyDrawnSegment = new Segment(
        [new Offset(0, 0), new Offset(0, 0)], selectedColor, selectedWidth);
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

    currentlyDrawnSegment = newLine;
    notifyListeners();
  }

  void deleteSegment(Segment segment) {
    segments.remove(segment);
    updateLinesStreamController();
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
    if (this.selectedSegment != segment) {
      selectedSegment
        ..isSelected = false
        ..color = Colors.black;

      segment
        ..isSelected = true
        ..color = Colors.red;

      this.selectedSegment = segment;

      addToCurrentLineStreamController(segment);

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
    return new Segment(
        [segment.path.first, segment.path.last], selectedColor, selectedWidth);
  }

  void clearCurrentLine() {
    currentlyDrawnSegment =
        Segment([new Offset(0, 0)], selectedColor, selectedWidth);
    currentLineStreamController.add(currentlyDrawnSegment);
  }

  void addSegment(Segment segment) {
    this.segments.add(segment);
    clearSegment();
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

  /// Merges end points of segments when distance is below threshold.
  void mergeSegmentsIfNearToEachOther(Segment segment, double threshold) {
    for (Segment currentSegment in segments) {
      List<Offset> offsetsCurrentSegment = [
        currentSegment.path.first,
        currentSegment.path.last
      ];
      if (currentSegment.path != segment.path) {
        for (Offset offsetOfCurrentSegment in offsetsCurrentSegment) {
          for (Offset offsetOfSegment in [
            segment.path.first,
            segment.path.last
          ]) {
            if ((offsetOfCurrentSegment - offsetOfSegment).distance <
                threshold) {
              Segment? mergedSegment = mergeSegments(currentSegment, segment,
                  offsetOfCurrentSegment, offsetOfSegment);
              if (mergedSegment != null) {
                changeSelectedSegment(currentSegment);
              }
            }
            break;
          }
        }
      }
    }
  }

  /// Merges segmentB into segmentA
  Segment? mergeSegments(Segment segmentA, Segment segmentB,
      Offset offsetToMergeSegmentA, Offset offsetToMergeSegmentB) {
    print('merge Segments');

    print('segmentA ${segmentA.path}');
    print('segmentB ${segmentB.path}');

    if (offsetToMergeSegmentA == segmentA.path.first &&
        offsetToMergeSegmentB == segmentB.path.first) {
      print('case first first');
      segmentA.path.insert(0, segmentB.path.last);
      updateSegment(segmentA);
      return segmentA;
    }
    if (offsetToMergeSegmentA == segmentA.path.first &&
        offsetToMergeSegmentB == segmentB.path.last) {
      print('case first last');
      segmentA.path.insert(0, segmentB.path.first);
      updateSegment(segmentA);
      return segmentA;
    }
    if (offsetToMergeSegmentA == segmentA.path.last &&
        offsetToMergeSegmentB == segmentB.path.last) {
      print('case last last');
      segmentA.path.add(segmentB.path.first);
      updateSegment(segmentA);
      return segmentA;
    }
    if (offsetToMergeSegmentA == segmentA.path.last &&
        offsetToMergeSegmentB == segmentB.path.first) {
      print('case last first');
      segmentA.path.add(segmentB.path.last);
      updateSegment(segmentA);
      return segmentA;
    }
    return null;
  }

  changeSelectedSegmentDependingNewOffset(
      Offset? selectedEdge, Offset newOffset) {
    List<Offset> offsets = this.selectedSegment.path;
    if (this.selectedSegment.selectedEdge != null) {
      if (selectedSegment.selectedEdge == selectedSegment.path.first) {
        offsets.removeAt(0);
        offsets.insert(0, newOffset);
      } else {
        offsets.removeLast();
        offsets.add(newOffset);
      }
      Segment segment = new Segment(offsets, selectedColor, selectedWidth);
      segment.selectedEdge = newOffset;
      updateSegmentPointMode(segment, newOffset);
    }
  }


}

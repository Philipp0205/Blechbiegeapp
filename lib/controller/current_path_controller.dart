import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/controller/all_paths_controller.dart';
import 'package:open_bsp/services/controller_locator.dart';

import '../model/segment.dart';

class CurrentPathController extends ChangeNotifier {
  Segment currentlyDrawnSegment =
      new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);

  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;

  AllPathsController _allPathsController = getIt<AllPathsController>();

  StreamController<Segment> currentLineStreamController =
      StreamController<Segment>.broadcast();

  List<Segment> get segments => _allPathsController.segments;

  void addToPathOfCurrentlyDrawnSegment(Offset offset) {
    List<Offset> path = List.from(this.currentlyDrawnSegment.path)..add(offset);
    currentlyDrawnSegment = Segment(path, selectedColor, selectedWidth);
    currentLineStreamController.add(currentlyDrawnSegment);
    notifyListeners();
  }

  changeSelectedSegmentDependingNewOffset(
      Offset? selectedEdge, Offset newOffset) {
    List<Offset> offsets = this.currentlyDrawnSegment.path;
    if (this.currentlyDrawnSegment.selectedEdge != null) {
      if (currentlyDrawnSegment.selectedEdge ==
          currentlyDrawnSegment.path.first) {
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

  void setCurrentlyDrawnSegment(Offset offset) {
    this.currentlyDrawnSegment =
        new Segment([offset], selectedColor, selectedWidth);
    notifyListeners();
  }

  void clearSegment() {
    this.currentlyDrawnSegment = new Segment(
        [new Offset(0, 0), new Offset(0, 0)], selectedColor, selectedWidth);
  }

  void updateSegmentPointMode(Segment segment, Offset offset) {
    segment
      ..highlightPoints = true
      ..isSelected = true
      ..color = Colors.red;

    _allPathsController
      ..deleteSegment(this.currentlyDrawnSegment)
      ..addSegment(segment);

    clearSegment();

    currentLineStreamController.add(segment);
    this.currentlyDrawnSegment = segment;
    notifyListeners();
  }

  void changeSelectedSegment(Segment segment) {
    if (this.currentlyDrawnSegment != segment) {
      currentlyDrawnSegment
        ..isSelected = false
        ..color = Colors.black;

      segment
        ..isSelected = true
        ..color = Colors.red;

      this.currentlyDrawnSegment = segment;

      addToCurrentLineStreamController(segment);

      notifyListeners();
    }
  }

  void addToCurrentLineStreamController(Segment segment) {
    currentLineStreamController.add(segment);
    notifyListeners();
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

  void clearCurrentLine() {
    currentlyDrawnSegment =
        Segment([new Offset(0, 0)], selectedColor, selectedWidth);
    currentLineStreamController.add(currentlyDrawnSegment);
  }

  Segment straigthenSegment(Segment segment) {
    clearCurrentLine();
    return new Segment(
        [segment.path.first, segment.path.last], selectedColor, selectedWidth);
  }

  void updateSegment(Segment segment) {
    segments.add(segment);
    currentLineStreamController.add(segment);
    _allPathsController
      ..deleteSegment(currentlyDrawnSegment)
      ..addSegment(segment);

    this.currentlyDrawnSegment = segment;

    segment
      ..setIsSelected(null)
      ..isSelected = true;

    notifyListeners();
  }

  void addSegment(Segment segment) {
    _allPathsController.addSegment(segment);
  }

  void selectPoint(Point point) {
    Point currentPoint = point,
        edgeA = new Point(currentlyDrawnSegment.path.first.dx,
            currentlyDrawnSegment.path.first.dy),
        edgeB = new Point(currentlyDrawnSegment.path.last.dx,
            currentlyDrawnSegment.path.last.dy);

    double threshold = 100,
        distanceToA = currentPoint.distanceTo(edgeA),
        distanceToB = currentPoint.distanceTo(edgeB);

    if (distanceToA < distanceToB && distanceToA < threshold) {
      currentlyDrawnSegment.selectedEdge =
          new Offset(edgeA.x.toDouble(), edgeA.y.toDouble());
    } else if (distanceToB < distanceToA && distanceToB < threshold) {
      currentlyDrawnSegment.selectedEdge =
          new Offset(edgeB.x.toDouble(), edgeB.y.toDouble());
    } else {}
    notifyListeners();
  }

  Segment getNearestSegment(DragDownDetails details) {
    return _allPathsController.getNearestSegment(details);
  }

  void clear() {
    currentlyDrawnSegment =
    new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);

  }
}

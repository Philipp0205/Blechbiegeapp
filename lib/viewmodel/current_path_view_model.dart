import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:open_bsp/services/viewmodel_locator.dart';

import '../model/appmodes.dart';
import '../model/segment.dart';
import '../services/segment_data_service.dart';
import 'modes_controller_view_model.dart';

class CurrentPathViewModel extends ChangeNotifier {
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;

  ModesViewModel _modesViewModel = getIt<ModesViewModel>();

  SegmentDataService _segmentDataService = getIt<SegmentDataService>();

  Segment get currentlyDrawnSegment =>
      _segmentDataService.currentlyDrawnSegment;

  List<Segment> get segments => _segmentDataService.segments;

  void setCurrentlyDrawnSegment(Offset offset) {
    _segmentDataService.setCurrentlyDrawnSegment(offset);
  }

  void changeSelectedSegmentDependingNewOffset(Offset newOffset) {
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

  void updateSegmentPointMode(Segment segment, Offset offset) {
    segment
      ..highlightPoints = true
      ..isSelected = true
      ..color = Colors.red;

    _segmentDataService.changeSegment(_segmentDataService.currentlyDrawnSegment, segment);
  }

  void addToPathOfCurrentlyDrawnSegment(Offset offset) {
    List<Offset> path =
        List.from(_segmentDataService.currentlyDrawnSegment.path)..add(offset);
    _segmentDataService.currentlyDrawnSegment =
        Segment(path, selectedColor, selectedWidth);
    _segmentDataService.updateCurrentSegmentLineStreamController();
    // currentLineStreamController.add(currentlyDrawnSegment);
    notifyListeners();
  }

  void changeSelectedSegment(Segment segment) {
    // if (this.currentlyDrawnSegment != segment) {
    currentlyDrawnSegment
      ..isSelected = false
      ..color = Colors.black;

    segment
      ..isSelected = true
      ..color = Colors.red;

    _segmentDataService.currentlyDrawnSegment = segment;

    addToCurrentLineStreamController(segment);
    notifyListeners();
    // }
  }

  void addToCurrentLineStreamController(Segment segment) {
    _segmentDataService.currentSegmentStreamController.add(segment);
    notifyListeners();
  }

  /// Merges end points of segments when distance is below threshold.
  void mergeSegmentsIfNearToEachOther(Segment segment, double threshold) {
    Map<Offset, Segment> segmentMap = new Map();

    segments.forEach((element) {
      if (element != segment) {
        segmentMap.putIfAbsent(element.path.first, () => element);
        segmentMap.putIfAbsent(element.path.last, () => element);
      }
    });

    for (MapEntry<Offset, Segment> e in segmentMap.entries) {
      Segment? mergedSegment;
      if ((e.key - segment.path.first).distance < threshold) {
        mergedSegment =
            mergeSegments(e.value, segment, e.key, segment.path.first);
      }
      if ((e.key - segment.path.last).distance < threshold) {
        mergedSegment =
            mergeSegments(e.value, segment, e.key, segment.path.last);
      }

      if (mergedSegment != null) {
        changeSelectedSegment(e.value);
      }

      break;

      // for (Segment currentSegment in segments) {
      //   List<Offset> offsetsCurrentSegment = [
      //     currentSegment.path.first,
      //     currentSegment.path.last
      //   ];
      //   if (currentSegment.path != segment.path) {
      //     for (Offset offsetOfCurrentSegment in offsetsCurrentSegment) {
      //       for (Offset offsetOfSegment in [
      //         segment.path.first,
      //         segment.path.last
      //       ]) {
      //         if ((offsetOfCurrentSegment - offsetOfSegment).distance <
      //             threshold) {
      //           Segment? mergedSegment = mergeSegments(currentSegment, segment,
      //               offsetOfCurrentSegment, offsetOfSegment);
      //           if (mergedSegment != null) {
      //             changeSelectedSegment(currentSegment);
      //           }
    }
    // break;
    // }
    // }
    // }
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

    _modesViewModel.setSelectedMode(Modes.defaultMode);
    return null;
  }

  void clearCurrentLine() {
    _segmentDataService.currentlyDrawnSegment =
        Segment([new Offset(0, 0)], selectedColor, selectedWidth);
    _segmentDataService.currentSegmentStreamController.add(currentlyDrawnSegment);
    notifyListeners();
  }

  void unselectCurrentLine() {
    currentlyDrawnSegment.isSelected = false;
    currentlyDrawnSegment.selectedEdge = new Offset(0, 0);
    currentlyDrawnSegment.color = Colors.black;
    _segmentDataService.currentSegmentStreamController.add(currentlyDrawnSegment);
    notifyListeners();
  }

  Segment straigthenSegment(Segment segment) {
    clearCurrentLine();
    return new Segment(
        [segment.path.first, segment.path.last], selectedColor, selectedWidth);
  }

  void updateSegment(Segment segment) {
    segments.add(segment);
    _segmentDataService.currentSegmentStreamController.add(segment);
    // _allPathsController
    //   ..deleteSegment(currentlyDrawnSegment)
    //   ..addSegment(segment);

    _segmentDataService.currentlyDrawnSegment = segment;

    segment
      ..setIsSelected(null)
      ..isSelected = true;

    notifyListeners();
  }

  void addSegment(Segment segment) {
    // _allPathsController.addSegment(segment);
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

  void clear() {
    _segmentDataService.currentlyDrawnSegment =
        new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
  }

  Segment getNearestSegment(DragDownDetails details) {
    Map<Segment, double> distances = {};

    _segmentDataService.segments.forEach((line) {
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
}

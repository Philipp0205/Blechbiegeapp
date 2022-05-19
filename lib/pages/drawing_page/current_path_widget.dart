import 'dart:math';

import 'package:flutter/material.dart';
import 'package:open_bsp/pages/drawing_page/bottom_sheet.dart';
import 'package:open_bsp/controller/sketcher_controller.dart';
import 'package:provider/provider.dart';

import '../../model/appmodes.dart';
import '../../model/segment.dart';
import '../../services/controller_locator.dart';
import 'sketcher.dart';

class CurrentPathWidget extends StatefulWidget {
  // final Modes selectedMode;
  // final Segment segment;
  // final List<Segment> model.segments;

  const CurrentPathWidget();

  @override
  _CurrentPathWidgetState createState() => _CurrentPathWidgetState();
}

class _CurrentPathWidgetState extends State<CurrentPathWidget> {
  GlobalKey key = new GlobalKey();

  SketcherController controller = getIt<SketcherController>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SketcherController>(
      create: (context) => controller,
      child: GestureDetector(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onPanDown: onPanDown,
        child: RepaintBoundary(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(4.0),
              color: Colors.transparent,
              alignment: Alignment.topLeft,
              child: StreamBuilder<Segment>(
                stream: controller.currentLineStreamController.stream,
                builder: (context, snapshot) {
                  return CustomPaint(
                    painter: Sketcher(
                      lines: [controller.currentlyDrawnSegment],
                      // lines: lines,
                    ),
                  );
                },
              )),
        ),
      ),
    );
  }

  /// Logic when user starts drawing in the canvas.
  void onPanStart(DragStartDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset offset = new Offset(point.dx, point.dy);

    switch (controller.selectedMode) {
      case Modes.defaultMode:
        onPanStartWithDefaultMode(offset);
        break;
      case Modes.pointMode:
        onPanStartWithPointMode(details, offset);
        break;
      case Modes.selectionMode:
        break;
    }
  }

  void onPanStartWithDefaultMode(Offset offset) {
    controller.setCurrentlyDrawnSegment(offset);
  }

  void onPanStartWithPointMode(DragStartDetails details, Offset offset) {
    controller.changeSelectedSegmentDependingNewOffset(
        controller.selectedSegment.selectedEdge, offset);
  }

  /// Logic when user continuous drawing in the canvas while holding down finger.
  void onPanUpdate(DragUpdateDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);

    switch (controller.selectedMode) {
      case Modes.defaultMode:
        onPanUpdateWithSelectionMode(point2);
        break;
      case Modes.pointMode:
        onPanUpdateWithPointMode(point2);
        break;
      case Modes.selectionMode:
        onPanUpdateWithSelectionMode(point2);
        break;
    }
  }

  void onPanUpdateWithSelectionMode(Offset offset) {
    controller.addToPathOfCurrentlyDrawnSegment(offset);
  }

  void onPanUpdateWithPointMode(Offset newOffset) {
    controller.changeSelectedSegmentDependingNewOffset(
        controller.selectedSegment.selectedEdge, newOffset);

    controller.mergeSegmentsIfNearToEachOther(controller.selectedSegment, 30);

  }

  /// Logic when user stops drawing in the canvas.
  void onPanEnd(DragEndDetails details) {
    switch (controller.selectedMode) {
      case Modes.defaultMode:
        onPanEndWithDefaultMode();
        break;
      case Modes.pointMode:
        onPanEndWithPointMode();
        break;
      case Modes.selectionMode:
        break;
    }
  }

  void onPanEndWithPointMode() {}

  void onPanEndWithDefaultMode() {
    controller.currentlyDrawnSegment =
        controller.straigthenSegment(controller.currentlyDrawnSegment);
    controller.addSegment(controller.currentlyDrawnSegment);

    controller.updateLinesStreamController();
  }

  void onPanDown(DragDownDetails details) {
    if (controller.selectedMode == Modes.selectionMode) {
      selectSegment(details);
    }
    if (controller.selectedMode == Modes.pointMode) {
      // selectEdge(details);
      controller.selectPoint(
          new Point(details.globalPosition.dx, details.globalPosition.dy - 80));
    }
  }

  void changeSelectedSegment(Segment segment) {
    setState(() {
      if (controller.selectedSegment != segment) {
        controller.selectedSegment.isSelected = false;
        segment.isSelected = true;
        controller.selectedSegment.color = Colors.black;
        controller.selectedSegment = segment;
      }
    });
  }

  Segment getNearestSegment(DragDownDetails details) {
    Map<Segment, double> distances = {};

    controller.segments.forEach((line) {
      distances.addEntries([MapEntry(line, getDistanceToLine(details, line))]);
    });

    var mapEntries = distances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    distances
      ..clear()
      ..addEntries(mapEntries);

    return distances.keys.toList().first;
  }

  Offset getNearestPoint(DragDownDetails details) {
    Segment nearestSegment = getNearestSegment(details);
    Offset nearestEdge;

    Point currentPoint =
            new Point(details.globalPosition.dx, details.globalPosition.dy),
        edgeA = new Point(
            nearestSegment.path.first.dx, nearestSegment.path.first.dy),
        edgeB =
            new Point(nearestSegment.path.last.dx, nearestSegment.path.last.dy);

    currentPoint.distanceTo(edgeA) > currentPoint.distanceTo(edgeB)
        ? nearestEdge = nearestSegment.path.last
        : nearestEdge = nearestSegment.path.first;

    return nearestEdge;
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

  Segment init(DragStartDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    return Segment([point], controller.selectedColor, controller.selectedWidth);
  }

  void extendSegment(Segment line, double length) {
    // deleteLine(line);
    Point pointA = new Point(line.path.first.dx, line.path.first.dy);
    Point pointB = new Point(line.path.last.dx, line.path.last.dy);

    double lengthAB = pointA.distanceTo(pointB);

    double x = pointB.x + (pointB.x - pointA.x) / lengthAB * length;
    double y = pointB.y + (pointB.y - pointA.y) / lengthAB * length;

    Offset pointC = new Offset(x, y);
    Segment newLine = new Segment([line.path.first, pointC],
        controller.selectedColor, controller.selectedWidth);

    controller.currentlyDrawnSegment = newLine;
  }

  void selectSegment(DragDownDetails details) {
    Segment nearestSegment = controller.getNearestSegment(details);
    if (nearestSegment != controller.selectedSegment) {
      controller.changeSelectedSegment(nearestSegment);
    }

    showModalBottomSheet(
      enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return AppBottomSheet();
      },
    );
  }
}

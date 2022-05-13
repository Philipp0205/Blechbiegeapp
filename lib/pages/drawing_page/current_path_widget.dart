import 'dart:math';

import 'package:flutter/material.dart';
import 'package:open_bsp/pages/drawing_page/bottom_sheet.dart';
import 'package:open_bsp/view_model/sketcher_data_service.dart';
import 'package:provider/provider.dart';

import '../../model/appmodes.dart';
import '../../model/segment.dart';
import '../../services/service_locator.dart';
import '../../sketcher.dart';

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

  Segment selectedSegment =
      new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);

  SketcherDataViewModel model = getIt<SketcherDataViewModel>();

  @override
  Widget build(BuildContext context) {
    print('build selectedMode: ${model.selectedMode}');
    print('build selectedMode: ${model.segments.length}');
    return ChangeNotifierProvider<SketcherDataViewModel>(
      create: (context) => model,
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
                stream: model.currentLineStreamController.stream,
                builder: (context, snapshot) {
                  return CustomPaint(
                    painter: Sketcher(
                      lines: [model.segment],
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
    // Compensate height of AppBar
    Offset offset = new Offset(point.dx, point.dy);

    switch (model.selectedMode) {
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

  void onPanStartWithPointMode(DragStartDetails details, Offset offset) {
    print('onPanStart with edgeMode');
    selectPoint(details);
    Offset newOffset = new Offset(offset.dx, offset.dy);

    model.deleteSegment(model.selectedSegment);

    Segment newSegment = createNewSegmentDependingOnSelectedPoint(
        selectedSegment.selectedEdge, newOffset);
    newSegment.selectedEdge = newOffset;
    newSegment.isSelected = true;

    model.setSegment(newSegment);
    model.setSelectedSegment(newSegment);

  }

  void onPanStartWithDefaultMode(Offset offset) {
    print('onPanStart with default Mode');
    model.segment = Segment([offset], model.selectedColor, model.selectedWidth);
    // print('onPanStart with default Mode');
    // Segment segment = Segment([offset], model.selectedColor, model.selectedWidth);
    // model.setSegment(segment);
    // model.currentLineStreamController.add(segment);
  }

  Segment createNewSegmentDependingOnSelectedPoint(
      Offset selectedEdge, Offset newOffset) {
    Segment segment;

    selectedSegment.selectedEdge == selectedSegment.path.first
        ? segment = new Segment([newOffset, selectedSegment.path.last],
            model.selectedColor, model.selectedWidth)
        : segment = new Segment([selectedSegment.path.first, newOffset],
            model.selectedColor, model.selectedWidth);

    return segment;
  }

  /// Logic when user continuous drawing in the canvas while holding down finger.
  void onPanUpdate(DragUpdateDetails details) {
    print('onPanUpdate');
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);

    switch (model.selectedMode) {
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

  void onPanUpdateWithPointMode(Offset offset) {
    print('PanUpdate with edgeMode');

    Segment segment = createNewSegmentDependingOnSelectedPoint(
        selectedSegment.selectedEdge, offset);

    model.segment = segment;
    selectedSegment = segment;
    selectedSegment.selectedEdge = offset;
    segment.highlightPoints = true;
    segment.isSelected = true;
    model.addToCurrentLineStreamController(segment);
    // model.currentLineStreamController.add(segment);
  }

  void onPanUpdateWithSelectionMode(Offset offset) {
    print('PanUpdate with selectionMode or defaultMode');
    model.addToPathOfSegment(offset);
  }

  /// Logic when user stops drawing in the canvas.
  void onPanEnd(DragEndDetails details) {
    switch (model.selectedMode) {
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

  void onPanEndWithPointMode() {
    print('onPanEnd with edgeMode');
    model.segment.isSelected = true;
    selectedSegment.selectedEdge = new Offset(0, 0);

    model.addSegment(model.segment);
  }

  void onPanEndWithDefaultMode() {
    model.segments = List.from(model.segments)..add(model.segment);

    this.model.segments = model.segments;
    model.segment = new Segment(
        [new Offset(0, 0)], model.selectedColor, model.selectedWidth);

    model.linesStreamController.add(model.segments);
  }

  void onPanDown(DragDownDetails details) {
    print('onPanDown');
    print('mode: ${model.selectedMode}');
    if (model.selectedMode == Modes.selectionMode) {
      selectSegment(details);
    }
    if (model.selectedMode == Modes.pointMode) {
      // selectEdge(details);
    }
  }

  void getSeleectedEdge(DragDownDetails detials) {}

  void selectEdge(DragDownDetails details) {
    print('Select edge');
    Point currentPoint =
            new Point(details.globalPosition.dx, details.globalPosition.dy),
        edgeA = new Point(
            selectedSegment.path.first.dx, selectedSegment.path.first.dy),
        edgeB = new Point(
            selectedSegment.path.last.dx, selectedSegment.path.last.dy);

    double threshold = 100;
    double distanceToA = currentPoint.distanceTo(edgeA);
    double distanceToB = currentPoint.distanceTo(edgeB);

    if (distanceToA < distanceToB &&
        (distanceToA < threshold || distanceToB < threshold)) {
      selectedSegment.selectedEdge =
          new Offset(edgeA.x.toDouble(), edgeA.y.toDouble());
    } else {
      selectedSegment.selectedEdge =
          new Offset(edgeB.x.toDouble(), edgeB.y.toDouble());
    }
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
    print('Point A: ${edgeA.x} / ${edgeA.y}');
    print('Point B: ${edgeB.x} / ${edgeB.y}');
    print('distance to A: $distanceToA');
    print('distance to B: $distanceToB');

    if (distanceToA < distanceToB &&
        (distanceToA < threshold || distanceToB < threshold)) {
      selectedSegment.selectedEdge =
          new Offset(edgeA.x.toDouble(), edgeA.y.toDouble());
      print('selectedEdge is ${selectedSegment.selectedEdge}');
    } else {
      selectedSegment.selectedEdge =
          new Offset(edgeB.x.toDouble(), edgeB.y.toDouble());
      print('selectedEdge is ${selectedSegment.selectedEdge}');
    }
  }

  void changeSelectedSegment(Segment segment) {
    print('changeSelectedSegment');
    setState(() {
      if (selectedSegment != segment) {
        selectedSegment.isSelected = false;
        segment.isSelected = true;
        selectedSegment.color = Colors.black;
        selectedSegment = segment;
      }
    });
  }

  Segment getNearestSegment(DragDownDetails details) {
    Map<Segment, double> distances = {};

    model.segments.forEach((line) {
      distances.addEntries([MapEntry(line, getDistanceToLine(details, line))]);
    });

    var mapEntries = distances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    distances
      ..clear()
      ..addEntries(mapEntries);

    return distances.keys.toList().first;
  }

  Offset getNearestEdge(DragDownDetails details) {
    print('getNearestEdge');
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
    return Segment([point], model.selectedColor, model.selectedWidth);
  }

  void extendSegment(Segment line, double length) {
    // deleteLine(line);
    Point pointA = new Point(line.path.first.dx, line.path.first.dy);
    Point pointB = new Point(line.path.last.dx, line.path.last.dy);

    double lengthAB = pointA.distanceTo(pointB);

    double x = pointB.x + (pointB.x - pointA.x) / lengthAB * length;
    double y = pointB.y + (pointB.y - pointA.y) / lengthAB * length;

    Offset pointC = new Offset(x, y);
    Segment newLine = new Segment(
        [line.path.first, pointC], model.selectedColor, model.selectedWidth);

    model.segment = newLine;
  }

  void selectSegment(DragDownDetails details) {
    Segment nearestSegment = model.getNearestSegment(details);
    model.changeSelectedSegment(nearestSegment);

    showModalBottomSheet(
      enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return AppBottomSheet();
      },
    );
  }
}

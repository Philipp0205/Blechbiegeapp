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
    print('onPanStart');
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
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

  void onPanStartWithDefaultMode(Offset offset) {
    model.setSegment(
        Segment([offset], model.selectedColor, model.selectedWidth));
  }

  void onPanStartWithPointMode(DragStartDetails details, Offset offset) {
    if (model.selectedSegment.selectedEdge != null) {
      Offset newOffset = new Offset(offset.dx, offset.dy);

      Segment newSegment = createNewSegmentDependingOnSelectedPoint(
          model.selectedSegment.selectedEdge, newOffset);

      model.deleteSegment(model.selectedSegment);
      model.setSelectedSegment(newSegment, newOffset);
      model.updateSegment(newSegment);
    }
  }

  Segment createNewSegmentDependingOnSelectedPoint(
      Offset? selectedEdge, Offset newOffset) {
    print('createNewSEgmentDependingOnSelectedPoint');

    Segment segment;

    model.selectedSegment.selectedEdge == model.selectedSegment.path.first
        ? segment = new Segment([model.selectedSegment.path.last, newOffset],
            model.selectedColor, model.selectedWidth)
        : segment = new Segment([newOffset, model.selectedSegment.path.first],
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

  void onPanUpdateWithSelectionMode(Offset offset) {
    print('PanUpdate with selectionMode or defaultMode');
    model.addToPathOfSegment(offset);
  }

  void onPanUpdateWithPointMode(Offset offset) {
    print('PanUpdate with edgeMode');

    // selectEdge2(new Point(offset.dx, offset.dy));

    Segment segment = createNewSegmentDependingOnSelectedPoint(
        model.selectedSegment.selectedEdge, offset);

    segment.selectedEdge = offset;
    segment.highlightPoints = true;
    segment.isSelected = true;

    print('Selected segment: ${model.selectedSegment.path}');
    print('New selected segment: ${model.selectedSegment.path}');

    // model.addToPathOfSegment(offset);
    // model.setSegment(segment);
    model.deleteSegment(model.selectedSegment);

    model.setSegment(segment);
    model.setSelectedSegment(segment, offset);
    model.updateSegment(segment);
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
    //  model.segment.isSelected = true;
    // model.selectedSegment.selectedEdge = new Offset(0, 0);
    //
    // model.addSegment(model.segment);
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
      print('onPanDownwithPointMode');
      // selectEdge(details);
      selectEdge(
          new Point(details.globalPosition.dx, details.globalPosition.dy - 80));
    }
  }

  void selectEdge(Point point) {
    print('Select edge2');
    Point currentPoint = point,
        edgeA = new Point(model.selectedSegment.path.first.dx,
            model.selectedSegment.path.first.dy),
        edgeB = new Point(model.selectedSegment.path.last.dx,
            model.selectedSegment.path.last.dy);

    double threshold = 100,
        distanceToA = currentPoint.distanceTo(edgeA),
        distanceToB = currentPoint.distanceTo(edgeB);

    if (distanceToA < distanceToB && distanceToA < threshold) {
      model.selectedSegment.selectedEdge =
          new Offset(edgeA.x.toDouble(), edgeA.y.toDouble());
      print('selectedPoint is $edgeA');
    } else if (distanceToB < distanceToA && distanceToB < threshold) {
      model.selectedSegment.selectedEdge =
          new Offset(edgeB.x.toDouble(), edgeB.y.toDouble());
      print('selectedPoint is $edgeB');
    } else {
      model.selectedSegment.selectedEdge = null;
    }
  }

  void changeSelectedSegment(Segment segment) {
    print('changeSelectedSegment');
    setState(() {
      if (model.selectedSegment != segment) {
        model.selectedSegment.isSelected = false;
        segment.isSelected = true;
        model.selectedSegment.color = Colors.black;
        model.selectedSegment = segment;
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

  Offset getNearestPoint(DragDownDetails details) {
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

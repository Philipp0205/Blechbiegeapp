import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:open_bsp/model/sketcher_data.dart';
import 'package:open_bsp/view_model/sketcher_data_service.dart';
import 'package:provider/provider.dart';

import '../../model/appmodes.dart';
import '../../model/segment.dart';
import '../../services/service_locator.dart';
import '../../sketcher.dart';

class CurrentPathWidget extends StatefulWidget {
  // final Modes selectedMode;
  // final Segment segment;
  // final List<Segment> viewModel.segments;

const CurrentPathWidget();

  @override
  _CurrentPathWidgetState createState() => _CurrentPathWidgetState();
}

class _CurrentPathWidgetState extends State<CurrentPathWidget> {
  StreamController<Segment> currentLineStreamController =
      StreamController<Segment>.broadcast();

  StreamController<List<Segment>> linesStreamController =
      StreamController<List<Segment>>.broadcast();

  SketcherData data = new SketcherData();

  GlobalKey key = new GlobalKey();

  Segment selectedSegment =
      new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);

  SketcherDataViewModel viewModel = getIt<SketcherDataViewModel>();

  @override
  Widget build(BuildContext context) {
    viewModel.segments = viewModel.segments;
    print('build selectedMode: ${viewModel.selectedMode}');
    print('build selectedMode: ${viewModel.segments.length}');
    return GestureDetector(
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
              stream: currentLineStreamController.stream,
              builder: (context, snapshot) {
                return ChangeNotifierProvider(
                    create: (context) => viewModel,
                    child: CustomPaint(
                      painter: Sketcher(
                        lines: [viewModel.segment],
                        // lines: lines,
                      ),
                    ));
              },
            )),
      ),
    );
  }

  /// Logic when user starts drawing in the canvas.
  void onPanStart(DragStartDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    // Compensate height of AppBar
    Offset offset = new Offset(point.dx, point.dy);

    switch (data.selectedMode) {
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

    Segment newSegment = createNewSegmentDependingOnSelectedPoint(
        selectedSegment.selectedEdge, newOffset);

    deleteSegment(selectedSegment);

    newSegment.selectedEdge = newOffset;
    newSegment.isSelected = true;

    viewModel.segment = newSegment;
    selectedSegment = newSegment;
  }

  void onPanStartWithDefaultMode(Offset offset) {
    print('onPanStart with default Mode');
    viewModel.segment = Segment([offset], data.selectedColor, data.selectedWidth);
  }

  Segment createNewSegmentDependingOnSelectedPoint(
      Offset selectedEdge, Offset newOffset) {
    Segment segment;

    selectedSegment.selectedEdge == selectedSegment.path.first
        ? segment = new Segment([newOffset, selectedSegment.path.last],
            data.selectedColor, data.selectedWidth)
        : segment = new Segment([selectedSegment.path.first, newOffset],
            data.selectedColor, data.selectedWidth);

    return segment;
  }

  /// Logic when user continuous drawing in the canvas while holding down finger.
  void onPanUpdate(DragUpdateDetails details) {
    print('onPanUpdate');
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);

    switch (data.selectedMode) {
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

    viewModel.segment = segment;
    selectedSegment = segment;
    selectedSegment.selectedEdge = offset;
    segment.highlightPoints = true;
    segment.isSelected = true;
    currentLineStreamController.add(segment);
  }

  void onPanUpdateWithSelectionMode(Offset offset) {
    print('PanUpdate with selectionMode or defaultMode');
    print('viewModel.segments: ${viewModel.segments.length}');
    List<Offset> path = List.from(viewModel.segment.path)..add(offset);
    viewModel.segment = Segment(path, data.selectedColor, data.selectedWidth);
    currentLineStreamController.add(viewModel.segment);
  }

  /// Logic when user stops drawing in the canvas.
  void onPanEnd(DragEndDetails details) {
    switch (data.selectedMode) {
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
    viewModel.segment.isSelected = true;
    selectedSegment.selectedEdge = new Offset(0, 0);

    viewModel.segments = List.from(viewModel.segments)..add(viewModel.segment);
    linesStreamController.add(viewModel.segments);
  }

  void onPanEndWithDefaultMode() {
    viewModel.segments = List.from(viewModel.segments)..add(viewModel.segment);

    // List<Segment> straightviewModel.segments = straightenviewModel.segments(viewModel.segments);
    // this.viewModel.segments = straightviewModel.segments;
    // print('straightviewModel.segments ${straightviewModel.segments.length}');
    this.viewModel.segments = viewModel.segments;
    viewModel.segment =
        new Segment([new Offset(0, 0)], data.selectedColor, data.selectedWidth);

    linesStreamController.add(viewModel.segments);
  }

  void onPanDown(DragDownDetails details) {
    print('onPanDown');
    if (data.selectedMode == Modes.selectionMode) {
      selectSegment(details);
    }
    if (data.selectedMode == Modes.pointMode) {
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

    viewModel.segments.forEach((line) {
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
    return Segment([point], data.selectedColor, data.selectedWidth);
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
        [line.path.first, pointC], data.selectedColor, data.selectedWidth);

    viewModel.segment = newLine;

    // DrawnLine newLine = new DrawnLine([
    //   line.path.first,
    //   Offset(line.path.last.dx + length, line.path.last.dy + length)
    // ], data.selectedColor, data.selectedWidth);
    //
    // this.line = newLine;
  }

  void deleteSegment(Segment segment) {
    setState(() {
      Segment line = viewModel.segments
          .firstWhere((currentSegment) => currentSegment.path == segment.path);
      viewModel.segments.remove(line);
    });
  }

  void saveLine(Segment line) {
    viewModel.segments.add(selectedSegment);
    deleteSegment(selectedSegment);
  }

  void selectSegment(DragDownDetails details) {
    print('selectSegment');
    Segment lowestDistanceLine = getNearestSegment(details);
    lowestDistanceLine.color = Colors.red;
    changeSelectedSegment(lowestDistanceLine);

    _bottomSheet(context, lowestDistanceLine);
  }

  _bottomSheet(BuildContext context, Segment selectedLine) {
    double _currentSliderValue = selectedLine.width;

    showModalBottomSheet(
      enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: StatefulBuilder(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(padding: EdgeInsets.all(10), child: Text('Länge')),
                  Slider(
                    value: _currentSliderValue,
                    max: selectedLine.width + 100,
                    divisions: 5,
                    min: selectedLine.width - 100,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      state(() {
                        _currentSliderValue = value;
                        extendSegment(selectedLine, _currentSliderValue);
                      });
                      setState(() {});
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              deleteSegment(selectedLine);
                            },
                            child: const Text('Löschen')),
                        // Container(
                        //   width: 80,
                        //   child: TextField(
                        //     keyboardType: TextInputType.number,
                        //   ),
                        // ),
                        ElevatedButton(
                            onPressed: () {
                              context
                                  .read<AppModes>()
                                  .setSelectedMode(Modes.pointMode);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Edge M.')),
                        ElevatedButton(
                            onPressed: () {
                              saveLine(selectedLine);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Speichern')),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

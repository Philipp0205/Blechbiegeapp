import 'dart:async';

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../draw_line.dart';
import '../sketcher.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  StreamController<Segment> currentLineStreamController =
      StreamController<Segment>.broadcast();

  StreamController<List<Segment>> linesStreamController =
      StreamController<List<Segment>>.broadcast();

  GlobalKey key = new GlobalKey();

  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;
  GlobalKey _globalKey = new GlobalKey();
  bool selectionMode = false;
  bool edgeMode = false;
  String modeText = '';

  List<Segment> segments = [];
  Segment segment =
      new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
  Segment selectedSegment =
      new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Biegeapp'), Text(modeText)],
        ),
      ),
      backgroundColor: Colors.yellow[50],
      body: Container(
        child: Stack(
            children: [buildAllPaths(context), buildCurrentPath(context)]),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(child: Icon(Icons.delete), onTap: clear),
          SpeedDialChild(
              child: Icon(Icons.arrow_forward), onTap: straightenLines),
          SpeedDialChild(
              child: Icon(Icons.select_all), onTap: toggleSelectionMode),
          SpeedDialChild(child: Icon(Icons.circle), onTap: debugFunction),
        ],
      ),
    );
  }

  Future<void> clear() async {
    setState(() {
      segments = [];
      segment = new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
      selectedSegment =
          new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
    });
  }

  straightenLines() {
    setState(() {
      List<Segment> straigtenedLines = [];
      print('lines.lenght ${segments.length}');

      segments.forEach((line) {
        straigtenedLines.add(new Segment(
            [line.path.first, line.path.last], selectedColor, selectedWidth));
      });

      segments = straigtenedLines;
      segment = new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
    });
  }
  
  void debugFunction() {
    print('segments: ${segments.length}');
  }

  Widget buildCurrentPath(BuildContext buildContext) {
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
                return CustomPaint(
                  painter: Sketcher(
                    lines: [segment],
                    // lines: lines,
                  ),
                );
              },
            )),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    print('onPanStart');
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy - 80);

    if (!selectionMode) {
      segment = Segment([point2], selectedColor, selectedWidth);
    }
    if (edgeMode) {
      print('onPanStart with edgeMode');
      Segment segment = new Segment(
          [new Offset(point2.dx, point2.dy), selectedSegment.path.last],
          selectedColor,
          selectedWidth);
      this.segment = segment;
      segment.isSelected = true;
      deleteSegment(selectedSegment);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    print('onPanUpdate');
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy - 80);

    if (!selectionMode && !edgeMode) {
      print('PanUpdate with selectionMode');
      List<Offset> path = List.from(segment.path)..add(point2);
      segment = Segment(path, selectedColor, selectedWidth);
      currentLineStreamController.add(segment);
    }
    if (edgeMode) {
      print('PanUpdate with edgeMode');
      Segment segment = new Segment(
          [new Offset(point2.dx, point2.dy), selectedSegment.path.last],
          selectedColor,
          selectedWidth);
      this.segment = segment;
      // deleteSegment(selectedSegment);
      selectedSegment = segment;
      segment.edgeCoordinates = true;
      segment.isSelected = true;
      currentLineStreamController.add(segment);
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (!selectionMode | edgeMode) {
      print('onPanEnd with selectionMode');
      segments = List.from(segments)..add(segment);
      linesStreamController.add(segments);
    }

    if (edgeMode) {
      // toggleEdgeMode();
    }
  }

  void onPanDown(DragDownDetails details) {
    if (selectionMode ) {
      print('selectionMode ${selectionMode}');
      selectSegment(details);
    }
    if (edgeMode == true) {
      print('edgeMode ${edgeMode}');
      selectEdge(details);
    }
  }

  void selectSegment(DragDownDetails details) {
    print('selectSegment');
    Segment lowestDistanceLine = getNearestSegment(details);
    lowestDistanceLine.color = Colors.red;
    changeSelectedSegment(lowestDistanceLine);

    _bottomSheet(context, lowestDistanceLine);
  }

  void selectEdge(DragDownDetails details) {
    print('Select edge');
    Point currentPoint = new Point(
            details.globalPosition.dx, details.globalPosition.dy - 80),
        edgeA = new Point(
            selectedSegment.path.first.dx, selectedSegment.path.first.dy),
        edgeB = new Point(
            selectedSegment.path.last.dx, selectedSegment.path.last.dy);

    if (currentPoint.distanceTo(edgeA) < currentPoint.distanceTo(edgeB)) {
      selectedSegment.selectedEdge =
          new Offset(edgeA.x.toDouble(), edgeA.y.toDouble());
    } else {
      selectedSegment.selectedEdge =
          new Offset(edgeB.x.toDouble(), edgeB.y.toDouble());
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

  Offset getNearestEdge(DragDownDetails details) {
    print('getNearestEdge');
    Segment nearestSegment = getNearestSegment(details);
    Offset nearestEdge;

    Point currentPoint = new Point(
            details.globalPosition.dx, details.globalPosition.dy - 80),
        edgeA = new Point(
            nearestSegment.path.first.dx, nearestSegment.path.first.dy),
        edgeB =
            new Point(nearestSegment.path.last.dx, nearestSegment.path.last.dy);

    currentPoint.distanceTo(edgeA) > currentPoint.distanceTo(edgeB)
        ? nearestEdge = nearestSegment.path.last
        : nearestEdge = nearestSegment.path.first;

    print('nearestEdge = ${nearestEdge}');
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
        new Point(details.globalPosition.dx, details.globalPosition.dy - 80);
    Point startPoint = new Point(line.path.first.dx, line.path.first.dy);
    Point endPoint = new Point(line.path.last.dx, line.path.last.dy);

    return startPoint.distanceTo(currentPoint) +
        currentPoint.distanceTo(endPoint) -
        startPoint.distanceTo(endPoint);
  }

  Segment init(DragStartDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    return Segment([point], selectedColor, selectedWidth);
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        padding: EdgeInsets.all(4.0),
        alignment: Alignment.topLeft,
        child: StreamBuilder<List<Segment>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                lines: segments,
              ),
            );
          },
        ),
      ),
    );
  }

  void toggleSelectionMode() {
    if (selectionMode) {
      setState(() {
        modeText = '';
        selectionMode = false;
      });
    } else {
      setState(() {
        modeText = 'Selection Mode';
        selectionMode = true;
      });
    }
    print('selectionMode: ${selectionMode}');
  }

  void toggleEdgeMode() {
    if (edgeMode) {
      setState(() {
        modeText = '';
        edgeMode = false;
        selectionMode = false;
      });
    } else {
      setState(() {
        modeText = 'Edge Mode';
        edgeMode = true;
        selectionMode = false;
      });
    }
    print('edgeMode: ${edgeMode}');
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

    this.segment = newLine;

    // DrawnLine newLine = new DrawnLine([
    //   line.path.first,
    //   Offset(line.path.last.dx + length, line.path.last.dy + length)
    // ], selectedColor, selectedWidth);
    //
    // this.line = newLine;
  }

  void deleteSegment(Segment segment) {
    setState(() {
      Segment line = segments
          .firstWhere((currentSegment) => currentSegment.path == segment.path);
      segments.remove(line);
    });
  }

  void saveLine(Segment line) {
    segments.add(selectedSegment);
    deleteSegment(selectedSegment);
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
                              toggleEdgeMode();
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

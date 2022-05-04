import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../draw_line.dart';
import '../sketcher.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  StreamController<DrawnLine> currentLineStreamController =
      StreamController<DrawnLine>.broadcast();

  StreamController<List<DrawnLine>> linesStreamController =
      StreamController<List<DrawnLine>>.broadcast();

  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;
  GlobalKey _globalKey = new GlobalKey();
  bool selectionMode = false;
  String modeText = '';

  List<DrawnLine> lines = [];
  DrawnLine line =
      new DrawnLine([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
  DrawnLine selectedLine =
      new DrawnLine([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);

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
              child: Icon(Icons.select_all), onTap: toggleSelectionMode)
        ],
      ),
    );
  }

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = new DrawnLine([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
    });
  }

  straightenLines() {
    setState(() {
      List<DrawnLine> straigtenedLines = [];
      print('lines.lenght ${lines.length}');

      lines.forEach((line) {
        straigtenedLines.add(new DrawnLine(
            [line.path.first, line.path.last], selectedColor, selectedWidth));
      });

      lines = straigtenedLines;
      line = new DrawnLine([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);
    });
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
            child: StreamBuilder<DrawnLine>(
              stream: currentLineStreamController.stream,
              builder: (context, snapshot) {
                return CustomPaint(
                  painter: Sketcher(
                    lines: [line],
                    // lines: lines,
                  ),
                );
              },
            )),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    if (selectionMode) {
      RenderBox box = context.findRenderObject() as RenderBox;
      Offset point = box.globalToLocal(details.globalPosition);
      Offset point2 = new Offset(point.dx, point.dy - 80);
      line = DrawnLine([point2], selectedColor, selectedWidth);
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (selectionMode) {
      print('onPanEnd');
      lines = List.from(lines)..add(line);
      linesStreamController.add(lines);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (selectionMode) {
      RenderBox box = context.findRenderObject() as RenderBox;

      Offset point = box.globalToLocal(details.globalPosition);
      Offset point2 = new Offset(point.dx, point.dy - 80);

      List<Offset> path = List.from(line.path)..add(point2);
      line = DrawnLine(path, selectedColor, selectedWidth);
      currentLineStreamController.add(line);
    }
  }

  void onPanDown(DragDownDetails details) {
    if (selectionMode == false) {
      selectLine(details);
    }
  }

  void selectLine(DragDownDetails details) {
    DrawnLine lowestDistanceLine = getLowestDistanceLine(details);
    lowestDistanceLine.color = Colors.red;
    changeSelectedLine(lowestDistanceLine);
    _bottomSheet(context, lowestDistanceLine);
  }

  void changeSelectedLine(DrawnLine line) {
    setState(() {
      if (selectedLine != line) {
        selectedLine.color = Colors.black;
        selectedLine = line;
        line = line;
      }
    });
  }

  DrawnLine getLowestDistanceLine(DragDownDetails details) {
    Map<DrawnLine, double> distances = {};

    lines.forEach((line) {
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
  double getDistanceToLine(DragDownDetails details, DrawnLine line) {
    Point currentPoint =
        new Point(details.globalPosition.dx, details.globalPosition.dy - 80);
    Point startPoint = new Point(line.path.first.dx, line.path.first.dy);
    Point endPoint = new Point(line.path.last.dx, line.path.last.dy);

    return startPoint.distanceTo(currentPoint) +
        currentPoint.distanceTo(endPoint) -
        startPoint.distanceTo(endPoint);
  }

  DrawnLine init(DragStartDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    return DrawnLine([point], selectedColor, selectedWidth);
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
        child: StreamBuilder<List<DrawnLine>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                lines: lines,
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
        modeText = 'Selection Mode';
        selectionMode = false;
      });
    } else {
      setState(() {
        modeText = '';
        selectionMode = true;
      });
    }
  }

  void extendSegment(DrawnLine line, double length) {
    // deleteLine(line);
    Point pointA = new Point(line.path.first.dx, line.path.first.dy);
    Point pointB = new Point(line.path.last.dx, line.path.last.dy);

    double lengthAB = pointA.distanceTo(pointB);

    double x = pointB.x + (pointB.x - pointA.x) / lengthAB * length;
    double y = pointB.y + (pointB.y - pointA.y) / lengthAB * length;

    Offset pointC = new Offset(x, x);
    // DrawnLine newLine = new DrawnLine([pointC], currentColor, width)

    // DrawnLine newLine = new DrawnLine([
    //   line.path.first,
    //   Offset(line.path.last.dx + length, line.path.last.dy + length)
    // ], selectedColor, selectedWidth);
    //
    // this.line = newLine;
    //



  }

  void deleteLine(DrawnLine selectedLine) {
    DrawnLine line = lines.firstWhere((line) => line.path == selectedLine.path);
    lines.remove(line);
  }

  _bottomSheet(BuildContext context, DrawnLine selectedLine) {
    double _currentSliderValue = selectedLine.width;

    showModalBottomSheet(
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
                    max: selectedLine.width + 50,
                    divisions: 5,
                    min: selectedLine.width - 50,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      state(() {
                        _currentSliderValue = value;
                        extendSegment(selectedLine, _currentSliderValue);
                      });
                      setState(() {});
                    },
                  ),
                  Container(
                    width: 50,
                    child: TextField(
                      keyboardType: TextInputType.number,
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }
}

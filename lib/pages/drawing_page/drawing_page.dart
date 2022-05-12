import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_bsp/model/painter_data.dart';
import 'package:open_bsp/pages/drawing_page/current_path_widget.dart';

import '../../model/appmodes.dart';
import '../../model/segment.dart';
import '../../sketcher.dart';

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  StreamController<Segment> currentLineStreamController =
      StreamController<Segment>.broadcast();

  StreamController<List<Segment>> linesStreamController =
      StreamController<List<Segment>>.broadcast();

  GlobalKey key = new GlobalKey();
  PainterData data = new PainterData();
  GlobalKey _globalKey = new GlobalKey();
  
  Modes selectedMode = Modes.defaultMode;
  
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
          children: [
            Text('Biegeapp'),
            Text(AppModes().getModeName(selectedMode))
          ],
        ),
      ),
      backgroundColor: Colors.yellow[50],
      body: Container(
        child: Stack(
            children: [buildAllPaths(context),
              // buildCurrentPath(context),
              CurrentPathWidget(selectedMode)
            ]),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(child: Icon(Icons.delete), onTap: clear),
          SpeedDialChild(
              child: Icon(Icons.arrow_forward), onTap: straightenSegments),
          SpeedDialChild(
              child: Icon(Icons.select_all), onTap: toggleSelectionMode),
          SpeedDialChild(child: Icon(Icons.circle), onTap: toggleDefaultMode),
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
      selectedMode = Modes.defaultMode;
    });

  }

  straightenSegments() {
    setState(() {
      print('straightenSegments: ${segments.length} segments');
      List<Segment> straightSegments = [];

      segments.forEach((line) {
        straightSegments.add(new Segment(
            [line.path.first, line.path.last], data.selectedColor, data.selectedWidth));
      });

      this.segments = straightSegments;
    });
  }

  void debugFunction() {
    print('segments: ${segments.length}');
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
    setState(() {
      selectedMode = Modes.selectionMode;
    });
  }

  void toggleEdgeMode() {
    setState(() {
      selectedMode = Modes.pointMode;
    });
  }

  void toggleDefaultMode() {
    setState(() {
      Offset offset = new Offset(0, 0);
      selectedSegment.selectedEdge = offset;
      selectedSegment.isSelected = false;
      selectedMode = Modes.defaultMode;
    });
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
        new Segment([line.path.first, pointC], data.selectedColor, data.selectedWidth);

    this.segment = newLine;

    // DrawnLine newLine = new DrawnLine([
    //   line.path.first,
    //   Offset(line.path.last.dx + length, line.path.last.dy + length)
    // ], data.selectedColor, data.selectedWidth);
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




}

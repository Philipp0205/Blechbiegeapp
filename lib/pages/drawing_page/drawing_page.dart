import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_bsp/model/sketcher_data.dart';
import 'package:open_bsp/pages/drawing_page/current_path_widget.dart';
import 'package:open_bsp/view_model/sketcher_data_service.dart';
import 'package:provider/provider.dart';
import 'package:open_bsp/services/service_locator.dart';

import '../../model/appmodes.dart';
import '../../model/segment.dart';
import '../../sketcher.dart';

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {

  GlobalKey key = new GlobalKey();
  SketcherData data = new SketcherData();
  GlobalKey _globalKey = new GlobalKey();

  // List<Segment> segments = [];

  SketcherDataViewModel model =  getIt<SketcherDataViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Biegeapp'),
            Text(AppModes().getModeName(model.selectedMode))
          ],
        ),
      ),
      backgroundColor: Colors.yellow[50],
      body: Container(
        child: Stack(children: [
          buildAllPaths(context, model),
          // buildCurrentPath(context),
          CurrentPathWidget()
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
      model.clear();
    });
  }

  straightenSegments() {
    setState(() {
      print('straightenSegments: ${model.segments.length} segments');
      List<Segment> straightSegments = [];

      model.segments.forEach((line) {
        straightSegments.add(new Segment([line.path.first, line.path.last],
            data.selectedColor, data.selectedWidth));
      });

      this.model.segments = straightSegments;
    });
  }

  void debugFunction() {
    print('segments: ${model.segments.length}');
  }

  Widget buildAllPaths(BuildContext context, SketcherDataViewModel model) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        padding: EdgeInsets.all(4.0),
        alignment: Alignment.topLeft,
        child: StreamBuilder<List<Segment>>(
          stream: model.linesStreamController.stream,
          builder: (context, snapshot) {
            return ChangeNotifierProvider<SketcherDataViewModel>(
              create: (context) => model,
              child: CustomPaint(
                painter: Sketcher(
                  lines: model.segments,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void toggleSelectionMode() {
    setState(() {
      model.selectedMode = Modes.selectionMode;
      model.clearSegmentSelection(model.selectedSegment);
    });
  }

  void toggleEdgeMode() {
    setState(() {
      model.selectedMode = Modes.pointMode;
    });
  }

  void toggleDefaultMode() {
    setState(() {
      Offset offset = new Offset(0, 0);
      model.selectedSegment.selectedEdge = offset;
      model.selectedSegment.isSelected = false;
      model.selectedMode = Modes.defaultMode;
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
    Segment newLine = new Segment(
        [line.path.first, pointC], data.selectedColor, data.selectedWidth);

    model.segment = newLine;
  }



}

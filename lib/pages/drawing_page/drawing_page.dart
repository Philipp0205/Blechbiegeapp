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
  StreamController<List<Segment>> linesStreamController =
      StreamController<List<Segment>>.broadcast();

  GlobalKey key = new GlobalKey();
  SketcherData data = new SketcherData();
  GlobalKey _globalKey = new GlobalKey();

  Modes selectedMode = Modes.defaultMode;

  // List<Segment> segments = [];

  SketcherDataViewModel viewModel =  getIt<SketcherDataViewModel>();

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
        child: Stack(children: [
          buildAllPaths(context, viewModel),
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
    viewModel.clear();
  }

  straightenSegments() {
    setState(() {
      print('straightenSegments: ${viewModel.segments.length} segments');
      List<Segment> straightSegments = [];

      viewModel.segments.forEach((line) {
        straightSegments.add(new Segment([line.path.first, line.path.last],
            data.selectedColor, data.selectedWidth));
      });

      this.viewModel.segments = straightSegments;
    });
  }

  void debugFunction() {
    print('segments: ${viewModel.segments.length}');
  }

  Widget buildAllPaths(BuildContext context, SketcherDataViewModel viewModel) {
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
            return ChangeNotifierProvider<SketcherDataViewModel>(
              create: (context) => viewModel,
              child: CustomPaint(
                painter: Sketcher(
                  lines: viewModel.segments,
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
      viewModel.selectedSegment.selectedEdge = offset;
      viewModel.selectedSegment.isSelected = false;
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
    viewModel.segments.add(viewModel.selectedSegment);
    deleteSegment(viewModel.selectedSegment);
  }
}

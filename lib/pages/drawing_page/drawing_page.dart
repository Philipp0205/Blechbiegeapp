import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_bsp/pages/drawing_page/build_all_paths.dart';
import 'package:open_bsp/pages/drawing_page/current_path_widget.dart';
import 'package:open_bsp/services/controller_locator.dart';

import '../../controller/sketcher_controller.dart';
import '../../model/appmodes.dart';
import '../../model/segment.dart';

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {

  GlobalKey key = new GlobalKey();

  SketcherController controller =  getIt<SketcherController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Biegeapp'),
            Text(AppModes().getModeName(controller.selectedMode))
          ],
        ),
      ),
      backgroundColor: Colors.yellow[50],
      body: Container(
        child: Stack(children: [
          BuildAllPaths(),
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
              child: Icon(Icons.select_all), onTap: toggleSelectionMode),
          SpeedDialChild(child: Icon(Icons.circle), onTap: controller.toggleDefaultMode),
        ],
      ),
    );
  }

  Future<void> clear() async {
    setState(() {
      controller.clear();
    });
  }

  void toggleSelectionMode() {
    setState(() {
      controller.toggleSelectionMode();
    });
  }

  void debugFunction() {
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
        [line.path.first, pointC], controller.selectedColor, controller.selectedWidth);

    controller.currentlyDrawnSegment = newLine;
  }



}

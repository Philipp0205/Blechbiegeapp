import 'dart:ui';

import 'package:flutter/material.dart';

import 'draw_line.dart';

class Sketcher extends CustomPainter {
  final List<Segment> lines;

  Sketcher({required this.lines});

  final PictureRecorder pictureRecorder = new PictureRecorder();
  late Canvas recordingCanvas;
  late Canvas canvas;

  Segment selectedSegment =
      new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);

  @override
  void paint(Canvas canvas, Size size) {
    canvas = canvas;
    recordingCanvas = new Canvas(pictureRecorder);

    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < lines.length; ++i) {
      if (lines[i] == null) continue;
      for (int j = 0; j < lines[i].path.length - 1; ++j) {
        if (lines[i].path[j] != null && lines[i].path[j + 1] != null) {
          paint.color = lines[i].color;
          paint.strokeWidth = lines[i].width;
          canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);

          toggleSegmentSelection(lines[i], canvas);
          // toggleEdgeSelection(lines[i], canvas);
          if (lines[i].selectedEdge.dx != 0) {
            toggleEdgeSelection(lines[i], canvas);
          }
        }
      }
    }
  }

  void toggleSegmentSelection(Segment line, Canvas canvas) {
    Paint paint = Paint()
      ..color = Colors.blueAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    if (line.isSelected) {
      canvas.drawCircle(line.path.first, 10, paint);
      canvas.drawCircle(line.path.last, 10, paint);
    } else {
      paint.color = Colors.yellow[50] as Color;
      canvas.drawCircle(line.path.first, 10, paint);
      canvas.drawCircle(line.path.last, 10, paint);
    }
  }

  void toggleEdgeSelection(Segment line, Canvas canvas) {
    Paint paint = Paint()
      ..color = Colors.blueAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    paint.color = Colors.yellow[50] as Color;
    canvas.drawCircle(line.selectedEdge, 10, paint);

    paint.color = Colors.red;
    canvas.drawCircle(line.selectedEdge, 10, paint);
  }

  void makeSegmentSelected(Segment line, Canvas canvas) {
    print('makeSegementSelected');
  }

  void unselectSegment(Segment line, Canvas canvas) {}

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }

  void getColorOfCoordinate() {}
}

import 'package:flutter/material.dart';

import '../../model/line.dart';
import '../../model/simulation/tool.dart';

class SimulationSketcher extends CustomPainter {
  final List<Tool> beams;
  final List<Tool> tracks;

  SimulationSketcher({required this.beams, required this.tracks});

  @override
  void paint(Canvas canvas, Size size) {
    Paint blackPaint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;

    Paint greyPaint = Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;


    Path beamsPath = new Path();
    Path tracksPath = new Path();

    // path.moveTo(testLine.start.dx, testLine.start.dy);
    // path.lineTo(testLine.end.dx, testLine.end.dy);

    if (beams.isNotEmpty ) {
      beams.forEach((tool) {
        beamsPath.moveTo(tool.lines.first.start.dx, tool.lines.first.start.dy);
        tool.lines.forEach((line) {
          beamsPath.lineTo(line.end.dx, line.end.dy);
        });
      });
    }

    if (tracks.isNotEmpty) {
      tracks.forEach((track) {
        tracksPath.moveTo(track.lines.first.start.dx, track.lines.first.start.dy);
        track.lines.forEach((line) {
          tracksPath.lineTo(line.end.dx, line.end.dy);
        });
      });
    }


    canvas.drawPath(beamsPath, blackPaint);
    canvas.drawPath(tracksPath, greyPaint);

    // shapes.forEach((shape) {
    // Move to first offset to start drawing
    // path.moveTo(shape.path.first.dx, shape.path.first.dy);
    //
    // shape.path.removeAt(0);
    //
    // shape.path.forEach((offset) {
    //   path.lineTo(offset.dx, offset.dy);
    // });
    // });
    //
    // canvas.drawPath(path, paint);
    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

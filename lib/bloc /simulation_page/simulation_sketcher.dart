import 'package:flutter/material.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';

import '../../model/line.dart';
import '../../model/simulation/tool.dart';

import 'package:collection/collection.dart';

class SimulationSketcher extends CustomPainter {
  final List<Tool> beams;
  final List<Tool> tracks;
  final List<Tool> plates;
  final List<Offset> debugOffsets;
  final double rotateAngle;

  SimulationSketcher(
      {required this.beams,
      required this.tracks,
      required this.plates,
      required this.rotateAngle,
      required this.debugOffsets});

  GeometricCalculationsService _calculationsService =
      new GeometricCalculationsService();

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

    Paint redStroke = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    Paint blueStroke = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    Path beamsPath = new Path();
    Path tracksPath = new Path();
    Path platesPath = new Path();

    // path.moveTo(testLine.start.dx, testLine.start.dy);
    // path.lineTo(testLine.end.dx, testLine.end.dy);

    if (beams.isNotEmpty) {
      beams.forEach((tool) {
        beamsPath.moveTo(tool.lines.first.start.dx, tool.lines.first.start.dy);
        tool.lines.forEach((line) {
          beamsPath.lineTo(line.end.dx, line.end.dy);
        });
      });
    }

    if (tracks.isNotEmpty) {
      tracks.forEach((track) {
        tracksPath.moveTo(
            track.lines.first.start.dx, track.lines.first.start.dy);
        track.lines.forEach((line) {
          tracksPath.lineTo(line.end.dx, line.end.dy);
        });
      });
    }

    canvas.drawPath(beamsPath, blackPaint);
    canvas.drawPath(tracksPath, greyPaint);

    if (plates.isNotEmpty) {
      List<Offset> plateOffsets =
          plates.first.lines.map((line) => line.start).toList() +
              plates.first.lines.map((line) => line.end).toList();

      Line? selectedLine =
          plates.first.lines.firstWhereOrNull((line) => line.isSelected);

      if (selectedLine == null) {
        selectedLine = plates.first.lines.first;
      }
      // Line middleLine = plates.first.lines[plates.first.lines.length ~/ 2];
      Offset center =
          _calculationsService.getMiddle(selectedLine.start, selectedLine.end);

      canvas.drawCircle(center, 4, redStroke);

      List<Line> selectedLines = [];
      //
      // canvas
      //   ..save()
      //   ..translate(center.dx, center.dy)
      //   ..rotate(_calculationsService.degreesToRadians(rotateAngle))
      //   ..translate(-center.dx, -center.dy);

      plates.forEach((plate) {
        platesPath.moveTo(
            plate.lines.first.start.dx, plate.lines.first.start.dy);
        plate.lines.forEach((line) {
          platesPath.lineTo(line.end.dx, line.end.dy);

          if (line.isSelected) {
            selectedLines.add(line);
          }
        });
      });

      canvas.drawPath(platesPath, blueStroke);

      selectedLines.forEach((line) {
        canvas.drawLine(line.start, line.end, redStroke);
      });

      // canvas.restore();

      // Debugging
      // debugOffsets.forEach((offset) {
      //   canvas.drawCircle(offset, 4, redStroke);
      // });

    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

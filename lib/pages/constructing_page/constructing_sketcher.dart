import 'dart:ui';

import 'package:flutter/material.dart';

import '../../model/segment.dart';
import '../../model/segment_offset.dart';
import '../../services/geometric_calculations_service.dart';

// section Constructing Sketcher
class ConstructingSketcher extends CustomPainter {
  // final List<Segment> lines;
  final List<Segment> lines2;
  final bool coordinatesShown;
  final bool edgeLengthsShown;
  final bool anglesShown;

  ConstructingSketcher(
      {required this.lines2,
      required this.coordinatesShown,
      required this.edgeLengthsShown,
      required this.anglesShown});

  PictureRecorder pictureRecorder = new PictureRecorder();

  String lastDrawnText = '';

  GeometricCalculationsService _calculationsService =
      new GeometricCalculationsService();

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    List<SegmentOffset> shorterSegments = lines2.first.path;
    Path drawnPath = new Path();
    Offset firstOffset = lines2.first.path.first.offset;
    drawnPath.moveTo(firstOffset.dx, firstOffset.dy);

    List<Offset> arcOffsets = [];

    // List<Offset> shortenedOffsets = shortSegments(lines2.first.path);

    if (lines2.isNotEmpty) {
    //   List<SegmentOffset> path = lines2.first.path;
    //   shortenedOffsets.forEach((o) {
    //     drawnPath.lineTo(o.dx, o.dy);
    //   });

      // for (int i = 0; i < lines2.first.path.length - 1; ++i) {
      //   Offset shortenedOffsetA = _calculationsService
      //       .extendSegment([path[i].offset, path[i + 1].offset], -20);
      //
      //   Offset shortenedOffsetB = _calculationsService
      //       .extendSegment([path[i + 1].offset, path[i].offset], -20);
      //
      //   if (path.first == path[i]) {
      //     drawnPath.lineTo(shortenedOffsetA.dx, shortenedOffsetA.dy);
      //     arcOffsets.add(path[i + 1].offset);
      //   } else if (path.last == path[i + 1]) {
      //     drawnPath.moveTo(shortenedOffsetA.dx, shortenedOffsetA.dy);
      //     arcOffsets.add(shortenedOffsetA);
      //   } else {
      //     drawnPath.moveTo(shortenedOffsetA.dx, shortenedOffsetA.dy);
      //     arcOffsets.addAll([shortenedOffsetA, shortenedOffsetB]);
      //   }
      //   drawnPath.lineTo(shortenedOffsetB.dx, shortenedOffsetB.dy);
      //
      //   if (edgeLengthsShown) {
      //     showEdgeLengths(canvas, path[i].offset, path[i + 1].offset);
      //   }
      //
      //   if (anglesShown) {
      //     showAngles(canvas, path[i].offset, path[i + 1].offset);
      //   }
      // }

      if (coordinatesShown) {
        showCoordinates(canvas, lines2.first.path);
      }
    }

    // canvas.drawPath(drawnPath, paint);
    //
    // // section drawArc
    // final curvesPaint = Paint()
    //   ..strokeWidth = 5
    //   ..color = Colors.greenAccent[700]!
    //   ..style = PaintingStyle.stroke;
    //
    // Offset arcCenter1 = lines2.first.path[1].offset;
    // Offset arcCenter2 = new Offset(arcCenter1.dx, arcCenter1.dy);
    // final arcRect = Rect.fromCircle(center: arcCenter2, radius: 40);
  }

  List<Offset> shortSegments(List<SegmentOffset> offsets) {
    print('short Segments');
    List<Offset> result = [];
    // if (lines2.isNotEmpty) {
    //   List<SegmentOffset> path = lines2.first.path;
    //   for (int i = 0; i < path.length - 1; i + 2) {
    //     Offset shortenedOffsetA = _calculationsService
    //         .extendSegment([path[i].offset, path[i + 1].offset], -20);
    //
    //     Offset shortenedOffsetB = _calculationsService
    //         .extendSegment([path[i + 1].offset, path[i].offset], -20);
    //
    //     result.addAll([shortenedOffsetA, shortenedOffsetB]);
    //   }
    // }

    return result;
  }

  void showEdgeLengths(Canvas canvas, Offset offsetA, Offset offsetB) {
    String text = '${(offsetA - offsetB).distance.toStringAsFixed(1)} cm';

    Offset middle = _calculationsService.getMiddle(offsetA, offsetB);

    Offset offset = new Offset(middle.dx - 15, middle.dy + 4);

    drawText(canvas, text, offset, Colors.black, Colors.yellow[50]);
  }

  void showCoordinates(Canvas canvas, List<SegmentOffset> path) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    path.forEach((o) {
      canvas.drawCircle(o.offset, 7, paint);

      String text =
          '${o.offset.dx.toStringAsFixed(1)} / ${o.offset.dy.toStringAsFixed(1)}';

      Offset offset = new Offset(o.offset.dx - 35, o.offset.dy - 30);
      drawText(
          canvas, text, offset, Colors.black, Colors.green.withOpacity(0.4));
    });
  }

  void showAngles(Canvas canvas, Offset offsetA, Offset offsetB) {
    double angle = _calculationsService.getAngle(offsetA, offsetB);
    String text = '${angle.toStringAsFixed(1)}°';
    Offset middle = _calculationsService.getMiddle(offsetA, offsetB);
    Offset offset = new Offset(middle.dx - 10, middle.dy + 4);
    drawText(canvas, text, offset, Colors.red, Colors.yellow[50]);
  }

  void drawText(Canvas canvas, String text, Offset offset, Color color,
      Color? backgroundColor) {
    TextStyle style = TextStyle(
        color: Colors.black,
        backgroundColor: backgroundColor,
        decorationColor: Colors.green,
        decorationThickness: 0.25);

    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth:
            500); // TextPainter doesn't need to have specified width (would use infinity if not defined).
    // BTW: using the TextPainter you can check size the text take to be rendered (without `paint`ing it).

    textPainter.paint(canvas, offset);
  }

  TextPainter measureText(Canvas canvas, String text, TextStyle style) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);
    return textPainter;
  }

  @override
  bool shouldRepaint(ConstructingSketcher oldDelegate) {
    return true;
  }
}

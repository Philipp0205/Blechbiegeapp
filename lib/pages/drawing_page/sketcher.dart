import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:open_bsp/bloc%20/current_path/geometric_calculations_service.dart';

import '../../model/segment2.dart';
import '../../model/segment_model.dart';
import '../../model/segment_offset.dart';

class Sketcher extends CustomPainter {
  final List<Segment2> lines2;

  Sketcher({required this.lines2});

  PictureRecorder pictureRecorder = new PictureRecorder();
  late Canvas recordingCanvas;
  late Canvas canvas;

  String lastDrawnText = '';

  GeometricCalculationsService _calculationsService =
      new GeometricCalculationsService();

  @override
  void paint(Canvas canvas, Size size) {
    canvas = canvas;
    recordingCanvas = new Canvas(pictureRecorder);

    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    if (lines2.isNotEmpty) {
      List<SegmentOffset> path = lines2.first.path;
      for (int i = 0; i < lines2.first.path.length - 1; ++i) {
        canvas.drawLine(path[i].offset, path[i + 1].offset, paint);
      }

      List<Offset> selectedOffsets = lines2.first.path
          .where((e) => e.isSelected)
          .toList()
          .map((e) => e.offset)
          .toList();

      highlightSelectedOffsets(selectedOffsets, canvas);
    }
  }

  void toggleSegmentSelection(Segment line, Canvas canvas) {
    Paint paint = Paint()
      ..color = Colors.blueAccent
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    if (line.isSelected) {
      if (line.selectedEdge == line.path.first) {
        canvas.drawCircle(line.path.last, 10, paint);
        paint.color = Colors.green;
        canvas.drawCircle(line.path.first, 10, paint);
      } else {
        canvas.drawCircle(line.path.first, 10, paint);
        paint.color = Colors.green;
        canvas.drawCircle(line.path.last, 10, paint);
      }
    } else {
      paint.color = Colors.yellow[50] as Color;
      canvas.drawCircle(line.path.first, 10, paint);
      canvas.drawCircle(line.path.last, 10, paint);
    }
  }

  void highlightSelectedOffsets(List<Offset> offsets, Canvas canvas) {
    Paint paintBlue = Paint()
      ..color = Colors.blueAccent
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    Paint paintRed = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    Paint paintPurple = Paint()
      ..color = Colors.purple
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    offsets.forEach((offset) {
      if (offsets.indexOf(offset) == 0) {
        canvas.drawCircle(offset, 10, paintBlue);
      } else if (offsets.indexOf(offset) == 1) {
        canvas.drawCircle(offset, 10, paintRed);
      } else if (offsets.indexOf(offset) == 2) {
        canvas.drawCircle(offset, 10, paintPurple);
      }
    });

    /// Text
    offsets.forEach((element) {
      String text = '${element.dx.toStringAsFixed(1)} / '
          '${element.dy.toStringAsFixed(1)}';
      Offset offset = new Offset(element.dx - 40, element.dy + 20);
      drawText(canvas, text, offset, Colors.black, Colors.green[100],);
    });


  }

  void drawText(Canvas canvas, String text, Offset offset, Color color, Color? backgroundColor) {
    TextStyle style = TextStyle(
        color: Colors.black,
        backgroundColor: backgroundColor,
        decorationStyle: TextDecorationStyle.dotted,
        decorationColor: Colors.green,
        decorationThickness: 0.25);

    TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        // TextSpan could be whole TextSpans tree :)
        textAlign: TextAlign.start,
        //maxLines: 25, // In both TextPainter and Paragraph there is no option to define max height, but there is `maxLines`
        textDirection: TextDirection
            .ltr // It is necessary for some weird reason... IMO should be LTR for default since well-known international languages (english, esperanto) are written left to right.
        )
      ..layout(
          maxWidth:
              500); // TextPainter doesn't need to have specified width (would use infinity if not defined).
    // BTW: using the TextPainter you can check size the text take to be rendered (without `paint`ing it).
    textPainter.paint(canvas, offset);
  }

  void makeSegmentSelected(Segment line, Canvas canvas) {}

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }

  void getColorOfCoordinate() {}
}

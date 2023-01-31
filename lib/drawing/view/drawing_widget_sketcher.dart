import 'dart:ui';

import 'package:flutter/material.dart';

import '../../model/line.dart';

class DrawingWidgetSketcher extends CustomPainter {
  final List<Line> lines2;

  DrawingWidgetSketcher({required this.lines2});

  PictureRecorder pictureRecorder = new PictureRecorder();
  late Canvas recordingCanvas;
  late Canvas canvas;

  @override
  void paint(Canvas canvas, Size size) {
    canvas = canvas;
    recordingCanvas = new Canvas(pictureRecorder);

    Paint blackPaint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    Paint redPaint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    if (lines2.isNotEmpty) {
      lines2.forEach((line) {
        if (line.isSelected) {
          canvas.drawLine(line.start, line.end, redPaint);
        } else {
          canvas.drawLine(line.start, line.end, blackPaint);
        }
      });
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
      drawText(
        canvas,
        text,
        offset,
        Colors.black,
        Colors.green[100],
      );
    });
  }

  void drawText(Canvas canvas, String text, Offset offset, Color color,
      Color? backgroundColor) {
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
        //maxLines: 25,
        // In both TextPainter and Paragraph there is no option to define max height, but there is `maxLines`
        textDirection: TextDirection
            .ltr // It is necessary for some weird reason... IMO should be LTR for default since well-known international languages (english, esperanto) are written left to right.
        )
      ..layout(
          maxWidth:
              500); // TextPainter doesn't need to have specified width (would use infinity if not defined).
    // BTW: using the TextPainter you can check size the text take to be rendered (without `paint`ing it).
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(DrawingWidgetSketcher oldDelegate) {
    return true;
  }
}

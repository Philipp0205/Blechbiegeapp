import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as v;

import '../../model/line.dart';
import '../../model/segment_widget/segment.dart';
import '../../model/segment_offset.dart';
import '../../services/geometric_calculations_service.dart';
import 'package:image/image.dart' as img;

// section Constructing Sketcher
class ConstructingSketcher extends CustomPainter {
  // final List<Segment> lines;
  final List<Segment> lines;
  final bool coordinatesShown;
  final bool edgeLengthsShown;
  final bool anglesShown;
  final double s;
  final double r;

  ConstructingSketcher(
      {required this.lines,
      required this.coordinatesShown,
      required this.edgeLengthsShown,
      required this.anglesShown,
      required this.s,
      required this.r});

  ui.PictureRecorder pictureRecorder = new ui.PictureRecorder();

  String lastDrawnText = '';

  GeometricCalculationsService _calculationsService =
      new GeometricCalculationsService();

  // section Paint segment
  /*
  *   ____       _       _                                          _
  *  |  _ \ __ _(_)_ __ | |_    ___  ___  __ _ _ __ ___   ___ _ __ | |_
  *  | |_) / _` | | '_ \| __|  / __|/ _ \/ _` | '_ ` _ \ / _ \ '_ \| __|
  *  |  __/ (_| | | | | | |_   \__ \  __/ (_| | | | | | |  __/ | | | |_
  *  |_|   \__,_|_|_| |_|\__|  |___/\___|\__, |_| |_| |_|\___|_| |_|\__|
  *                                      |___/
  */
  //
  @override
  void paint(Canvas canvas, Size size) {
    // Canvas recordingCanvas = new Canvas(pictureRecorder);

    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s
      ..style = PaintingStyle.stroke;

    Path drawnPath = new Path();
    Offset firstOffset = lines.first.path.first.offset;
    drawnPath.moveTo(firstOffset.dx, firstOffset.dy);

    List<Line> shortLines = shortSegments(mapSegmentToLines(lines.first.path));
    List<Line> longLines = mapSegmentToLines(lines.first.path);

    if (lines.isNotEmpty) {
      Path drawnPath = new Path();

      shortLines.forEach((l) {
        drawnPath
          ..moveTo(l.start.offset.dx, l.start.offset.dy)
          ..lineTo(l.end.offset.dx, l.end.offset.dy);
      });

      for (int i = 0; i < shortLines.length - 1; ++i) {
        drawnPath.moveTo(
            shortLines[i].start.offset.dx, shortLines[i].start.offset.dy);
        double firstAngle = _calculationsService.getAngle(
            shortLines[i].end.offset, shortLines[i].start.offset);
        double secondAngle = _calculationsService.getAngle(
            shortLines[i + 1].end.offset, shortLines[i + 1].start.offset);

        double angleDelta;
        if (firstAngle > secondAngle) {
          angleDelta = firstAngle - secondAngle;
        } else {
          angleDelta = secondAngle - firstAngle;
        }

        bool direction = _calculationsService.getDirection(
            shortLines[i].end.offset,
            shortLines[i + 1].start.offset,
            lines.first.path[i].offset);

    ui.Rect myRect = shortLines[i].start.offset & const Size(-40, 40);
    // drawnPath.addRect(myRect);
        // drawnPath.addArc(oval, startAngle, sweepAngle)






        Offset controll = longLines[i].end.offset;
        Offset end = shortLines[i+1].end.offset;


        drawnPath.quadraticBezierTo(controll.dx, controll.dy, end.dx, end.dy);

        // drawnPath.arcToPoint(shortLines[i + 1].end.offset,
        //     radius: Radius.circular(20), clockwise: direction);
      }

      canvas.drawPath(drawnPath, paint);
      createPicture(canvas, size, drawnPath, paint);

      if (coordinatesShown) {
        List<SegmentOffset> offsets = [];
        offsets
          ..addAll(shortLines.map((e) => e.start).toList())
          ..addAll(shortLines.map((e) => e.end).toList());

        showCoordinates(canvas, offsets);
      }

      shortLines.forEach((l) {
        if (edgeLengthsShown) {
          showEdgeLengths(canvas, l.start.offset, l.end.offset);
        }

        // if (anglesShown) {
        //   _showAngles(canvas, l.start.offset, l.end.offset);
        // }
      });

      for (int i = 0; i < longLines.length - 1; ++i) {
        if (anglesShown) {
          _showAngles2(canvas, longLines[i], longLines[i + 1]);
        }
      }
    }
  }

  void createPicture(
      Canvas recodingCanvas, Size size, Path path, Paint paint) async {
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    Canvas canvas2 = new Canvas(recorder);
    canvas2.drawPath(path, paint);

    // ui.Picture picture = pictureRecorder.endRecording();
    ui.Picture picture = recorder.endRecording();
    ui.Image image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    // ByteData? data = await image.toByteData();
    ByteData? data2 =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    List<Offset> blackOffsets = [];

    img.Image newImage = img.Image.fromBytes(
        size.width.toInt(), size.height.toInt(), data2!.buffer.asUint8List());

    for (int x = 0; x < size.width.toInt(); ++x) {
      for (int y = 0; y < size.height.toInt(); ++y) {
        int color = newImage.getPixel(x, y);

        if (Color(color) == Colors.black) {
          blackOffsets.add(new Offset(x.toDouble(), y.toDouble()));
        }
      }
    }
    // print('blackOffsets length: ${blackOffsets.length}');
  }

  /// Shorts all lines by the same length. Except the first offset of the first
  /// line and the last offset of the last line. These do not ge shorted
  /// because there are not arc drawn before or after them.
  List<Line> shortSegments(List<Line> lines) {
    // List<Line> result = [];
    // for (int i = 0; i < lines.length - 1; ++i) {
    //
    //   v.Vector2 va = _calculationsService.createVectorFromLines(lines[i]);
    //   v.Vector2 vb = _calculationsService.createVectorFromLines(lines[i+1]);
    //
    //   double angle = _calculationsService.getAngleFromVectors(va, vb);
    //
    //   // if (angleA > angleB) {
    //   //   angle = 180 - (angleA - angleB);
    //   // } else {
    //   //   angle = 180 - (angleB - angleA);
    //   // }
    //   //
    //
    //   double shortening =
    //       -(0.0002 * pow(angle, 3))+
    //       0.0578 * pow(angle, 2)
    //       -(4.9717 * pow(angle,1))+
    //       178.8539;
    //
    //   List<Offset> shortOffsets = _calculationsService.changeLengthOfSegment(
    //       lines[i].start.offset, lines[i].end.offset, shortening, true, true);
    //
    //   print('angle: $angle');
    //   print('shortening: $shortening');
    //
    //   result.add(new Line(
    //       start:
    //           new SegmentOffset(offset: shortOffsets.first, isSelected: false),
    //       end:
    //           new SegmentOffset(offset: shortOffsets.last, isSelected: false)));
    //
    // }
    //
    // return result;


    List<Line> result = [];
    lines.forEach((l) {
      int i = lines.indexOf(l);
      if (i < lines.length) {
        List<Offset> shortOffsets = _calculationsService.changeLengthOfSegment(
            l.start.offset, l.end.offset, -10, true, true);

        result.add(new Line(
            start: new SegmentOffset(
                offset: shortOffsets.first, isSelected: false),
            end: new SegmentOffset(
                offset: shortOffsets.last, isSelected: false)));
      } else {
        List<Offset> shortOffsets = _calculationsService.changeLengthOfSegment(
            l.start.offset, l.end.offset, -10, true, true);

        result.add(new Line(
            start: new SegmentOffset(
                offset: shortOffsets.first, isSelected: false),
            end: new SegmentOffset(
                offset: shortOffsets.last, isSelected: false)));
      }
    });

    return result;
  }

  // shortLine(Line line, double length) {
  //
  // }

  List<Line> mapSegmentToLines(List<SegmentOffset> offsets) {
    List<Line> lines = [];
    for (int i = 0; i < offsets.length - 1; ++i) {
      lines.add(new Line(start: offsets[i], end: offsets[i + 1]));
    }
    return lines;
  }

  // Segment details
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

    // Iterate in separate loops so that circled do not overlay the text.
    path.forEach((o) {
      canvas.drawCircle(o.offset, 7, paint);
    });

    path.forEach((o) {
      String text =
          '${o.offset.dx.toStringAsFixed(1)} / ${o.offset.dy.toStringAsFixed(1)}';

      Offset offset = new Offset(o.offset.dx - 35, o.offset.dy + 30);
      drawText(canvas, text, offset, Colors.black, Colors.yellow[50]);
    });
  }

  void _showAngles(Canvas canvas, Offset offsetA, Offset offsetB) {
    double angle = _calculationsService.getAngle(offsetB, offsetA);
    String text = '${angle.toStringAsFixed(1)}°';
    Offset middle = _calculationsService.getMiddle(offsetA, offsetB);
    Offset offset = new Offset(middle.dx - 10, middle.dy + 4);
    drawText(canvas, text, offset, Colors.red, Colors.yellow[50]);
  }

  // 150 - 300
  void _showAngles2(Canvas canvas, Line lineA, Line lineB) {
    // double angleA =
    //     _calculationsService.getAngle(lineA.start.offset, lineA.end.offset);
    // double angleB =
    //     _calculationsService.getAngle(lineB.start.offset, lineB.end.offset);
    //
    // double angle = atan2(angleB, angleA);


    v.Vector2 vectorA = _calculationsService.createVectorFromLines(lineA);
    v.Vector2 vectorB = _calculationsService.createVectorFromLines(lineB);

    double angle = _calculationsService.getAngleFromVectors(vectorA, vectorB);


    // double angle = _calculationsService.getInnerAngle(lineA, lineB);

    SegmentOffset offsetA = new SegmentOffset(offset: new Offset(0, 3), isSelected: false);
    SegmentOffset offsetB = offsetA.copyWith(offset: new Offset(4, 3));



    String text = '${angle.toStringAsFixed(1)}°';

    Offset offset = new Offset(lineA.end.offset.dx - 10, lineA.end.offset.dy);

    drawText(canvas, text, offset, Colors.red, Colors.white);
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

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as v;

import '../../model/line.dart';
import '../../model/segment_widget/segment.dart';
import '../../model/segment_offset.dart';
import '../../services/geometric_calculations_service.dart';
import 'package:image/image.dart' as img;

/// Sketcher for the second page that comes after initially drawing a [Segment].
/// Allows configuration of existing [Segment]:
///
/// - Shows details like coordinates, lengths of the edges and angles.
/// - Allows to change the thickness (s) of the segment.
/// - Draw arcs between lines to make the corners round. Can be modified with
///   a radius (r).
///
/// Naming: A [Segment] consists of multiple [Line]s.
class ConstructingSketcher extends CustomPainter {
  // Segment details
  final bool coordinatesShown;
  final bool edgeLengthsShown;
  final bool anglesShown;

  // Segment configuration
  final double s;
  final double r;

  final List<Segment> lines;

  // Constructor
  ConstructingSketcher(
      {required this.lines,
      required this.coordinatesShown,
      required this.edgeLengthsShown,
      required this.anglesShown,
      required this.s,
      required this.r});

  // Class variables
  GeometricCalculationsService _calculationsService =
      new GeometricCalculationsService();
  ui.PictureRecorder pictureRecorder = new ui.PictureRecorder();

  /// Paints on current canvas.
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s
      ..style = PaintingStyle.stroke;

    List<Line> shortLines =
        changeLengthsOfSegments(mapSegmentToLines(lines.first.path), -r, false);
    List<Line> longLines = mapSegmentToLines(lines.first.path);

    // If no liens where drawn before do nothing.
    if (lines.isNotEmpty) {
      // Move to the first offset to start drawing.
      Path drawnPath = new Path();
      Offset firstOffset = lines.first.path.first.offset;
      drawnPath.moveTo(firstOffset.dx, firstOffset.dy);

      drawnPath = drawLinesOnCanvas(canvas, shortLines);
      drawnPath =
          drawCurvesBetweeLines(canvas, shortLines, longLines, drawnPath);

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
          _showAngles(canvas, longLines[i], longLines[i + 1]);
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

  /// Changes the lengths of all [lines] by the same [length].
  /// The length value will be subtracted from the start and the end of the line.
  ///
  /// If the [length] is negative the line will get shorter.
  /// If it is shorter it will get longer.
  ///
  /// Depending on the value of [changeEnds] the very first offset and the very
  /// last offset will not be changed at all.
  List<Line> changeLengthsOfSegments(
      List<Line> lines, double length, bool changeEnds) {
    List<Line> changedLines = [];

    lines.forEach((l) {
      List<Offset> shortOffsets = _calculationsService.changeLengthOfSegment(
          l.start.offset, l.end.offset, length, true, true);

      SegmentOffset firstOffset =
          new SegmentOffset(offset: shortOffsets.first, isSelected: false);
      SegmentOffset endOffset =
          new SegmentOffset(offset: shortOffsets.last, isSelected: false);

      // If current line ist the first or last line do not change the outer offset.
      if (!changeEnds) {
        if (l == lines.first) {
          endOffset = firstOffset.copyWith(offset: l.start.offset);
        } else if (l == lines.last) {
          firstOffset = firstOffset.copyWith(offset: l.end.offset);
        }
      }
      changedLines.add(new Line(start: firstOffset, end: endOffset));
    });

    return changedLines;
  }

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

  void _showAngles(Canvas canvas, Line lineA, Line lineB) {
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

    SegmentOffset offsetA =
        new SegmentOffset(offset: new Offset(0, 3), isSelected: false);
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

  /// Draws all given [lines] on [canvas] using dart [Path].
  Path drawLinesOnCanvas(Canvas canvas, List<Line> lines) {
    Path path = new Path();

    lines.forEach((l) {
      path
        ..moveTo(l.start.offset.dx, l.start.offset.dy)
        ..lineTo(l.end.offset.dx, l.end.offset.dy);
    });
    return path;
  }

  /// Draws curves between all [lines] on a [canvas]. Using dart [path].
  /// The curves drawn between the lines are Bézier curves and therefore need
  /// control points which here are in the [controlPoints] list.
  Path drawCurvesBetweeLines(
      Canvas canvas, List<Line> lines, List<Line> controlPoints, Path path) {
    for (int i = 0; i < lines.length - 1; ++i) {
      path.moveTo(lines[i].start.offset.dx, lines[i].start.offset.dy);

      Offset controlPoint = controlPoints[i].end.offset;
      Offset endPoint = lines[i + 1].end.offset;

      path.quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    }

    return path;
  }
}

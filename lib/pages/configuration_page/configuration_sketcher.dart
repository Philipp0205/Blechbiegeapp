import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as v;

import '../../model/Line2.dart';
import '../../model/segment_widget/segment.dart';
import '../../model/segment_offset.dart';
import '../../services/geometric_calculations_service.dart';
import 'package:image/image.dart' as img;

/// Sketcher for the second page that comes after initially drawing a [Segment].
/// Allows configuration_page of existing [Segment]:
///
/// - Shows details like coordinates, lengths of the edges and angles.
/// - Allows to change the thickness (s) of the segment.
/// - Draw arcs between lines to make the corners round. Can be modified with
///   a radius (r).
///
/// Naming: A [Segment] consists of multiple [Line]s.
class ConfigurationSketcher extends CustomPainter {
  // Segment details
  final bool coordinatesShown;
  final bool edgeLengthsShown;
  final bool anglesShown;

  // Segment configuration_page
  final double s;
  final double r;

  final List<Segment> segments;
  final List<Line> lines;

  // Constructor
  ConfigurationSketcher(
      {required this.segments,
      required this.lines,
      required this.coordinatesShown,
      required this.edgeLengthsShown,
      required this.anglesShown,
      required this.s,
      required this.r});

  // Class variables
  GeometricCalculationsService _calculationsService =
      new GeometricCalculationsService();
  ui.PictureRecorder pictureRecorder = new ui.PictureRecorder();

  /// Paints on current canvas. Called whenever the object needs to paint.
  ///
  /// The given [Canvas] has its coordinate space configured such that the
  /// origin is at the top left of the box.
  /// The area of the box is the size of the [size] argument.
  ///
  /// Main method of this class
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s
      ..style = PaintingStyle.stroke;

    List<Line> shortLines = changeLengthsOfSegments(lines, -r, false);

    if (lines.isNotEmpty) {
      Path drawnPath = new Path();

      Offset firstOffset = lines.first.start;
      drawnPath.moveTo(firstOffset.dx, firstOffset.dy);

      drawnPath = addLinesToPath(shortLines);
      drawnPath = addCurvesToPath(canvas, shortLines, lines, drawnPath);

      canvas.drawPath(drawnPath, paint);
      //
      //   createPicture(canvas, size, drawnPath, paint);
      //
      showSegmentDetails(canvas, shortLines, lines);
    }

    // if (segments.isNotEmpty) {
    //   // Move to the first offset to start drawing.
    //   Path drawnPath = new Path();
    //   Offset firstOffset = segments.first.path.first.offset;
    //   drawnPath.moveTo(firstOffset.dx, firstOffset.dy);
    //
    //   drawnPath = addLinesToPath(shortLines);
    //   drawnPath = addCurvesToPath(canvas, shortLines, longLines, drawnPath);
    //
    //   canvas.drawPath(drawnPath, paint);
    //
    //   createPicture(canvas, size, drawnPath, paint);
    //
    //   showSegmentDetails(canvas, shortLines, longLines);
    // }
  }

  /// Returns all black pixel of the canvas.
  Future<List<Offset>> createPicture(
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
    return blackOffsets;
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

    lines.forEach((line) {
      List<Offset> shortOffsets = _calculationsService.changeLengthOfSegment(
          line.start, line.end, length, true, true);

      SegmentOffset firstOffset =
          new SegmentOffset(offset: shortOffsets.first, isSelected: false);
      SegmentOffset endOffset =
          new SegmentOffset(offset: shortOffsets.last, isSelected: false);

      // If current line ist the first or last line do not change the outer offset.
      if (!changeEnds) {
        if (line == lines.first) {
          endOffset = firstOffset.copyWith(offset: line.start);
        } else if (line == lines.last) {
          firstOffset = firstOffset.copyWith(offset: line.end);
        }
      }
      changedLines.add(new Line(
          start: shortOffsets.first,
          end: shortOffsets.last,
          isSelected: false));
    });

    return changedLines;
  }

  /// Maps [SegmentOffset]s created to [Line]s.
  /// The difference is, that one lines contains two offsets. A start offset
  /// and an end offset.
  // List<Line> mapSegmentToLines(List<Line2> offsets) {
  //   List<Line> lines = [];
  //
  //   for (int i = 0; i < offsets.length - 1; ++i) {
  //     lines.add(new Line(start: offsets[i], end: offsets[i + 1]));
  //   }
  //   return lines;
  // }

  /// Draws given [text] on an [canvas] at the coordinates of [offset] with the
  /// a [textColor] and [backgroundColor].
  void drawText(Canvas canvas, String text, Offset offset, Color textColor,
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
    )..layout(maxWidth: 500);

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(ConfigurationSketcher oldDelegate) {
    return true;
  }

  ///  Adds all given [lines] to a [Path].
  Path addLinesToPath(List<Line> lines) {
    Path path = new Path();

    lines.forEach((l) {
      path
        ..moveTo(l.start.dx, l.start.dy)
        ..lineTo(l.end.dx, l.end.dy);
    });
    return path;
  }

  /// Draws curves between all [lines] on a [canvas]. Using dart [path].
  /// The curves drawn between the lines are Bézier curves and therefore need
  /// [controlPoints].
  Path addCurvesToPath(
      Canvas canvas, List<Line> lines, List<Line> controlPoints, Path path) {
    for (int i = 0; i < lines.length - 1; ++i) {
      path.moveTo(lines[i].start.dx, lines[i].start.dy);

      Offset controlPoint = controlPoints[i].end;
      Offset endPoint = lines[i + 1].end;

      path.quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    }

    return path;
  }

  /// Shows details of the drawn Lines on the canvas.
  ///
  /// Details are the coordinates of each line, the inner angles between lines
  /// and the lengths of each edge.
  void showSegmentDetails(
      Canvas canvas, List<Line> shortLines, List<Line> longLines) {
    if (coordinatesShown) {
      List<Offset> offsets = [];
      offsets
        ..addAll(shortLines.map((e) => e.start).toList())
        ..addAll(shortLines.map((e) => e.end).toList());

      _drawCoordinates(canvas, offsets);
    }

    shortLines.forEach((l) {
      if (edgeLengthsShown) {
        _drawLineLengths(canvas, l.start, l.end);
      }

      // if (anglesShown) {
      //   _showAngles(canvas, l.start.offset, l.end.offset);
      // }
    });

    longLines.forEach((line) {
      if (anglesShown) {
        // _drawAngles(canvas, line.start, line.end);
      }
    });
  }

  /// Draws text on the canvas containing the length of a line.
  void _drawLineLengths(Canvas canvas, Offset offsetA, Offset offsetB) {
    String text = '${(offsetA - offsetB).distance.toStringAsFixed(1)} cm';

    Offset middle = _calculationsService.getMiddle(offsetA, offsetB);

    Offset offset = new Offset(middle.dx - 15, middle.dy + 4);

    drawText(canvas, text, offset, Colors.black, Colors.white);
  }

  /// Draws the coordinates of each [SegmentOffset] in the [path] on an
  /// [canvas].
  void _drawCoordinates(Canvas canvas, List<Offset> path) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    // Iterate in separate loops so that circled do not overlay the text.
    path.forEach((o) {
      canvas.drawCircle(o, 7, paint);
    });

    path.forEach((o) {
      String text = '${o.dx.toStringAsFixed(1)} / ${o.dy.toStringAsFixed(1)}';

      Offset offset = new Offset(o.dx - 35, o.dy + 30);
      drawText(canvas, text, offset, Colors.black, Colors.white);
    });
  }

  /// Draws inner angle between [lineA] and [lineB] on an [canvas].
  void _drawAngles(Canvas canvas, Line lineA, Line lineB) {
    // v.Vector2 vectorA = _calculationsService.createVectorFromLines(lineA);
    // v.Vector2 vectorB = _calculationsService.createVectorFromLines(lineB);

    // double angle = _calculationsService.getAngleFromVectors(vectorA, vectorB);

    // String text = '${angle.toStringAsFixed(1)}°';

    // Offset offset = new Offset(lineA.end.offset.dx - 10, lineA.end.offset.dy);

    // drawText(canvas, text, offset, Colors.red, Colors.white);
  }
}

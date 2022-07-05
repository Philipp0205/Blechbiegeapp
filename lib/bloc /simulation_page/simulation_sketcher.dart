import 'package:flutter/material.dart';

import '../../model/Line2.dart';
import '../../model/simulation/shape.dart';

class SimulationSketcher extends CustomPainter {
  final List<Shape> shapes;

  SimulationSketcher({required this.shapes});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;

    Path path = new Path();

    print('${shapes.length} shapes');


    // path.moveTo(testLine.start.dx, testLine.start.dy);
    // path.lineTo(testLine.end.dx, testLine.end.dy);

    Offset firstOffset = shapes.first.lines.first.start;

    shapes.forEach((shape) {
      path.moveTo(shape.lines.first.start.dx, shape.lines.first.start.dy);
      shape.lines.forEach((line) {
        path.lineTo(line.end.dx, line.end.dy);
      });
    });

    canvas.drawPath(path, paint);

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

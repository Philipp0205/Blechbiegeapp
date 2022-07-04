
import 'package:flutter/material.dart';

import '../../model/simulation/shape.dart';

class SimulationSketcher extends CustomPainter{
  final List<Shape> shapes;

  SimulationSketcher({required this.shapes});

  @override
  void paint(Canvas canvas, Size size) {

    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
    ..style = PaintingStyle.fill;

    Path path = new Path();
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
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
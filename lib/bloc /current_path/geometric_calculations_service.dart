import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../model/segment.dart';

/// All calculations involving points (offsets) in a the coordinate system of
/// the application.
class GeometricCalculationsService {
  /// Returns sorted Map according to distance of [offset] to each element
  /// in [offsets].
  Map<Offset, double> _getOffsetsByDistance(
      Offset offset, List<Offset> offsets) {
    Map<Offset, double> distances = {};
    offsets.forEach((currentOffset) {
      distances.addEntries(
          [MapEntry(currentOffset, (currentOffset - offset).distance)]);
    });

    var mapEntries = distances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    distances
      ..clear()
      ..addEntries(mapEntries);

    return distances;
  }

  List<Offset> getNNearestOffsets(
      Offset offset, List<Offset> offsets, int numberOfOffsets) {
    return _getOffsetsByDistance(offset, offsets)
        .keys
        .toList()
        .getRange(0, numberOfOffsets)
        .toList();
  }

  /// Extends a segment consisting of two [offsets] by given [length].
  Offset extendSegment(List<Offset> offsets, double length) {
    Offset offsetA = offsets.first;
    Offset offsetB = offsets.last;

    double lengthAB = (offsetA - offsetB).distance;

    double x = offsetB.dx + (offsetB.dx - offsetA.dx) / lengthAB * length;
    double y = offsetB.dy + (offsetB.dy - offsetA.dy) / lengthAB * length;

    return new Offset(x, y);
  }

  /*
       Distance(point1, currPoint)
     + Distance(currPoint, point2)
    == Distance(point1, point2)

    https://stackoverflow.com/questions/11907947/how-to-check-if-a-point-lies-on-a-line-between-2-other-points/11912171#11912171
  */
  double getDistanceToSegment(DragDownDetails details, Segment segment) {
    Point currentPoint =
        new Point(details.globalPosition.dx, details.globalPosition.dy - 80);
    Point startPoint = new Point(segment.path.first.dx, segment.path.first.dy);
    Point endPoint = new Point(segment.path.last.dx, segment.path.last.dy);

    return startPoint.distanceTo(currentPoint) +
        currentPoint.distanceTo(endPoint) -
        startPoint.distanceTo(endPoint);
  }

  /// Returns the angle between a [centre] offset and another [offset]
  ///
  /// Dot product u dot v = mag u * mag v * cos theta
  /// Therefore theta = cos -1 ((u dot v) / (mag u * mag v))
  /// Horizontal v = (1, 0)
  /// therefore theta = cos -1 (u.x / mag u)
  /// nb, there are 2 possible angles and if u.y is positive then angle is in first quadrant, negative then second
  ///
  /// https://stackoverflow.com/a/38024982/7127837

  double getAngle(Offset centre, Offset offset) {
    double x = offset.dx - centre.dx;
    double y = offset.dy - centre.dy;

    double magnitude = sqrt(x * x + y * y);
    double angle = 0;
    if (magnitude > 0) {
      angle = acos(x / magnitude);
    }

    angle = angle * 180 / pi;
    if (y < 0) {
      angle = 360 - angle;
    }

    return angle;
  }

  /// If you are at point (x,y) and you want to move d unit in alpha
  /// angle (in radian), then formula for destination point will be:
  ///
  /// xx = x + (d * cos(alpha))
  /// yy = y + (d * sin(alpha))
  ///
  /// Angle to radian
  /// angle in radian = angle in degree * Pi / 180
  ///
  /// https://math.stackexchange.com/a/3534251/743682
  Offset calculatePointWithAngle(Offset centre, double length, double angle) {
    double radian = angle * pi / 180;

    double x = centre.dx + (length * cos(radian));
    double y = centre.dy + (length * sin(radian));

    return new Offset(x, y);
  }
}

import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../model/segment_widget/segment.dart';

/// All calculations involving points (offsets) in a the coordinate system of
/// the application.
class GeometricCalculationsService {
  //section Offsets
  /*
  *    ___   __  __          _       
  *   / _ \ / _|/ _|___  ___| |_ ___ 
  *  | | | | |_| |_/ __|/ _ \ __/ __|
  *  | |_| |  _|  _\__ \  __/ |_\__ \
  *   \___/|_| |_| |___/\___|\__|___/
  *                                  
  */

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

  /// Returns nearest nearest offsets of [offset] in [offsets].
  /// Number of nearest offsets is determined by [numberOfOffsets].
  List<Offset> getNNearestOffsets(
      Offset offset, List<Offset> offsets, int numberOfOffsets) {
    return _getOffsetsByDistance(offset, offsets)
        .keys
        .toList()
        .getRange(0, numberOfOffsets)
        .toList();
  }

  Offset changeLengthOfOffset(Offset start, Offset end, double length) {
    double lengthAB = (start - end).distance;
    double x = end.dx + (end.dx - start.dx) / lengthAB * length;
    double y = end.dy + (end.dy - start.dy) / lengthAB * length;

    return new Offset(x, y);
  }

  // section Segments
  /*
  *   ____                                  _
  *  / ___|  ___  __ _ _ __ ___   ___ _ __ | |_ ___
  *  \___ \ / _ \/ _` | '_ ` _ \ / _ \ '_ \| __/ __|
  *   ___) |  __/ (_| | | | | | |  __/ | | | |_\__ \
  *  |____/ \___|\__, |_| |_| |_|\___|_| |_|\__|___/
  *              |___/
  */

  /// Changes the  length of a segment consisting of two Offsets [start]  and
  /// [end] by given [length]. Can handle negative lengths!
  ///
  /// Changes the [end] Offset or both Offsets if [bothEnds] is true.
  /// Return one offset if only the end changes, return two offsets if both
  /// ends change.
  List<Offset> changeLengthOfSegment(
      Offset start, Offset end, double length, bool bothEnds) {
    List<Offset> result = [];

    Offset newStart = changeLengthOfOffset(start, end, length);
    if (bothEnds) {
      Offset newEnd = changeLengthOfOffset(end, start, length);
      result.addAll([newStart, newEnd]);
    } else {
      result.add(newStart);
    }
    return result;
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
    Point startPoint =
        new Point(segment.path.first.offset.dx, segment.path.first.offset.dy);
    Point endPoint =
        new Point(segment.path.last.offset.dx, segment.path.last.offset.dy);

    return startPoint.distanceTo(currentPoint) +
        currentPoint.distanceTo(endPoint) -
        startPoint.distanceTo(endPoint);
  }

  /// Given two offsets of a line starting is [offsetA] and ending is [offsetB]
  /// find out the mid-point of a line.
  Offset getMiddle(Offset offsetA, Offset offsetB) {
    double x = (offsetA.dx + offsetB.dx) / 2;
    double y = (offsetA.dy + offsetB.dy) / 2;

    return new Offset(x, y);
  }

  // section Angles & Radians
  /*
  *      _                _               ___      ____           _ _
  *     / \   _ __   __ _| | ___  ___    ( _ )    |  _ \ __ _  __| (_) __ _ _ __  ___
  *    / _ \ | '_ \ / _` | |/ _ \/ __|   / _ \/\  | |_) / _` |/ _` | |/ _` | '_ \/ __|
  *   / ___ \| | | | (_| | |  __/\__ \  | (_>  <  |  _ < (_| | (_| | | (_| | | | \__ \
  *  /_/   \_\_| |_|\__, |_|\___||___/   \___/\/  |_| \_\__,_|\__,_|_|\__,_|_| |_|___/
  *                 |___/
  */
  //

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

  double getMagnitude(Offset centre, Offset offset) {
    double x = offset.dx - centre.dx;
    double y = offset.dy - centre.dy;

    return sqrt(x * x + y * y);
  }

  /// Determines the direction of an arc. Which means that if it is clockwise
  /// (true) or anti-clockwise (false).
  ///
  /// Three parts of the arcs are needed, the [start], [middle] and [end] Offset
  /// of the arc.
  ///
  /// https://stackoverflow.com/questions/33960924/is-arc-clockwise-or-counter-clockwise
  bool getDirection(Offset start, Offset end, Offset middle) {
    return ((end.dx - start.dx) * (middle.dy - start.dy) -
            (end.dy - start.dy) * (middle.dx - start.dx)) >
        0;
  }

  double degreesToRadians(double degrees) {
    return (degrees * pi) / 180;
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

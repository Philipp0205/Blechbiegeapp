import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math.dart';

import '../model/line.dart';
import '../model/segment_widget/segment.dart';
import '../model/simulation/tool.dart';

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

  Offset _changeLengthOfOffset(Offset start, Offset end, double length) {
    double lengthAB = (start - end).distance;
    double x = end.dx + (end.dx - start.dx) / lengthAB * length;
    double y = end.dy + (end.dy - start.dy) / lengthAB * length;

    return new Offset(x, y);
  }

  /// Changes the  length of a segment consisting of two Offsets [start]  and
  /// [end] by given [length]. Can handle negative lengths!
  ///
  /// With [shortStart] and [shortEnd] it is possible to set the ends which
  /// should be shorted. It is possible to short only one end or both.
  ///
  /// Always two offsets are returned. Only one end got shorted one of the
  /// results will be  the same offset.
  List<Offset> changeLengthOfSegment(
      Offset start, Offset end, double length, bool shortStart, bool shortEnd) {
    List<Offset> result = [];

    Offset newStart = _changeLengthOfOffset(start, end, length);
    Offset newEnd = _changeLengthOfOffset(end, start, length);
    if (shortStart && shortEnd) {
      result.addAll([newStart, newEnd]);
    } else if (shortStart) {
      result.addAll([newStart, end]);
    } else {
      result.addAll([start, newEnd]);
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

  double getAngleBetweenTwoLines(double angleA, double angleB) {
    double angle;
    if (angleA > angleB) {
      angle = angleA - angleB;
      print('$angleA - $angleB = $angle');
    } else {
      angle = angleB - angleA;
      print('$angleB - $angleA = $angle');
    }

    if (angle > 180) {
      angle = 360 - angle;
    }
    return angle;
  }

  /// atan2(vector1.y - vector2.y, vector1.x - vector2.x)
  /// angle = arccos[(xa * xb + ya * yb) / (√(xa2 + ya2) * √(xb2 + yb2))]
  double getAngleFromVectors(Vector2 vector1, Vector2 vector2) {
    double angle = atan2(vector2.y, vector2.x) - atan2(vector1.y, vector1.x);

    if (angle > pi) {
      angle -= 2 * pi;
    } else if (angle <= -pi) {
      angle += 2 * pi;
    }

    return (angle * radians2Degrees).abs();
  }

  /// Returns the inner angle between two [Line]s.
  double getInnerAngle(Line lineA, Line lineB) {
    double angleA = getAngle(lineA.start, lineA.end);
    double angleB = getAngle(lineB.start, lineB.end);

    return (angleA - angleB).abs();
  }

  /// Return all selected [lines].
  List<Line> getSelectedLines(List<Line> lines) {
    return lines.where((line) => line.isSelected).toList();
  }

  /// Returns [Offset]s with lowest x.
  /// If there are multiple lowest x all are returned.
  List<Offset> getLowestX(List<Offset> offsets) {
    List<Offset> lowestX = [];
    double lowestXValue = double.infinity;

    for (Offset offset in offsets) {
      if (offset.dx < lowestXValue) {
        lowestXValue = offset.dx;
        lowestX = [offset];
      } else if (offset.dx == lowestXValue) {
        lowestX.add(offset);
      }
    }
    return lowestX;
  }

  /// Returns [Offset]s with lowest y.
  /// If there are multiple lowest y, all are returned.
  List<Offset> getLowestY(List<Offset> offsets) {
    List<Offset> lowestY = [];
    double lowestYValue = double.infinity;

    for (Offset offset in offsets) {
      if (offset.dy < lowestYValue) {
        lowestYValue = offset.dy;
        lowestY = [offset];
      } else if (offset.dy == lowestYValue) {
        lowestY.add(offset);
      }
    }
    return lowestY;
  }

  /// Returns [Offset]s with highest x.
  /// If there are multiple highest x, all are returned.
  List<Offset> getHighestX(List<Offset> offsets) {
    List<Offset> highestX = [];
    double highestXValue = double.negativeInfinity;

    for (Offset offset in offsets) {
      if (offset.dx > highestXValue) {
        highestXValue = offset.dx;
        highestX = [offset];
      } else if (offset.dx == highestXValue) {
        highestX.add(offset);
      }
    }
    return highestX;
  }

  /// Returns [Offset]s with highest y.
  /// If there are multiple highest y, all are returned.
  List<Offset> getHighestY(List<Offset> offsets) {
    List<Offset> highestY = [];
    double highestYValue = double.negativeInfinity;

    for (Offset offset in offsets) {
      if (offset.dy > highestYValue) {
        highestYValue = offset.dy;
        highestY = [offset];
      } else if (offset.dy == highestYValue) {
        highestY.add(offset);
      }
    }
    return highestY;
  }

  /// Rotate given [offsets] around the given [center] by [angle] degrees.
  /// Returns the rotated [offsets].
  List<Offset> rotateOffsets(
      List<Offset> offsets, Offset center, double degrees) {
    List<Offset> rotatedOffsets = [];
    offsets.forEach((offset) {
      // var newx = (x - centerx) * Math.cos(degrees * Math.PI / 180) - (y - centery) * Math.sin(degrees * math.PI / 180) + centerx;
      // var newy = (x - centerx) * Math.sin(degrees * Math.PI / 180) + (y - centery) * Math.cos(degrees * math.PI / 180) + centery;
      double newX = (offset.dx - center.dx) * cos(degreesToRadians(degrees)) -
          (offset.dy - center.dy) * sin(degreesToRadians(degrees)) +
          center.dx;
      double newY = (offset.dx - center.dx) * sin(degreesToRadians(degrees)) +
          (offset.dy - center.dy) * cos(degreesToRadians(degrees)) +
          center.dy;
      rotatedOffsets.add(Offset(newX, newY));
    });
    return rotatedOffsets;
  }

  /// Rotate [offet] around the given [center] by [angle] degrees.
  /// Returns the rotated [offset].
  Offset rotateOffset(Offset offset, Offset center, double degrees) {
    double newX = (offset.dx - center.dx) * cos(degreesToRadians(degrees)) -
        (offset.dy - center.dy) * sin(degreesToRadians(degrees)) +
        center.dx;
    double newY = (offset.dx - center.dx) * sin(degreesToRadians(degrees)) +
        (offset.dy - center.dy) * cos(degreesToRadians(degrees)) +
        center.dy;
    return Offset(newX, newY);
  }

  /// Rotate given [lines] around the given [center] by [angle] degrees.
  List<Line> rotateLines(List<Line> lines, Offset center, double degrees) {
    List<Line> rotatedLines = [];
    lines.forEach((line) {
      rotatedLines.add(Line(
        start: rotateOffset(line.start, center, degrees),
        end: rotateOffset(line.end, center, degrees),
        isSelected: line.isSelected,
      ));
    });
    return rotatedLines;
  }

  List<Line> mirrorLines(List<Line> lines, double mirrorX) {
    List<Line> mirroredLines = [];

    print('mirrorX: $mirrorX');

    lines.forEach((line) {
      Line mirroredLine = line;

      Offset mirroredStart = _mirrorOffset(line.start, mirrorX);
      Offset mirroredEnd = _mirrorOffset(line.end, mirrorX);

      mirroredLines
          .add(mirroredLine.copyWith(start: mirroredStart, end: mirroredEnd));
    });

    return mirroredLines;
  }

  Offset _mirrorOffset(Offset offset, double mirrorX) {
    print('mirrorX: $mirrorX, offset.dx: ${offset.dx}');
    double distance = (mirrorX - offset.dx).abs();
    if (offset.dx < mirrorX) {
      return Offset(mirrorX + distance, offset.dy);
    } else if (offset.dx > mirrorX) {
      return Offset(mirrorX - distance, offset.dy);
    } else {
      return offset;
    }
  }
}

import 'dart:ui';

import 'package:flutter/cupertino.dart';

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

  Offset extendSegment(List<Offset> offsets, double length) {
    Offset offsetA = offsets.first;
    Offset offsetB = offsets.last;

    double lengthAB = (offsetA - offsetB).distance;

    double x = offsetB.dx + (offsetB.dx - offsetA.dx) / lengthAB * length;
    double y = offsetB.dy + (offsetB.dy - offsetA.dy) / lengthAB * length;

    return new Offset(x, y);
  }
}

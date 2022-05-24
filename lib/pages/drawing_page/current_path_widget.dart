import 'dart:math';

import 'package:flutter/material.dart';
import 'package:open_bsp/pages/drawing_page/bottom_sheet.dart';
import 'package:open_bsp/services/segment_data_service.dart';
import 'package:provider/provider.dart';

import '../../model/appmodes.dart';
import '../../model/segment.dart';
import '../../services/viewmodel_locator.dart';
import '../../viewmodel/all_paths_view_model.dart';
import '../../viewmodel/current_path_view_model.dart';
import '../../viewmodel/modes_controller_view_model.dart';
import 'sketcher.dart';

class CurrentPathWidget extends StatefulWidget {
  // final Modes selectedMode;
  // final Segment segment;
  // final List<Segment> model.segments;

  const CurrentPathWidget();

  @override
  _CurrentPathWidgetState createState() => _CurrentPathWidgetState();
}

class _CurrentPathWidgetState extends State<CurrentPathWidget> {
  GlobalKey key = new GlobalKey();

  CurrentPathViewModel currentPathVM = getIt<CurrentPathViewModel>();
  SegmentDataService _segmentDataService = getIt<SegmentDataService>();
  AllPathsViewModel _allPathsVM = getIt<AllPathsViewModel>();
  ModesViewModel _modesVM = getIt<ModesViewModel>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SegmentDataService>(
      create: (context) => _segmentDataService,
      child: GestureDetector(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onPanDown: onPanDown,
        child: RepaintBoundary(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(4.0),
              color: Colors.transparent,
              alignment: Alignment.topLeft,
              child: StreamBuilder<Segment>(
                stream: _segmentDataService.currentSegmentStreamController.stream,
                builder: (context, snapshot) {
                  return CustomPaint(
                    painter: Sketcher(
                      lines: [_segmentDataService.currentlyDrawnSegment],
                      // lines: lines,
                    ),
                  );
                },
              )),
        ),
      ),
    );
  }

  /// Logic when user starts drawing in the canvas.
  void onPanStart(DragStartDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset offset = new Offset(point.dx, point.dy);

    switch (_modesVM.selectedMode) {
      case Modes.defaultMode:
        onPanStartWithDefaultMode(offset);
        break;
      case Modes.pointMode:
        onPanStartWithPointMode(details, offset);
        break;
      case Modes.selectionMode:
        break;
    }
  }

  void onPanStartWithDefaultMode(Offset offset) {
    currentPathVM.setCurrentlyDrawnSegment(offset);
  }

  void onPanStartWithPointMode(DragStartDetails details, Offset offset) {
    currentPathVM.changeSelectedSegmentDependingNewOffset(offset);
  }

  /// Logic when user continuous drawing in the canvas while holding down finger.
  void onPanUpdate(DragUpdateDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);

    switch (_modesVM.selectedMode) {
      case Modes.defaultMode:
        onPanUpdateWithSelectionMode(point2);
        break;
      case Modes.pointMode:
        onPanUpdateWithPointMode(point2);
        break;
      case Modes.selectionMode:
        onPanUpdateWithSelectionMode(point2);
        break;
    }
  }

  void onPanUpdateWithSelectionMode(Offset offset) {
    currentPathVM.addToPathOfCurrentlyDrawnSegment(offset);
  }

  void onPanUpdateWithPointMode(Offset newOffset) {
    currentPathVM.changeSelectedSegmentDependingNewOffset(newOffset);
  }

  /// Logic when user stops drawing in the canvas.
  void onPanEnd(DragEndDetails details) {
    switch (_modesVM.selectedMode) {
      case Modes.defaultMode:
        onPanEndWithDefaultMode();
        break;
      case Modes.pointMode:
        onPanEndWithPointMode();
        break;
      case Modes.selectionMode:
        break;
    }
  }

  void onPanEndWithPointMode() {
    currentPathVM.mergeSegmentsIfNearToEachOther(
        currentPathVM.currentlyDrawnSegment, 30);
  }

  void onPanEndWithDefaultMode() {
    _segmentDataService
      ..currentlyDrawnSegment = currentPathVM
          .straigthenSegment(_segmentDataService.currentlyDrawnSegment)
      ..segments.add(_segmentDataService.currentlyDrawnSegment)
      ..updateCurrentSegmentLineStreamController()
      ..updateSegmentsStreamController();
  }

  void onPanDown(DragDownDetails details) {
    if (_modesVM.selectedMode == Modes.selectionMode) {
      selectSegment(details);
    }
    if (_modesVM.selectedMode == Modes.pointMode) {
      currentPathVM.selectPoint(
          new Point(details.globalPosition.dx, details.globalPosition.dy - 80));
    }
  }

  // Offset getNearestPoint(DragDownDetails details) {
  //   Segment nearestSegment = getNearestSegment(details);
  //   Offset nearestEdge;
  //
  //   Point currentPoint =
  //           new Point(details.globalPosition.dx, details.globalPosition.dy),
  //       edgeA = new Point(
  //           nearestSegment.path.first.dx, nearestSegment.path.first.dy),
  //       edgeB =
  //           new Point(nearestSegment.path.last.dx, nearestSegment.path.last.dy);
  //
  //   currentPoint.distanceTo(edgeA) > currentPoint.distanceTo(edgeB)
  //       ? nearestEdge = nearestSegment.path.last
  //       : nearestEdge = nearestSegment.path.first;
  //
  //   return nearestEdge;
  // }

  void selectSegment(DragDownDetails details) {
    Segment nearestSegment = currentPathVM.getNearestSegment(details);
    // if (nearestSegment != currentPathVM.currentlyDrawnSegment) {
    currentPathVM.changeSelectedSegment(nearestSegment);
    // }

    showModalBottomSheet(
      enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return AppBottomSheet();
      },
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:open_bsp/bloc%20/current_path/current_path_bloc.dart';
import 'package:open_bsp/pages/drawing_page/bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../model/appmodes.dart';
import '../../model/segment.dart';
import '../../services/viewmodel_locator.dart';
import '../../viewmodel/current_path_view_model.dart';
import '../../viewmodel/modes_controller_view_model.dart';
import 'sketcher.dart';

class CurrentPathWidget extends StatefulWidget {
  @override
  _CurrentPathWidgetState createState() => _CurrentPathWidgetState();
}

class _CurrentPathWidgetState extends State<CurrentPathWidget> {
  ModesViewModel _modesVM = getIt<ModesViewModel>();

  @override
  Widget build(BuildContext context) {
    // return ChangeNotifierProvider<CurrentPathViewModel>(
    //   create: (context) => _model,
    return Consumer<CurrentPathViewModel>(
      builder: (context, model, child) => GestureDetector(
        onPanStart: (details) => onPanStart(details, model),
        onPanUpdate: (details) => onPanUpdate(details, model),
        onPanEnd: (details) => onPanEnd(details, model),
        onPanDown: (details) => onPanDown(details, model),
        child: RepaintBoundary(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(4.0),
              color: Colors.transparent,
              alignment: Alignment.topLeft,
              child: StreamBuilder<Segment>(
                stream: model.currentSegmentStreamController.stream,
                builder: (context, snapshot) {
                  // model.addListener(() {
                  //  print('currentSegemntmodel triggered ') ;
                  // });
                  return CustomPaint(
                    painter: Sketcher(
                      lines: [model.currentlyDrawnSegment],
                    ),
                  );
                },
              )),
        ),
      ),
    );
    // );
  }

  /// Logic when user starts drawing in the canvas.
  void onPanStart(DragStartDetails details, CurrentPathViewModel model) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset offset = new Offset(point.dx, point.dy);

    switch (_modesVM.selectedMode) {
      case Mode.defaultMode:
        onPanStartWithDefaultMode(offset, model);
        break;
      case Mode.pointMode:
        onPanStartWithPointMode(details, offset, model);
        break;
      case Mode.selectionMode:
        break;
    }
  }

  void onPanStartWithDefaultMode(Offset offset, CurrentPathViewModel model) {
    model.setCurrentlyDrawnSegment(offset);
  }

  void onPanStartWithPointMode(DragStartDetails details, Offset offset, CurrentPathViewModel model) {
    model.changeSelectedSegmentDependingNewOffset(offset);
  }

  /// Logic when user continuous drawing in the canvas while holding down finger.
  void onPanUpdate(DragUpdateDetails details, CurrentPathViewModel model) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);

    switch (_modesVM.selectedMode) {
      case Mode.defaultMode:
        onPanUpdateWithSelectionMode(point2, model);
        break;
      case Mode.pointMode:
        onPanUpdateWithPointMode(point2, model);
        break;
      case Mode.selectionMode:
        onPanUpdateWithSelectionMode(point2, model);
        break;
    }
  }

  void onPanUpdateWithSelectionMode(Offset offset, CurrentPathViewModel model) {
    model.addToPathOfCurrentlyDrawnSegment(offset);
  }

  void onPanUpdateWithPointMode(Offset newOffset, CurrentPathViewModel model) {
    model.changeSelectedSegmentDependingNewOffset(newOffset);
  }

  /// Logic when user stops drawing in the canvas.
  void onPanEnd(DragEndDetails details, CurrentPathViewModel model) {
    switch (_modesVM.selectedMode) {
      case Mode.defaultMode:
        onPanEndWithDefaultMode(model);
        break;
      case Mode.pointMode:
        onPanEndWithPointMode(model);
        break;
      case Mode.selectionMode:
        break;
    }
  }

  void onPanEndWithPointMode(CurrentPathViewModel model) {
    model.mergeSegmentsIfNearToEachOther(model.currentlyDrawnSegment, 30);
  }

  void onPanEndWithDefaultMode(CurrentPathViewModel model) {
    model
      ..currentlyDrawnSegment =
          model.straigthenSegment(model.currentlyDrawnSegment)
      ..segments.add(model.currentlyDrawnSegment)
      ..updateCurrentSegmentLineStreamController()
      ..updateSegmentsStreamController();
    print('segments: ${model.segments.length}');
  }

  void onPanDown(DragDownDetails details, CurrentPathViewModel model) {
    if (_modesVM.selectedMode == Mode.selectionMode) {
      selectSegment(details, model);
    }
    if (_modesVM.selectedMode == Mode.pointMode) {
      model.selectPoint(
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

  void selectSegment(DragDownDetails details, CurrentPathViewModel model) {
    Segment nearestSegment = model.getNearestSegment(details);
    // if (nearestSegment != currentPathVM.currentlyDrawnSegment) {
    model.changeSelectedSegment(nearestSegment);
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

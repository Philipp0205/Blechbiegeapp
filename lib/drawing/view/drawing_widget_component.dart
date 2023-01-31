import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/drawing/drawing_page/bloc/drawing_page_bloc.dart';
import 'package:open_bsp/drawing/drawing_widget/bloc/drawing_widget_state.dart';

import '../drawing_widget/bloc/drawing_widget_event.dart';
import '../drawing_widget/drawing_widget.dart';
import 'drawing_widget_sketcher.dart';

/// Widget which the the line is drawn on. Gestures from the user are
/// registered with a [GestureDetector] and drawn on the screen with the
/// [DrawingWidgetSketcher] widget.
class DrawingWidget extends StatefulWidget {
  @override
  _DrawingWidgetState createState() => _DrawingWidgetState();
}

class _DrawingWidgetState extends State<DrawingWidget> {
  @override
  Widget build(BuildContext context) {
    // Listens for if the mode was changed in the parent widget [DrawingPage]
    return BlocListener<DrawingPageBloc, DrawingPageState>(
      listenWhen: (prev, current) =>
          prev.selectionMode != current.selectionMode,
      listener: (BuildContext context, state) {
        context.read<DrawingWidgetBloc>().add(LineDrawingSelectionModeSelected(
            selectionMode: state.selectionMode));
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.4), width: 1),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5)),
        ),
        child: BlocBuilder<DrawingWidgetBloc, DrawingWidgetState>(
            builder: (context, state) {
          /// Contains the part where the user can draw the line.
          return GestureDetector(
            onPanStart: (details) => onPanStart(context, details, state),
            onPanUpdate: (details) => onPanUpdate(context, details, state),
            onPanDown: (details) => onPanDown(context, details, state),
            child: RepaintBoundary(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.9,
                child: CustomPaint(
                  painter: DrawingWidgetSketcher(
                    lines2: state.lines,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  ///A pointer has contacted the screen with a primary button and has begun to
  ///move.
  void onPanStart(BuildContext context, DragStartDetails details,
      DrawingWidgetState state) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);

    context
        .read<DrawingWidgetBloc>()
        .add(LineDrawingStarted(firstDrawnOffset: point));
  }

  ///  A pointer that is in contact with the screen with a primary button and
  ///  moving has moved again.
  void onPanUpdate(BuildContext context, DragUpdateDetails details,
      DrawingWidgetState state) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);

    context
        .read<DrawingWidgetBloc>()
        .add(LineDrawingUpdated(updatedOffset: point));
  }

  /// The pointer that previously triggered onPanDown did not complete.
  void onPanDown(
      BuildContext context, DragDownDetails details, DrawingWidgetState state) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);

    context
        .read<DrawingWidgetBloc>()
        .add(LineDrawingPanDown(panDownOffset: point2));
  }
}

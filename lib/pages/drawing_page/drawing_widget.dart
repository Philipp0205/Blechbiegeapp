import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';

import '../../bloc /drawing_page/segment_widget/drawing_widget_bloc.dart';
import '../../bloc /drawing_page/segment_widget/drawing_widget_event.dart';
import '../../bloc /drawing_page/segment_widget/drawing_widget_state.dart';
import '../../model/appmodes.dart';
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
    return MultiBlocListener(
      listeners: [
        /// Listen for mode changes in DrawingPage
        BlocListener<DrawingPageBloc, DrawingPageState>(
            listenWhen: (previous, current) => previous.mode != current.mode,
            listener: (context, state) {
              context
                  .read<DrawingWidgetBloc>()
                  .add(CurrentSegmentModeChanged(mode: state.mode));
            }),
      ],

      /// Rebuild when change in state happens.
      child: BlocBuilder<DrawingWidgetBloc, DrawingWidgetState>(
          builder: (context, state) {
        /// Contains the part where the user can draw the line.
        return Container(
          height: 300,
          width: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          child: GestureDetector(
            onPanStart: (details) => onPanStart(context, details, state),
            onPanUpdate: (details) => onPanUpdate(context, details, state),
            onPanDown: (details) => onPanDown(context, details, state),
            child: RepaintBoundary(
              child: Container(
                // width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height,
                width: 300,
                height: 500,
                child: CustomPaint(
                  painter: DrawingWidgetSketcher(
                    lines: state.segment,
                    lines2: state.lines,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
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
  void onPanDown(BuildContext context, DragDownDetails details,
      DrawingWidgetState state) {
    Mode mode = context.read<DrawingPageBloc>().state.mode;

    context
        .read<DrawingWidgetBloc>()
        .add(CurrentSegmentPanDowned(details: details, mode: mode));


  }
}

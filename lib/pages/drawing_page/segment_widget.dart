import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';

import '../../bloc /drawing_page/segment_widget/current_segment_event.dart';
import '../../bloc /drawing_page/segment_widget/current_segment_state.dart';
import '../../bloc /drawing_page/segment_widget/segment_widget_bloc.dart';
import '../../model/appmodes.dart';
import 'sketcher.dart';

/// Widget which the the line/segment is drawn on. Gestures from the user are
/// registered via a [GestureDetector] and drawn on the screen with the
/// [DrawingSketcher] widget.
class SegmentWidget extends StatefulWidget {
  @override
  _SegmentWidgetState createState() => _SegmentWidgetState();
}

class _SegmentWidgetState extends State<SegmentWidget> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        /// Listen for mode changes in DrawingPage
        BlocListener<DrawingPageBloc, DrawingPageState>(
            listenWhen: (previous, current) => previous.mode != current.mode,
            listener: (context, state) {
              context
                  .read<SegmentWidgetBloc>()
                  .add(CurrentSegmentModeChanged(mode: state.mode));
            }),
      ],
      /// Rebuild when change in state happens.
      child: BlocBuilder<SegmentWidgetBloc, SegmentWidgetBlocState>(
          builder: (context, state) {
        return GestureDetector(
          onPanStart: (details) => onPanStart(context, details, state),
          onPanUpdate: (details) => onPanUpdate(context, details, state),
          onPanEnd: (details) => onPanEnd(context, details, state),
          onPanDown: (details) => onPanDown(context, details, state),
          child: RepaintBoundary(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CustomPaint(
                painter: DrawingSketcher(
                  lines: state.segment,
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
      SegmentWidgetBlocState state) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);
    Mode mode = context.read<DrawingPageBloc>().state.mode;
    context
        .read<SegmentWidgetBloc>()
        .add(CurrentSegmentPanStarted(firstDrawnOffset: point2, mode: mode));
  }

  ///  A pointer that is in contact with the screen with a primary button and
  ///  moving has moved again.
  void onPanUpdate(BuildContext context, DragUpdateDetails details,
      SegmentWidgetBlocState state) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);
    Mode mode = context.read<DrawingPageBloc>().state.mode;
    context.read<SegmentWidgetBloc>().add(CurrentSegmentPanUpdated(
        segment: state.segment.first, offset: point2, mode: mode));
  }

  /// A pointer that is in contact with the screen with a primary button and
  /// moving has moved again.
  void onPanEnd(
      BuildContext context, DragEndDetails details, SegmentWidgetBlocState state) {
    Mode mode = context.read<DrawingPageBloc>().state.mode;
    context
        .read<SegmentWidgetBloc>()
        .add(CurrentSegmentPanEnded(segment2: state.segment.first, mode: mode));
  }

  /// The pointer that previously triggered onPanDown did not complete.
  void onPanDown(BuildContext context, DragDownDetails details,
      SegmentWidgetBlocState state) {
    Mode mode = context.read<DrawingPageBloc>().state.mode;
    context
        .read<SegmentWidgetBloc>()
        .add(CurrentSegmentPanDowned(details: details, mode: mode));
  }
}

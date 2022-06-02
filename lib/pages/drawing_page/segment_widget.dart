import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/current_path/segment_widget_bloc.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';

import '../../bloc /all_paths/all_segments_bloc.dart';
import '../../bloc /current_path/current_segment_event.dart';
import '../../bloc /current_path/current_segment_state.dart';
import '../../model/appmodes.dart';
import 'bottom_sheet.dart';
import 'sketcher.dart';

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
      child: BlocBuilder<SegmentWidgetBloc, CurrentSegmentState>(
          builder: (context, state) {
        return GestureDetector(
          onPanStart: (details) => onPanStart(context, details, state),
          onPanUpdate: (details) => onPanUpdate(context, details, state),
          onPanEnd: (details) => onPanEnd(context, details, state),
          onPanDown: (details) => onPanDown(context, details, state),
          onDoubleTap: () => onDoubleTab(context, state),
          child: RepaintBoundary(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(4.0),
              color: Colors.transparent,
              alignment: Alignment.topLeft,
              child: CustomPaint(
                painter: Sketcher(
                  lines: state.currentSegment,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void onPanStart(BuildContext context, DragStartDetails details,
      CurrentSegmentState state) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);
    Mode mode = context.read<DrawingPageBloc>().state.mode;
    context
        .read<SegmentWidgetBloc>()
        .add(CurrentSegmentPanStarted(firstDrawnOffset: point2, mode: mode));
  }

  void onPanUpdate(BuildContext context, DragUpdateDetails details,
      CurrentSegmentState state) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);
    Mode mode = context.read<DrawingPageBloc>().state.mode;
    context.read<SegmentWidgetBloc>().add(CurrentSegmentPanUpdated(
        currentSegment: state.currentSegment, offset: point2, mode: mode));
  }

  void onPanEnd(
      BuildContext context, DragEndDetails details, CurrentSegmentState state) {
    Mode mode = context.read<DrawingPageBloc>().state.mode;
    context.read<SegmentWidgetBloc>().add(CurrentSegmentPanEnded(
        currentSegment: state.currentSegment, mode: mode));
    // context.read<AllSegmentsBloc>().add(AllSegmentsUpdated());
  }

  void onPanDown(BuildContext context, DragDownDetails details,
      CurrentSegmentState state) {
    Mode mode = context.read<DrawingPageBloc>().state.mode;
    context
        .read<SegmentWidgetBloc>()
        .add(CurrentSegmentPanDowned(details: details, mode: mode));
  }

  void onDoubleTab(BuildContext context, CurrentSegmentState state) {

  }
}

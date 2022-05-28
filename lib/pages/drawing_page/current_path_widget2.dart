import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/current_path/current_path_bloc/current_path_bloc.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';

import '../../bloc /all_paths/all_paths_bloc.dart';
import '../../model/appmodes.dart';
import 'sketcher.dart';

class CurrentPathWidget2 extends StatefulWidget {
  @override
  _CurrentPathWidget2State createState() => _CurrentPathWidget2State();
}

class _CurrentPathWidget2State extends State<CurrentPathWidget2> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentPathBloc, CurrentPathState>(
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
    });
  }

  void onPanStart(
      BuildContext context, DragStartDetails details, CurrentPathState state) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);
    Mode mode = context.read<DrawingPageBloc>().state.mode;
    context
        .read<CurrentPathBloc>()
        .add(CurrentPathPanStarted(firstDrawnOffset: point2, mode: mode));
  }

  void onPanUpdate(
      BuildContext context, DragUpdateDetails details, CurrentPathState state) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);
    Mode mode = context.read<DrawingPageBloc>().state.mode;
    context.read<CurrentPathBloc>().add(CurrentPathPanUpdated(
        currentSegment: state.currentSegment, offset: point2, mode: mode));
  }

  void onPanEnd(
      BuildContext context, DragEndDetails details, CurrentPathState state) {
    print('onPanend');
    Mode mode = context.read<DrawingPageBloc>().state.mode;
    context
        .read<CurrentPathBloc>()
        .add(CurrentPathPanEnded(currentSegment: state.currentSegment, mode: mode));
    context
        .read<AllPathsBloc>()
        .add(AllPathsUpdated());
    // context.read<CurrentPathBloc>().add(CurrentSegmentDeleted());
  }

  void onPanDown(
      BuildContext context, DragDownDetails details, CurrentPathState state) {
      Mode mode = context.read<DrawingPageBloc>().state.mode;
      context
          .read<CurrentPathBloc>()
          .add(CurrentPathPanDowned(details: details, mode: mode));
  }
}

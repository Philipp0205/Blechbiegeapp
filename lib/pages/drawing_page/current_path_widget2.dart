import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/current_path/current_path_bloc.dart';

import '../../services/viewmodel_locator.dart';
import '../../viewmodel/modes_controller_view_model.dart';
import 'sketcher.dart';

class CurrentPathWidget2 extends StatefulWidget {
  @override
  _CurrentPathWidget2State createState() => _CurrentPathWidget2State();
}

class _CurrentPathWidget2State extends State<CurrentPathWidget2> {
  ModesViewModel _modesVM = getIt<ModesViewModel>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentPathBloc, CurrentPathState>(
        builder: (context, state) {
          return GestureDetector(
            onPanStart: (details) => onPanStart(context, details, state),
            onPanUpdate: (details) => onPanUpdate(context, details, state),
            child: RepaintBoundary(
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                padding: EdgeInsets.all(4.0),
                color: Colors.transparent,
                alignment: Alignment.topLeft,
                child: CustomPaint(
                  painter: Sketcher(
                    lines: [state.currentSegment.first],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  onPanStart(BuildContext context, DragStartDetails details, CurrentPathState state) {
    print('on pan start');
    // context.read<CurrentPathBloc>().add(OnPanStarted(currentSegment: state.currentSegment));
  }

  void onPanUpdate(BuildContext context, DragUpdateDetails details, CurrentPathState state) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    Offset point2 = new Offset(point.dx, point.dy);
    context.read<CurrentPathBloc>().add(OnPanUpdated(currentSegment: state.currentSegment, offset: point2));

  }
}


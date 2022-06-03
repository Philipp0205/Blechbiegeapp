import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/all_paths/all_segments_bloc.dart';
import 'package:open_bsp/bloc%20/current_path/geometric_calculations_service.dart';
import 'package:open_bsp/bloc%20/current_path/segment_widget_bloc.dart';
import 'package:open_bsp/bloc%20/current_path/current_segment_event.dart';
import 'package:open_bsp/bloc%20/current_path/current_segment_state.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';
import 'package:open_bsp/model/segment.dart';

import '../../model/appmodes.dart';
import '../../services/viewmodel_locator.dart';
import '../../viewmodel/all_paths_view_model.dart';
import '../../viewmodel/current_path_view_model.dart';
import '../../viewmodel/modes_controller_view_model.dart';

class AppBottomSheet extends StatefulWidget {
  const AppBottomSheet({Key? key}) : super(key: key);

  @override
  State<AppBottomSheet> createState() => _AppBottomSheetState();
}

class _AppBottomSheetState extends State<AppBottomSheet> {
  // SketcherController _allPathsController = getIt<SketcherController>();
  AllPathsViewModel _allPathsVM = getIt<AllPathsViewModel>();
  ModesViewModel _modesVM = getIt<ModesViewModel>();
  CurrentPathViewModel _currentPathVM = getIt<CurrentPathViewModel>();
  AllPathsViewModel _allPathsViewModel = getIt<AllPathsViewModel>();

  final GeometricCalculationsService _calculationsService =
      new GeometricCalculationsService();

  final _angleController = TextEditingController();
  final _lengthController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _angleController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    List<Offset> offsets = context
        .read<SegmentWidgetBloc>()
        .state
        .currentSegment
        .first
        .selectedOffsets;
    int index = offsets.indexOf(offsets.last);
    double distance = (offsets[index - 1] - offsets.last).distance;

    if (distance > 1) {
      _lengthController.text = distance.toStringAsFixed(2);
    }

    if (offsets.length == 2) {
      double angle = _calculationsService.getAngle(offsets.first, offsets.last);

      _angleController.text = angle.toStringAsFixed(2);
    }

    // Start listening to changes.
    // myController.addListener(_printLatestValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 275,
      child: BlocBuilder<SegmentWidgetBloc, CurrentSegmentState>(
        builder: (context, state) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      onPressed: () {
                        context
                            .read<SegmentWidgetBloc>()
                            .add(SegmentPartDeleted());
                      },
                      icon: Icon(Icons.delete),
                      iconSize: 30,
                      color: Colors.grey),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      width: 60,
                      height: 55,
                      child: TextField(
                          decoration: InputDecoration(labelText: 'Länge'),
                          autofocus: true,
                          controller: _lengthController,
                          keyboardType: TextInputType.number,
                          onChanged: (text) {
                            double length = double.parse(text);
                            if (length != double.nan) {
                              context.read<SegmentWidgetBloc>().add(
                                  SegmentPartLengthChanged(length: length));
                            }
                          }),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 55,
                    child: TextField(
                        decoration: InputDecoration(labelText: 'Winkel'),
                        controller: _angleController,
                        keyboardType: TextInputType.number,
                        onChanged: (text) {
                          context.read<SegmentWidgetBloc>().add(
                              SegmentPartAngleChanged(
                                  angle: double.parse(text),
                                  length:
                                      double.parse(_lengthController.text)));
                        }),
                  ),
                  IconButton(
                    onPressed: () {
                      _currentPathVM
                          .updateSegment(_currentPathVM.currentlyDrawnSegment);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.save),
                    iconSize: 30,
                    color: Colors.grey,
                  ),
                  IconButton(
                      onPressed: () {
                        context.read<DrawingPageBloc>().add(
                            DrawingPageModeChanged(mode: Mode.pointMode));
                      },
                      icon: Icon(Icons.drag_indicator),
                    iconSize: 35,
                      color: Colors.grey,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

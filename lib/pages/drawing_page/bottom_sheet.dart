import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/all_paths/all_segments_bloc.dart';
import 'package:open_bsp/bloc%20/current_path/segment_widget_bloc.dart';
import 'package:open_bsp/bloc%20/current_path/current_segment_event.dart';
import 'package:open_bsp/bloc%20/current_path/current_segment_state.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    double _currentSliderValue = _currentPathVM.currentlyDrawnSegment.width;
    return Container(
      height: 150,
      child: BlocBuilder<SegmentWidgetBloc, CurrentSegmentState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(padding: EdgeInsets.all(10), child: Text('Länge')),
              // Slider(
              //   value: _currentSliderValue,
              //   max: _currentPathController.currentlyDrawnSegment.width + 100,
              //   divisions: 5,
              //   min: _currentPathController.currentlyDrawnSegment.width - 100,
              //   label: _currentSliderValue.round().toString(),
              //   onChanged: (double value) {
              //     state(() {
              //       _currentSliderValue = value;
              //       _currentPathController.extendSegment(_allPathsController.selectedSegment, _currentSliderValue);
              //     });
              //     setState(() {});
              //   },
              // ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          context.read<SegmentWidgetBloc>().add(new CurrentSegmentDeleted());
                          context.read<AllSegmentsBloc>().add(new AllSegmentsUpdated());
                        },
                        child: const Text('Löschen')),
                    ElevatedButton(
                        onPressed: () {
                          context.read<DrawingPageBloc>().add(DrawingPageModeChanged(mode: Mode.pointMode));
                        },
                        child: const Text('Edge M.')),
                    ElevatedButton(
                        onPressed: () {
                          _currentPathVM.updateSegment(
                              _currentPathVM.currentlyDrawnSegment);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Speichern')),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

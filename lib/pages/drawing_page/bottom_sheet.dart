import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return Container(
      height: 400,
      child: BlocBuilder<SegmentWidgetBloc, CurrentSegmentState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 40,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onSubmitted: (text) => context
                        .read<SegmentWidgetBloc>()
                        .add(SegmentPartLengthChanged(
                            length: double.parse(text))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            context
                                .read<SegmentWidgetBloc>()
                                .add(SegmentPartDeleted());
                          },
                          child: const Text('Löschen')),
                      ElevatedButton(
                          onPressed: () {
                            context.read<DrawingPageBloc>().add(
                                DrawingPageModeChanged(mode: Mode.pointMode));
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
            ),
          );
        },
      ),
    );
  }
}

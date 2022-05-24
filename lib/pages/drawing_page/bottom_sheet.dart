import 'package:flutter/material.dart';

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
      child: StatefulBuilder(
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
                          setState(() {
                            _allPathsVM.deleteSegment(
                                _currentPathVM.currentlyDrawnSegment);
                            _currentPathVM.clearCurrentLine();
                          });
                        },
                        child: const Text('Löschen')),
                    ElevatedButton(
                        onPressed: () {
                          _modesVM.setSelectedMode(Modes.pointMode);
                          // context
                          //     .read<AppModes>()
                          //     .setSelectedMode(Modes.pointMode);
                          Navigator.of(context).pop();
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

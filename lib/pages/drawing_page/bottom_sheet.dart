import 'package:flutter/material.dart';

import '../../controller/sketcher_controller.dart';
import '../../model/appmodes.dart';
import '../../services/controller_locator.dart';

class AppBottomSheet extends StatefulWidget {

  const AppBottomSheet({Key? key}) : super(key: key);


  @override
  State<AppBottomSheet> createState() => _AppBottomSheetState();
}

class _AppBottomSheetState extends State<AppBottomSheet> {
  SketcherController controller = getIt<SketcherController>();


  @override
  Widget build(BuildContext context) {
    double _currentSliderValue = controller.selectedSegment.width;
    return Container(
      height: 150,
      child: StatefulBuilder(
        builder: (context, state) {
          return Column(
            children: [
              Padding(padding: EdgeInsets.all(10), child: Text('Länge')),
              Slider(
                value: _currentSliderValue,
                max: controller.selectedSegment.width + 100,
                divisions: 5,
                min: controller.selectedSegment.width - 100,
                label: _currentSliderValue.round().toString(),
                onChanged: (double value) {
                  state(() {
                    _currentSliderValue = value;
                    controller.extendSegment(controller.selectedSegment, _currentSliderValue);
                  });
                  setState(() {});
                },
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            controller.deleteSegment(controller.selectedSegment);
                          });
                        },
                        child: const Text('Löschen')),
                    ElevatedButton(
                        onPressed: () {
                          controller.setSelectedMode(Modes.pointMode);
                          // context
                          //     .read<AppModes>()
                          //     .setSelectedMode(Modes.pointMode);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Edge M.')),
                    ElevatedButton(
                        onPressed: () {
                          controller.saveLine(controller.selectedSegment);
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

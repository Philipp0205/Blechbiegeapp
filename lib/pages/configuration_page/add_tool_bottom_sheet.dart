import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/configuration_page/configuration_page_bloc.dart';
import 'package:open_bsp/bloc%20/shapes_page/tool_page_bloc.dart';
import 'package:open_bsp/model/simulation/tool.dart';
import 'package:open_bsp/persistence/database_provider.dart';

import '../../model/line.dart';
import '../../model/simulation/tool_type.dart';

/// Bottom sheet which appears when the users adds a shape.
class AddToolBottomSheet extends StatefulWidget {
  final Tool? selectedShape;

  const AddToolBottomSheet({Key? key, required this.selectedShape})
      : super(key: key);

  @override
  State<AddToolBottomSheet> createState() =>
      _AddToolBottomSheetState(selectedShape: selectedShape);
}

class _AddToolBottomSheetState extends State<AddToolBottomSheet> {
  final _nameController = TextEditingController();
  bool lowerCheek = false;
  bool upperCheek = false;
  final Tool? selectedShape;

  String? dropdownValue = 'Unterwange';

  _AddToolBottomSheetState({required this.selectedShape});

  /// Fills in the TextField and dropdown with initial values of the selected
  /// shape if present.
  @override
  void initState() {
    super.initState();
    if (selectedShape != null) {
      _nameController.text = selectedShape!.name;
      setState(() {
        dropdownValue = _getNameOfType(selectedShape!.type);
      });
    }
  }

  /// Disposes the TextField controller when page is not needed anymore.
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Builds the bottom sheet.
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      child: BlocBuilder<ConfigPageBloc, ConfigPageState>(
          builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              buildTitleRow(),
              Divider(),
              buildNameRow(),
              buildButtonRow(state, context),
            ],
          ),
        );
      }),
    );
  }

  /// Builds the row containing two buttons.
  Row buildButtonRow(ConfigPageState state, BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            List<Line> lines = context.read<ConfigPageBloc>().state.lines;
            _saveTool(_nameController.text, lines);
          },
          child: Text('Speichern'),
        ),
        Container(
          width: 10,
        ),
        ElevatedButton(
          onPressed: () {
            context
                .read<ToolPageBloc>()
                .add(ToolPageCreated());

            // Close bottom sheet
            Navigator.pop(context);

            Navigator.of(context).pushNamed("/shapes");
          },
          child: Text('Übersicht Werkzeuge'),
        ),
      ],
    );
  }

  /// Builds the row where the suer can set the name and the type of the shape.
  Row buildNameRow() {
    return Row(
      children: [
        Container(
          width: 150,
          height: 50,
          child: TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
        ),
        Container(width: 10),
        DropdownButton(
            value: dropdownValue,
            items: <String>['Unterwange', 'Oberwange', 'Biegewange']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
                print('dropdownvalue changed: ${newValue}');
              });
            }),
        Container(
          width: 10,
        ),
        Container(
          width: 20,
        ),
      ],
    );
  }

  /// Builds the row containing the title of the bottom sheet.
  /// The title is either "Neues Werkzeug" or "Werkzeug bearbeiten".
  /// The title is determined by the selected shape.
  Row buildTitleRow() {
    return Row(
      children: [
        Text(
          'Werkzeug hinzufügen',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Saves the shape to the database and notified the [ToolPageBloc].j
  void _saveTool(String name, List<Line> lines) {
    ToolType type = ToolType.upperBeam;

    switch (dropdownValue) {
      case 'Oberwange':
        type = ToolType.upperBeam;
        print('saved shape type: ${type}');
        break;
      case 'Unterwange':
        type = ToolType.lowerBeam;
        print('saved shape type: ${type}');
        break;
      case 'Biegewange':
        type = ToolType.bendingBeam;
        print('saved shape type: ${type}');
    }

    Tool tool = new Tool(
        name: _nameController.text,
        lines: lines,
        type: type,
        isSelected: false,
        adapterLine: []);

    if (selectedShape == null) {
      Navigator.of(context).pushNamed("/shapes");
      context.read<ToolPageBloc>().add(ToolAdded(tool: tool));
    } else {
      Navigator.pop(context);
      context.read<ToolPageBloc>().add(ToolEdited(tool: tool));
    }
  }

  /// Returns the name of the type of the shape.
  String _getNameOfType(ToolType type) {
    switch (type) {
      case ToolType.lowerBeam:
        return 'Unterwange';
      case ToolType.upperBeam:
        return 'Oberwange';
      case ToolType.bendingBeam:
        return 'Biegewange';
    }
  }
}

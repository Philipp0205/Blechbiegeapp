import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_bsp/bloc%20/configuration_page/configuration_page_bloc.dart';
import 'package:open_bsp/bloc%20/shapes_page/shapes_page_bloc.dart';
import 'package:open_bsp/model/OffsetAdapter.dart';
import 'package:open_bsp/model/simulation/shape.dart';
import 'package:open_bsp/persistence/database_service.dart';

import '../../model/line.dart';
import '../../model/offset.dart';
import '../../model/simulation/shape_type.dart';

/// Bottom sheet which appears when the users adds a shape.
class AddShapeBottomSheet extends StatefulWidget {
  final Shape? selectedShape;

  const AddShapeBottomSheet({Key? key, required this.selectedShape})
      : super(key: key);

  @override
  State<AddShapeBottomSheet> createState() =>
      _AddShapeBottomSheetState(selectedShape: selectedShape);
}

class _AddShapeBottomSheetState extends State<AddShapeBottomSheet> {
  final _nameController = TextEditingController();
  bool lowerCheek = false;
  bool upperCheek = false;
  final Shape? selectedShape;

  String? dropdownValue = 'Unterwange';

  _AddShapeBottomSheetState({required this.selectedShape});

  DatabaseService _service = DatabaseService();

  @override
  void initState() {
    super.initState();
    if (selectedShape != null) {
      _nameController.text = selectedShape!.name;
      print('initial type ${_getNameOfType(selectedShape!.type)}');
      setState(() {
        dropdownValue = _getNameOfType(selectedShape!.type);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
              buildButtonRow(context),
            ],
          ),
        );
      }),
    );
  }

  Row buildButtonRow(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            List<Line> lines = context.read<ConfigPageBloc>().state.lines;
            _saveShape(_nameController.text, lines);
          },
          child: Text('Speichern'),
        ),
        Container(
          width: 10,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/shapes");
          },
          child: Text('Übersicht Werkzeuge'),
        ),
      ],
    );
  }

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

  void _saveShape(String name, List<Line> lines) {
    ShapeType type = ShapeType.upperBeam;

    print('DropDownvalue ${dropdownValue}');

    switch (dropdownValue) {
      case 'Oberwange':
        type = ShapeType.upperBeam;
        print('saved shape type: ${type}');
        break;
      case 'Unterwange':
        type = ShapeType.lowerBeam;
        print('saved shape type: ${type}');
        break;
      case 'Biegewange':
        type = ShapeType.bendingBeam;
        print('saved shape type: ${type}');
    }

    Shape shape =
        new Shape(name: _nameController.text, lines: lines, type: type);

    context.read<ShapesPageBloc>().add(ShapeAdded(shape: shape));

    if (selectedShape == null) {

      Navigator.of(context).pushNamed("/shapes");
    } else {
      Navigator.pop(context);
    }
  }

  String _getNameOfType(ShapeType type) {
    switch (type) {
      case ShapeType.lowerBeam:
        return 'Unterwange';
      case ShapeType.upperBeam:
        return 'Oberwange';
      case ShapeType.bendingBeam:
        return 'Biegewange';
    }
  }
}


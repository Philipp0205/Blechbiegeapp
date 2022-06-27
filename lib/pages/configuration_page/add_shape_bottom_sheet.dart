import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/configuration_page/configuration_page_bloc.dart';
import 'package:open_bsp/bloc%20/shapes_page/shapes_page_bloc.dart';
import 'package:open_bsp/model/simulation/shape.dart';

import '../../model/segment_widget/segment.dart';

/// Bottom sheet which appears when the users adds a shape.
class AddShapeBottomSheet extends StatefulWidget {
  const AddShapeBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddShapeBottomSheet> createState() => _AddShapeBottomSheetState();
}

class _AddShapeBottomSheetState extends State<AddShapeBottomSheet> {
  final _nameController = TextEditingController();
  bool lowerCheek = false;
  bool upperCheek = false;

  String dropdownValue = 'Unterwange';

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
              Row(
                children: [
                  Text(
                    'Werkzeug hinzufügen',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Divider(),
              Row(
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
                      items: <String>[
                        'Unterwange',
                        'Oberwange',
                        'Hinteranschlag'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      }),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 20,
                  ),
                ],
              ),
              Row(
                children: [],
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Segment segment =
                          context.read<ConfigPageBloc>().state.segment.first;
                      _saveShape(_nameController.text, segment);
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
              ),
            ],
          ),
        );
      }),
    );
  }

  void _saveShape(String name, Segment segment) {
    List<Offset> path = segment.path.map((e) => e.offset).toList();

    ShapeType type = ShapeType.upperBeam;

    switch (dropdownValue) {
      case 'Oberwange':
        type = ShapeType.upperBeam;
        break;
      case 'Unterwange:':
        type = ShapeType.lowerBeam;
        break;
      case 'Hinteranschlag':
        type:
        ShapeType.backstop;
    }

    Shape shape = new Shape(name: _nameController.text, path: path, type: type);
    context.read<ShapesPageBloc>().add(ShapeAdded(shape: shape));
    print('added shape ${shape.name}');

    Navigator.of(context).pushNamed("/shapes");
  }
}

enum ShapeType { lowerBeam, upperBeam, backstop }

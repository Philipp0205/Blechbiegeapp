import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/configuration_page/configuration_page_bloc.dart';
import 'package:open_bsp/model/simulation/shape.dart';

import '../../model/segment_widget/segment.dart';

class AddShapeBottomSheet extends StatefulWidget {
  const AddShapeBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddShapeBottomSheet> createState() => _AddShapeBottomSheetState();
}

class _AddShapeBottomSheetState extends State<AddShapeBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
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
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Name',
                        ),
                      ),
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () { },
                    child: Text('Speichern'),
                  )
                ],
              )
            ],
          ),
        );
      }),
    );
  }

  void _saveShape(String name) {
    Segment segment = context.read<ConfigPageBloc>().state.segment.first;
    List<Offset> path = segment.path.map((e) => e.offset).toList();

    Shape shape = new Shape(name: name, path:  path);
  }
}

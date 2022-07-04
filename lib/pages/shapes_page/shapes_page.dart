import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:open_bsp/bloc%20/configuration_page/configuration_page_bloc.dart';
import 'package:open_bsp/bloc%20/shapes_page/shapes_page_bloc.dart';
import 'package:open_bsp/pages/configuration_page/add_shape_bottom_sheet.dart';

import '../../model/simulation/shape.dart';

class ShapesPage extends StatefulWidget {
  const ShapesPage({Key? key}) : super(key: key);

  @override
  State<ShapesPage> createState() => _ShapesPageState();
}

class _ShapesPageState extends State<ShapesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Werkzeuge')),
      body: BlocBuilder<ConfigPageBloc, ConfigPageState>(
        buildWhen: (prev, current) {
          List<String> prevNames = prev.shapes.map((shape) => shape.name).toList();
          List<String> currentNames = current.shapes.map((shape) => shape.name).toList();
          return prevNames != currentNames;
        },
        builder: (context, state) {
          print('shape name: ${state.shapes[0].name}');
          return state.shapes.isNotEmpty
              ? ListView.builder(
                  itemCount: state.shapes.length,
                  itemBuilder: (context, index) {
                    /// List with [Shape]s.
                    return Slidable(
                        // Specify a key if the Slidable is dismissible.
                        key: const ValueKey(0),

                        // The start action pane is the one at the left or the top side.
                        startActionPane: ActionPane(
                          // A motion is a widget used to control how the pane animates.
                          motion: const ScrollMotion(),

                          // A pane can dismiss the Slidable.
                          dismissible: DismissiblePane(onDismissed: () {
                            print('${state.shapes.length} remaining shapes');
                            context
                                .read<ShapesPageBloc>()
                                .add(ShapeDeleted(shape: state.shapes[index]));
                          }),

                          // All actions are defined in the children parameter.
                          children: [
                            // A SlidableAction can have an icon and/or a label.
                            SlidableAction(
                              onPressed: (_) {
                                print(
                                    '${state.shapes.length} remaining shapes');
                                context.read<ShapesPageBloc>().add(
                                    ShapeDeleted(shape: state.shapes[index]));
                              },
                              backgroundColor: Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Löschen',
                            ),
                          ],
                        ),

                        // The end action pane is the one at the right or the bottom side.
                        endActionPane: ActionPane(
                          motion: ScrollMotion(),
                          children: [
                            SlidableAction(
                              // An action can be bigger than the others.
                              flex: 2,
                              onPressed: (_) {
                                _addShape(state.shapes[index]);
                              },
                              backgroundColor: Color(0xFF7BC043),
                              foregroundColor: Colors.white,
                              icon: Icons.drive_file_rename_outline,
                              label: 'Ändern',
                            ),
                          ],
                        ),

                        // The child of the Slidable is what the user sees when the
                        // component is not dragged.
                        child: ListTile(
                          title: Text(state.shapes[index].name),
                          // child: const ListTile(title: Text('Slide me')),
                        ));
                  })
              : const Center(
                  child: Text('List empty'),
                );
        },
      ),
    );
  }

  void _addShape(Shape shape) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return AddShapeBottomSheet(selectedShape: shape);
        });
  }
}

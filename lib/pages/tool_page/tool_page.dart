import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:open_bsp/bloc%20/shapes_page/tool_page_bloc.dart';
import 'package:open_bsp/pages/configuration_page/add_tool_bottom_sheet.dart';
import 'package:open_bsp/persistence/database_service.dart';

import '../../bloc /configuration_page/configuration_page_bloc.dart';
import '../../model/line.dart';
import '../../model/simulation/tool.dart';

class ToolPage extends StatefulWidget {
  const ToolPage({Key? key}) : super(key: key);

  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  DatabaseService _service = DatabaseService();

  /// Open the shape box and get all shapes.
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // List<Shape> shapes = context.read<ShapesPageBloc>().state.shapes;
    // context.read<ShapesPageBloc>().add(ShapesSavedToDisk(shapes: shapes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          Text('Werkzeuge'),
          Spacer(),
          ElevatedButton(
              onPressed: () => Hive.close(), child: Text('Speichern')),
        ],
      )),
      body: BlocBuilder<ToolPageBloc, ToolPageState>(
        buildWhen: (prev, current) {
          List<String> prevNames =
              prev.tools.map((shape) => shape.name).toList();
          List<String> currentNames =
              current.tools.map((shape) => shape.name).toList();
          return prevNames != currentNames;
        },
        builder: (context, state) {
          return state.tools.isNotEmpty
              ? ListView.builder(
                  itemCount: state.tools.length,
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
                            print('${state.tools.length} remaining shapes');
                            context
                                .read<ToolPageBloc>()
                                .add(ShapeDeleted(shape: state.tools[index]));
                          }),

                          // All actions are defined in the children parameter.
                          children: [
                            // A SlidableAction can have an icon and/or a label.
                            SlidableAction(
                              onPressed: (_) {
                                print(
                                    '${state.tools.length} remaining shapes');
                                context.read<ToolPageBloc>().add(
                                    ShapeDeleted(shape: state.tools[index]));
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
                                _editShape(state.tools[index]);
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
                          onTap: () => _loadTool(context, state.tools[index]),
                          title: Text(state.tools[index].name),
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

  /// Opens a modal bottom sheet where the shape can be edited.
  void _editShape(Tool shape) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return AddToolBottomSheet(selectedShape: shape);
        });
  }

  /// Load the [Line]s for the given [tool] and pushes them into the
  /// [ConfigPageBloc].
  void _loadTool(BuildContext context, Tool tool) {
    List<Line> lines = tool.lines;
    context.read<ConfigPageBloc>().add(ConfigPageCreated(lines: lines));
    Navigator.of(context).pop();

  }
}

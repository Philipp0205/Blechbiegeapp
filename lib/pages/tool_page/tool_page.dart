import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/shapes_page/tool_page_bloc.dart';
import 'package:open_bsp/model/simulation/tool_type.dart';
import 'package:open_bsp/pages/configuration_page/add_tool_bottom_sheet.dart';

import '../../bloc /configuration_page/configuration_page_bloc.dart';
import '../../model/line.dart';
import '../../model/simulation/tool.dart';

class ToolPage extends StatefulWidget {
  const ToolPage({Key? key}) : super(key: key);

  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  /// Open the shape box and get all shapes.
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToolPageBloc, ToolPageState>(builder: (context, state) {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: buildAppBar(context, state),
          body: buildTabBarViews(state, context),
        ),
      );
    });
  }
}

/// Build the pages of the [TabBarView].
/// Build the [TarbBarView] with the containing three [Tab]s with
/// lower beams, upper beams and bending beams.
TabBarView buildTabBarViews(ToolPageState state, BuildContext context) {
  return TabBarView(
    children: [
      buildListView(
        state,
        context,
        state.tools.where((tool) => tool.type == ToolType.lowerBeam).toList(),
      ),
      buildListView(
        state,
        context,
        state.tools.where((tool) => tool.type == ToolType.upperBeam).toList(),
      ),
      buildListView(
        state,
        context,
        state.tools.where((tool) => tool.type == ToolType.bendingBeam).toList(),
      ),
    ],
  );
}

/// Build the [AppBar] of the page.
/// Build the [AppBar] with the title and two [IconButton]s to delete and
/// edit a shape respectively. The [IconButton]s are only visible if in selection
/// mode.
AppBar buildAppBar(BuildContext context, ToolPageState state) {
  return AppBar(
    title: Row(
      children: [
        Text('Werkzeuge'),
        Spacer(),
        if (state.isSelectionMode)
          // Delete button
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTool(context, state.selectedTools)),
              IconButton(
                  onPressed: () =>
                      _editTool(context, state.tools, state.selectedTools),
                  icon: Icon(Icons.edit)),
            ],
          ),
      ],
    ),
    bottom: TabBar(tabs: [
      Tab(text: 'Unterwangen', icon: Icon(Icons.border_bottom)),
      Tab(text: 'Oberwangen', icon: Icon(Icons.border_top)),
      Tab(text: 'Biegewangen', icon: Icon(Icons.border_left)),
    ]),
  );
}

/// Load the [Line]s for the given [tool] and pushes them into the
/// [ConfigPageBloc].
void _loadTool(BuildContext context, Tool tool) {
  List<Line> lines = tool.lines;
  context.read<ConfigPageBloc>().add(ConfigPageCreated(lines: lines));
  Navigator.of(context).pop();
}

ListView buildListView(
    ToolPageState state, BuildContext context, List<Tool> tools) {
  return ListView.builder(
      itemCount: tools.length,
      itemBuilder: (_, int index) {
        return ListTile(
          onTap: () {
            _loadTool(context, tools[index]);
          },
          onLongPress: () {
            if (state.isSelectionMode) {
              _toggleSelectionMode(
                context,
                false,
              );
              _selectedToolsChanged(context, state, state.tools[index], true);
            } else {
              _toggleSelectionMode(context, true);
              // _selectedToolsChanged(context, state, state.tools[index], true);
            }
          },
          title: Text('${tools[index].name}'),
          trailing: state.isSelectionMode
              ? Checkbox(
                  value: state.selectedTools.values.toList()[0],
                  onChanged: (bool? x) => {
                    _selectedToolsChanged(
                        context, state, state.tools[index], x!),
                  },
                )
              : const SizedBox.shrink(),
        );
      });
}

/// Toggle the selection mode.
void _toggleSelectionMode(BuildContext context, bool value) {
  context
      .read<ToolPageBloc>()
      .add(SelectionModeChanged(isSelectionMode: value));
}

/// Triggered when a [Tool] is selected or deselected in the [ListView].
/// If the [Tool] is selected, it is added to the [selectedTools] map.
/// If the [Tool] is deselected, it is removed from the [selectedTools] map.
void _selectedToolsChanged(
    BuildContext context, ToolPageState state, Tool tool, bool value) {
  if (state.isSelectionMode) {
    context
        .read<ToolPageBloc>()
        .add(SelectedToolsChanged(tool: tool, value: value));
  }
}

/// Trigger event that deletes the selected [Tool]s.
/// Delete the selected [Tool]s and update the [ToolPageState].
void _deleteTool(BuildContext context, Map<Tool, bool> selectedTools) {
  context.read<ToolPageBloc>().add(ToolDeleted(selectedTools: selectedTools));
}

/// Trigger event that edits the selected [Tool]s.
/// Opens a modal bottom sheet where the shape can be edited.
void _editTool(
    BuildContext context, List<Tool> tools, Map<Tool, bool> selectedTools) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddToolBottomSheet(selectedShape: selectedTools.keys.first);
      });
}

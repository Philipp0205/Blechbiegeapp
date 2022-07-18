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
        state.beams.where((tool) => tool.type.type == ToolType.lowerBeam).toList(),
        ToolType.lowerBeam,
      ),
      buildListView(
          state,
          context,
          state.beams.where((tool) => tool.type.type == ToolType.upperBeam).toList(),
          ToolType.upperBeam),
      buildListView(
          state,
          context,
          state.beams
              .where((tool) => tool.type.type == ToolType.bendingBeam)
              .toList(),
          ToolType.bendingBeam),
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
          // Show delete button when one or more tools are selected.
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteTool(context, state)),
        // Because only one tool can be edited at a time, the edit button is
        // only visible when no tool is selected.
        if (state.isSelectionMode &&
            state.beams.where((tool) => tool.isSelected).length <= 1)
          IconButton(
              onPressed: () => _editTool(context, state.beams, state),
              icon: Icon(Icons.edit)),
      ],
    ),
    bottom: TabBar(tabs: [
      Tab(text: 'Unten', icon: Icon(Icons.border_bottom)),
      Tab(text: 'Oben', icon: Icon(Icons.border_top)),
      Tab(text: 'Links', icon: Icon(Icons.border_left)),
    ]),
  );
}

/// Load the [Line]s for the given [tool] and pushes them into the
/// [ConfigPageBloc].
void _loadTool(BuildContext context, Tool tool) {
  List<Line> lines = tool.lines;
  context
      .read<ConfigPageBloc>()
      .add(ConfigPageCreated(lines: lines, tools: [tool]));
  Navigator.of(context).pop();
}

/// Builds a list of [Tool]s.
ListView buildListView(ToolPageState state, BuildContext context,
    List<Tool> tools, ToolType toolType) {
  List<Tool> toolsOfType =
      tools.where((tool) => tool.type.type == toolType).toList();

  return ListView.builder(
      itemCount: toolsOfType.length,
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
              _selectedToolsChanged(context, state, state.beams[index], true);
            } else {
              _toggleSelectionMode(context, true);
              // _selectedToolsChanged(context, state, state.tools[index], true);
            }
          },
          title: Text('${tools[index].name}'),
          subtitle: Text('${tools[index].type.name}'),
          trailing: state.isSelectionMode
              ? Checkbox(
                  value: toolsOfType
                      .map((tool) => tool.isSelected)
                      .toList()[index],
                  onChanged: (bool? value) => {
                    print('index: $index, value: $value'),
                    _selectedToolsChanged(
                        context,
                        state,
                        // Get the correct tool from the correct list...
                        toolsOfType[index],
                        value!),
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
/// If the [Tool] is selected, it is added to the [beams] map.
/// If the [Tool] is deselected, it is removed from the [beams] map.
void _selectedToolsChanged(
    BuildContext context, ToolPageState state, Tool tool, bool value) {
  if (state.isSelectionMode) {
    context.read<ToolPageBloc>().add(SelectedToolsChanged(tool: tool));
  }
}

/// Trigger event that deletes the selected [Tool]s.
/// Delete the selected [Tool]s and update the [ToolPageState].
void _deleteTool(BuildContext context, ToolPageState state) {
  List<Tool> selectedTools =
      state.beams.where((tool) => tool.isSelected).toList();
  context.read<ToolPageBloc>().add(ToolDeleted(tools: selectedTools));
}

/// Trigger event that edits the selected [Tool]s.
/// Opens a modal bottom sheet where the shape can be edited.
void _editTool(BuildContext context, List<Tool> tools, ToolPageState state) {
  Tool selectedTool =
      state.beams.where((tool) => tool.isSelected).toList().first;

  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddToolBottomSheet(selectedShape: selectedTool);
      });
}

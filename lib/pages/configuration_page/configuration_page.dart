import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/shapes_page/tool_page_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/pages/configuration_page/add_tool_bottom_sheet.dart';
import 'package:open_bsp/persistence/repositories/tool_repository.dart';

import '../../bloc /configuration_page/configuration_page_bloc.dart';
import '../../model/line.dart';
import '../../model/simulation/tool.dart';
import '../../model/simulation/tool_type.dart';
import 'config_page_segment_widget.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({Key? key}) : super(key: key);

  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  /// TextField controllers
  final _sController = TextEditingController();
  final _rController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// When the page gets' created the TextFields get an initial value.
    double s = context.read<ConfigPageBloc>().state.s;
    double r = context.read<ConfigPageBloc>().state.r;
    _sController.text = s.toStringAsFixed(0);
    _rController.text = r.toStringAsFixed(0);

    // createDebuggingShapes();
  }

  @override
  void dispose() {
    _sController.dispose();
    _rController.dispose();
    super.dispose();
  }

  /// Build the page containing the [ConstructingSegmentWidget] which draw the
  /// line, a row of [Checkbox]es to show differents details of the line and
  /// a row of [TextField]s to configure the drawn line.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigPageBloc, ConfigPageState>(
        builder: (context, state) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: buildAppBar(),
        backgroundColor: Colors.white,
        floatingActionButton: buildFloatingActionButton(state, context),
        body: Container(
          child: Column(
            children: [
              /// Sketcher
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ConstructingPageSegmentWidget(),
              ),

              /// Checkboxes
              buildCheckboxRow(state, context),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.black,
                ),
              ),

              ///TextFields
              buildTextFieldRow(state, context),
              buildSetAdapterRow(state, context)
            ],
          ),
        ),
      );
    });
  }

  /// Builds the app bar of the page.
  AppBar buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('Konfiguration')],
      ),
    );
  }

  /// [TextField]s where the user can change the metal sheet thickness and
  /// the radius of the curves.
  Padding buildTextFieldRow(ConfigPageState state, BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            child: TextField(
                controller: _sController,
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  double? angle = double.tryParse(_sController.text);
                  if (angle != null) {
                    context
                        .read<ConfigPageBloc>()
                        .add(ConfigSChanged(s: angle));
                    context
                        .read<SimulationPageBloc>()
                        .add(SimulationSChanged(s: angle));
                  }
                }),
          ),
          Text('Bleckdicke (s)   '),
          Container(
            width: 30,
            height: 30,
            child: TextField(
                controller: _rController,
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  double? value = double.tryParse(text);
                  if (value != null) {
                    context.read<ConfigPageBloc>().add(
                        ConfigRChanged(r: double.parse(_rController.text)));
                  }
                }),
          ),
          Text('Radius (r)'),
          Container(
            width: 30,
          ),
          ElevatedButton(
              onPressed: () => _createShape(state), child: Text('+ Werkzeug'))
        ],
      ),
    );
  }

  /// [Row] containing checkboxes for showing different details of the drawn
  /// [Line]s.
  Row buildCheckboxRow(ConfigPageState state, BuildContext context) {
    return Row(
      children: [
        Checkbox(
            value: state.showCoordinates,
            onChanged: (bool? value) {
              context
                  .read<ConfigPageBloc>()
                  .add(ConfigCoordinatesShown(showCoordinates: value!));
              print('checkbox');
            }),
        Text('Koordinaten'),
        Checkbox(
            value: state.showEdgeLengths,
            onChanged: (bool? value) {
              context
                  .read<ConfigPageBloc>()
                  .add(ConfigEdgeLengthsShown(showEdgeLengths: value!));
            }),
        Text('Längen'),
        Checkbox(
            value: state.showAngles,
            onChanged: (bool? value) {
              context
                  .read<ConfigPageBloc>()
                  .add(ConfigAnglesShown(showAngles: value!));
            }),
        Text('Winkel'),
      ],
    );
  }

  /// Builds [Row] containing one more [Checkbox] for marking a line as adapter
  /// line.
  Row buildSetAdapterRow(ConfigPageState state, BuildContext context) {
    return Row(
      children: [
        Checkbox(
            value: state.markAdapterLineMode,
            onChanged: (bool? value) {
              _toggleAdapterLineMode(value!);
            }),
        Text('Adapter'),
      ],
    );
  }

  /// Builds the left [FloatingActionButton].
  Stack buildFloatingActionButton(ConfigPageState state, BuildContext context) {
    return Stack(
      children: [
        /// Right Button
        Positioned(
          bottom: 20,
          right: 10,
          child: FloatingActionButton(
            heroTag: "btn2",
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_right),
            onPressed: () {
              context
                  .read<SimulationPageBloc>()
                  .add(SimulationPageCreated(lines: state.lines));

              Navigator.of(context).pushNamed("/third");
            },
          ),
        ),
      ],
    );
  }

  /// Creates a new [Tool] using a [ModalBottomSheet]
  void _createShape(ConfigPageState state) {
    ToolPageBloc(context.read<ToolRepository>()).add(ToolPageCreated());

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // No selected shape because new Shapes created.
        return AddToolBottomSheet(selectedShape: null);
      },
    );
  }

  /// Toggles the adapter line mode.
  void _toggleAdapterLineMode(bool value) {
    context
        .read<ConfigPageBloc>()
        .add(ConfigToggleMarkAdapterLineMode(adapterLineMode: value));
  }
}

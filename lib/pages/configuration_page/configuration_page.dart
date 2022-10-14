import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/shapes_page/tool_page_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/pages/configuration_page/add_tool_bottom_sheet.dart';
import 'package:open_bsp/pages/drawing_page/two_coloumn_portrait_layout.dart';
import 'package:open_bsp/pages/widgets/app_title.dart';
import 'package:open_bsp/persistence/repositories/tool_repository.dart';

import '../../bloc /configuration_page/configuration_page_bloc.dart';
import '../../model/line.dart';
import '../../model/simulation/tool.dart';
import '../drawing_page/two_column_landscape_layout.dart';
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
  void onBackPressed() {
//some function
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
        body: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _buildPortraitLayout(state, context)
                : buildLandscapeLayout(state);
          },
        ),
      );
    });
  }

  TwoColumnPortraitLayout _buildPortraitLayout(
      ConfigPageState state, BuildContext context) {
    return TwoColumnPortraitLayout(
      upperRow: Row(
        children: [Expanded(child: ConstructingPageSegmentWidget())],
      ),
      lowerColumn: Column(
        children: [
          Column(
            children: [
              for (var widget in _buildMenuHeader()) widget,
            ],
          ),
          Divider(height: 20),
          Row(
            children: [
              Flexible(child: _buildSTextField(context)),
              SizedBox(width: 10),
              Flexible(child: _buildRadiusTextField(context)),
              SizedBox(width: 10),
              Flexible(child: _buildToolElevatedButton(state)),
            ],
          ),
          Divider(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                Flexible(child: _buildCoodinateCheckboxListTile(state)),
                VerticalDivider(),
                Flexible(child: _buildLengthCheckboxListTile(state)),
                VerticalDivider(),
                Flexible(child: _buildAngleCheckboxListTile(state)),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  /// Builds the app bar of the page.
  AppBar buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('Konfiguration des Profils'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppTitle(),
            ],
          )
        ],
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
          _buildSTextField(context),
          Container(width: 20),
          _buildRadiusTextField(context),
          Container(
            width: 30,
          ),
          _buildToolElevatedButton(state)
        ],
      ),
    );
  }

  ElevatedButton _buildToolElevatedButton(ConfigPageState state) {
    return ElevatedButton(
        onPressed: () => _createTool(state),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add),
            SizedBox(width: 10),
            Text('Werkzeuge'),
          ],
        ));
  }

  /// Builds the [TextField] where the user can change the radius of the
  /// profile.
  TextField _buildRadiusTextField(BuildContext context) {
    return TextField(
        decoration:
            InputDecoration(border: OutlineInputBorder(), labelText: 'Radius'),
        controller: _rController,
        keyboardType: TextInputType.number,
        onChanged: (text) {
          double? value = double.tryParse(text);
          if (value != null) {
            context
                .read<ConfigPageBloc>()
                .add(ConfigRChanged(r: double.parse(_rController.text)));
          }
        });
  }

  TextField _buildSTextField(BuildContext context) {
    return TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(), labelText: 'Blechdicke'),
        controller: _sController,
        keyboardType: TextInputType.number,
        onChanged: (text) {
          double? angle = double.tryParse(_sController.text);
          if (angle != null) {
            context.read<ConfigPageBloc>().add(ConfigSChanged(s: angle));
            context
                .read<SimulationPageBloc>()
                .add(SimulationSChanged(s: angle));
          }
        });
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

  Column buildCheckboxes2(ConfigPageState state) {
    return Column(
      children: [
        _buildCoodinateCheckboxListTile(state),
        _buildLengthCheckboxListTile(state),
        _buildAngleCheckboxListTile(state)
      ],
    );
  }

  CheckboxListTile _buildAngleCheckboxListTile(ConfigPageState state) {
    return CheckboxListTile(
        value: state.showAngles,
        title: Text('Winkel anzeigen'),
        secondary: Icon(Icons.text_rotation_angledown),
        onChanged: (bool? value) {
          context
              .read<ConfigPageBloc>()
              .add(ConfigAnglesShown(showAngles: value!));
        });
  }

  CheckboxListTile _buildLengthCheckboxListTile(ConfigPageState state) {
    return CheckboxListTile(
        value: state.showEdgeLengths,
        title: Text('Längen anzeigen'),
        secondary: Icon(Icons.mms),
        onChanged: (bool? value) {
          context
              .read<ConfigPageBloc>()
              .add(ConfigEdgeLengthsShown(showEdgeLengths: value!));
        });
  }

  CheckboxListTile _buildCoodinateCheckboxListTile(ConfigPageState state) {
    return CheckboxListTile(
        value: state.showCoordinates,
        title: Text('Koordinaten anzeigen'),
        secondary: Icon(Icons.control_point),
        onChanged: (bool? value) {
          context
              .read<ConfigPageBloc>()
              .add(ConfigCoordinatesShown(showCoordinates: value!));
        });
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
  void _createTool(ConfigPageState state) {
    ToolPageBloc(context.read<ToolRepository>()).add(ToolPageCreated());

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        // No selected shape because new Shapes created.
        return AddToolBottomSheet(selectedShape: null);
      },
    );
  }

  TwoColumnLandscapeLayout buildLandscapeLayout(ConfigPageState state) {
    return TwoColumnLandscapeLayout(
      leftColumn: Column(
        children: [
          for (var widget in _buildMenuHeader()) widget,
          Divider(),
          Flexible(child: _buildRadiusTextField(context)),
          SizedBox(height: 10),
          Flexible(child: _buildSTextField(context)),
          Divider(),
          buildCheckboxes2(state),
          Divider(),
          SizedBox(
            width: double.infinity,
            child: _buildToolElevatedButton(state),
          ),
        ],
      ),
      rightColumn: Column(
        children: [
          ConstructingPageSegmentWidget(),
        ],
      ),
    );
  }

  List<Widget> _buildMenuHeader() {
    return [
      Text('Konfiguration', style: Theme.of(context).textTheme.titleLarge),
      SizedBox(
        height: 10,
      ),
      Text('Kante selektieren um Länge und Winkel anzupassen.',
          style: Theme.of(context).textTheme.subtitle1),
    ];
  }
}

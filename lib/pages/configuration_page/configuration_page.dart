import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/pages/configuration_page/add_shape_bottom_sheet.dart';

import '../../bloc /configuration_page/configuration_page_bloc.dart';
import '../../model/Line2.dart';
import '../../model/simulation/shape.dart';
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
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Konfiguration')],
          ),
        ),
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
            ],
          ),
        ),
      );
    });
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
              onPressed: () => _createShape(state.lines),
              child: Text('+ Werkzeug'))
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
        Text('Winkel')
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

  /// Creates a new [Shape] using a [ModalBottomSheet]
  void _createShape(List<Line2> lines) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // No selected shape because new Shapes created.
        return AddShapeBottomSheet(selectedShape: null);
      },
    );
  }

  /// Will be removed later
  List<Shape> createDebuggingShapes() {
    List<Shape> shapes = [];

    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width - 13;
    double height = 295;

    Offset bottom1 = new Offset(width, height);
    Offset bottom2 = new Offset(width / 2, height);
    Offset bottom3 = new Offset(width / 2, 270);
    Offset bottom4 = new Offset(width, 270);

    // create 4 [Line2] consisting of the 4 points above
    Line2 line1 = Line2(start: bottom1, end: bottom2, isSelected: false);
    Line2 line2 = Line2(start: bottom2, end: bottom3, isSelected: false);
    Line2 line3 = Line2(start: bottom3, end: bottom4, isSelected: false);
    Line2 line4 = Line2(start: bottom4, end: bottom1, isSelected: false);

    // create [Shape] consisting of the 4 [Line2] above.
    Shape lowerBeam = Shape(
      name: 'Unterwange',
      type: ShapeType.lowerBeam,
      lines: [line1, line2, line3, line4],
    );

    Offset top1 = new Offset(width, 260);
    Offset top2 = new Offset(width / 2, 260);
    Offset top3 = new Offset(220, 230);
    Offset top4 = new Offset(width, 230);

    // create 4 [Line2] consisting of the 4 points above
    Line2 line5 = Line2(start: top1, end: top2, isSelected: false);
    Line2 line6 = Line2(start: top2, end: top3, isSelected: false);
    Line2 line7 = Line2(start: top3, end: top4, isSelected: false);
    Line2 line8 = Line2(start: top4, end: top1, isSelected: false);

    Shape upperBeam = new Shape(
        name: "Oberwange",
        lines: [line5, line6, line7, line8],
        type: ShapeType.lowerBeam);

    Offset bending1 = new Offset(0, 260);
    Offset bending2 = new Offset(170, 260);
    Offset beinding3 = new Offset(170, 230);
    Offset bending4 = new Offset(0, 230);

    // Create 4 [Line2] consisting of the 4 points above
    Line2 bendingLine1 =
        Line2(start: bending1, end: bending2, isSelected: false);
    Line2 bendingLine2 =
        Line2(start: bending2, end: beinding3, isSelected: false);
    Line2 bendingLine3 =
        Line2(start: beinding3, end: bending4, isSelected: false);
    Line2 bendingLine4 =
        Line2(start: bending4, end: bending1, isSelected: false);

    Shape bendingBeam = new Shape(
        name: "Biegewange",
        lines: [bendingLine1, bendingLine2, bendingLine3, bendingLine4],
        type: ShapeType.bendingBeam);

    shapes.addAll([lowerBeam, upperBeam, bendingBeam]);

    context.read<ConfigPageBloc>().add(ConfigShapeAdded(shape: lowerBeam));
    context.read<ConfigPageBloc>().add(ConfigShapeAdded(shape: upperBeam));
    context.read<ConfigPageBloc>().add(ConfigShapeAdded(shape: bendingBeam));

    return shapes;
  }
}

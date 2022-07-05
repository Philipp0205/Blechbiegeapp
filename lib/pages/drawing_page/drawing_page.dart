import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';
import 'package:open_bsp/bloc%20/drawing_page/segment_widget/drawing_widget_event.dart';
import 'package:open_bsp/bloc%20/drawing_page/segment_widget/drawing_widget_state.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';

import '../../bloc /configuration_page/configuration_page_bloc.dart';
import '../../bloc /drawing_page/segment_widget/drawing_widget_bloc.dart';
import '../../model/Line2.dart';
import 'drawing_widget.dart';

/// On this page the user can draw a single line representing the the profile
/// of a metal sheet.
///
/// The length and angle of the lines can be changed in a bottom sheet.
class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  /// TextField controllers
  final _angleController = TextEditingController();
  final _lengthController = TextEditingController();
  final _calcService = new GeometricCalculationsService();

  @override
  void initState() {
    super.initState();

    List<Line> selectedLines = context
        .read<DrawingWidgetBloc>()
        .state
        .lines
        .where((element) => element.isSelected)
        .toList();

    if (selectedLines.isNotEmpty) {
      _setAngle(selectedLines);
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _angleController.dispose();
    _lengthController.dispose();
  }

  /// Sets the initial angle in the angle text field.
  ///
  /// When there are multiple [Line]s selected it show only the angle of
  /// the first Line.
  void _setAngle(List<Line> lines) {
    if (lines.length == 1) {
      _angleController.text = _calcService
          .getAngle(lines.first.start, lines.first.end)
          .toStringAsFixed(1);
    } else {
      print(
          'angle controller inner angle ${_calcService.getInnerAngle(lines.first, lines.last)}');
      _angleController.text = _calcService
          .getInnerAngle(lines.first, lines.last)
          .toStringAsFixed(1);
    }
  }

  void _setLength(Line line) {
    double distance = (line.start - line.end).distance;

    _lengthController.text = distance.toStringAsFixed(1);
  }

  /// Building a widget containing a [DrawingWidget], one row where the eiditing
  /// Mode can be changed and one row where the angle and the length of the
  /// line can be changed.
  @override
  Widget build(BuildContext context) {
    /// Triggers when a new line is selected and there the [TextField]s get new
    /// values.
    return BlocListener<DrawingWidgetBloc, DrawingWidgetState>(
      listenWhen: (prev, current) =>
          prev.selectedLines != current.selectedLines &&
          current.selectedLines.isNotEmpty,
      listener: (context, state) {
        _setAngle(state.selectedLines);
        _setLength(state.selectedLines.first);
      },

      /// Rebuild the Widget if [DrawingPageState] changes.
      child: BlocBuilder<DrawingPageBloc, DrawingPageState>(
          builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Color(0xff009374),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Biegeapp'),
                Container(width: 100),
                IconButton(
                    onPressed: () {
                      _undo();
                    },
                    icon: Icon(Icons.arrow_circle_left)),
                IconButton(
                    onPressed: () {
                      _redo();
                    },
                    icon: Icon(Icons.arrow_circle_right)),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  /// DrawingWidget
                  buildDrawingWidget(),
                  Divider(color: Colors.green),

                  /// SelectionMode
                  Text(
                    'Modi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  buildConfigRow(state),
                  Divider(),

                  /// Line configuration
                  Text('Selektiere Linie',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  buildLineConfigRow(),
                ],
              ),
            ),
          ),
          floatingActionButton: Stack(
            children: [
              /// Right Button
              Positioned(
                bottom: 20,
                right: 10,
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_right),
                  onPressed: () => _goToNextPage(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Container buildDrawingWidget() {
    return Container(
      height: 300,
      width: 500,
      child: Stack(children: [
        DrawingWidget(),
      ]),
    );
  }

  Row buildConfigRow(DrawingPageState state) {
    return Row(
      children: [
        Checkbox(
            value: state.selectionMode,
            onChanged: (bool? value) {
              _toggleSelectionMode(value!);
            }),
        Text('Linien selektieren'),
        Container(
          width: 10,
        ),
        Container(
          width: 130,
        ),
        ElevatedButton(
            onPressed: () => _clearCanvas(), child: Icon(Icons.delete))
      ],
    );
  }

  Padding buildLineConfigRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 30,
            child: TextField(
                onChanged: (text) {
                  double? value = double.tryParse(text);
                  if (value != null) {
                    _changeAngle(value);
                  }
                },
                controller: _angleController,
                keyboardType: TextInputType.number),
          ),
          Container(
            width: 10,
          ),
          Text('Winkel'),
          Container(
            width: 10,
          ),
          Container(
            width: 50,
            height: 30,
            child: TextField(
                onChanged: (text) {
                  double? value = double.tryParse(text);
                  if (value != null) {
                    context.read<DrawingWidgetBloc>().add(
                        LineDrawingLengthChanged(
                            length: double.parse(_lengthController.text)));
                  }
                },
                controller: _lengthController,
                keyboardType: TextInputType.number),
          ),
          Container(
            width: 10,
          ),
          Text('Länge'),
        ],
      ),
    );
  }

  /// Deletes all drawn lines.
  Future<void> _clearCanvas() async {
    BlocProvider.of<DrawingWidgetBloc>(context).add((LinesDeleted()));
  }

  /// Toggles the selection mode in which the user can select one ore multiple 
  /// [Line]s.
  void _toggleSelectionMode(bool value) {
    context
        .read<DrawingPageBloc>()
        .add(DrawingPageSelectionModeChanged(selectionMode: value));
  }

  /// Navigates to the next Page and passes the selected lines to the next Page.
  void _goToNextPage() {
    List<Line> lines = context.read<DrawingWidgetBloc>().state.lines;
    BlocProvider.of<ConfigPageBloc>(context)
        .add(ConfigPageCreated(lines: lines));

    Navigator.of(context).pushNamed('/config');
  }

  /// Undo the last action.
  void _undo() {
    context.read<DrawingWidgetBloc>().add(LineDrawingUndo());
  }

  /// Redo the last action.
  void _redo() {
    context.read<DrawingWidgetBloc>().add(LineDrawingRedo());
  }

  /// Changes the angle of the selected [Line]s.
  /// Note that different events are triggered depending on the number of 
  /// selected [Line]s.
  void _changeAngle(double value) {
    List<Line> selectedLines =
        context.read<DrawingWidgetBloc>().state.selectedLines;

    if (selectedLines.length == 1) {
      context.read<DrawingWidgetBloc>().add(LineDrawingAngleChanged(
          angle: value, length: double.parse(_lengthController.text)));
    } else {
      context.read<DrawingWidgetBloc>().add(LineDrawingInnerAngleChanged(
          angle: value, length: double.parse(_lengthController.text)));
    }
  }
}

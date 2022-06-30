import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';
import 'package:open_bsp/bloc%20/drawing_page/segment_widget/drawing_widget_event.dart';
import 'package:open_bsp/bloc%20/drawing_page/segment_widget/drawing_widget_state.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';

import '../../bloc /configuration_page/configuration_page_bloc.dart';
import '../../bloc /drawing_page/segment_widget/drawing_widget_bloc.dart';
import '../../model/Line2.dart';
import '../../model/appmodes.dart';
import '../../model/segment_widget/segment.dart';
import 'bottom_sheet.dart';
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
  void dispose() {
    super.dispose();
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _angleController.dispose();
    _lengthController.dispose();
  }

  @override
  void initState() {
    super.initState();

    List<Line2> selectedLines = context
        .read<DrawingWidgetBloc>()
        .state
        .lines
        .where((element) => element.isSelected)
        .toList();

    if (selectedLines.isNotEmpty) {
      _setAngle(selectedLines.first);
    }
  }

  /// Sets the initial angle in the angle text field.
  ///
  /// When there are multiple [Line2]s selected it show only the angle of
  /// the first Line.
  void _setAngle(Line2 line) {
    _angleController.text =
        _calcService.getAngle(line.start, line.end).toStringAsFixed(1);
  }

  void _setLength(Line2 line) {
    double distance = (line.start - line.end).distance;

    _lengthController.text = distance.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DrawingWidgetBloc, DrawingWidgetState>(
      listenWhen: (prev, current) {
        return _calcService.getSelectedLines(prev.lines).length !=
            _calcService.getSelectedLines(current.lines).length;
      },
      listener: (context, state) {
        print('listener');
        List<Line2> selectedLines = _calcService
            .getSelectedLines(context.read<DrawingWidgetBloc>().state.lines);
        _setAngle(selectedLines.first);
        _setLength(selectedLines.first);
      },
      child: BlocBuilder<DrawingPageBloc, DrawingPageState>(
          builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Color(0xff009374),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Biegeapp'), Text(state.mode.name)],
            ),
          ),
          backgroundColor: Colors.white,
          body: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    height: 300,
                    width: 500,
                    child: Stack(children: [
                      DrawingWidget(),
                    ]),
                  ),
                  Divider(color: Colors.green),
                  Text(
                    'Modi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  buildConfigRow(state),
                  Divider(),
                  Text('Selektiere Linie',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  buildLineConfigRow(),
                ],
              ),
            ),
          ),
          floatingActionButton: Stack(
            children: [
              /// Left Button
              Positioned(
                left: 40,
                bottom: 20,
                child: SpeedDial(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  icon: Icons.add,
                  activeIcon: Icons.close,
                  children: [
                    SpeedDialChild(
                        child: Icon(Icons.delete), onTap: _clearCanvas),
                    // SpeedDialChild(
                    //     child: Icon(Icons.select_all),
                    //     onTap: _toggleSelectionMode()),
                    SpeedDialChild(
                        child: Icon(Icons.circle), onTap: _toggleDefaultMode),
                    SpeedDialChild(
                        child: Icon(Icons.circle_notifications),
                        onTap: _bottomSheet),
                  ],
                ),
              ),

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
                    context.read<DrawingWidgetBloc>().add(
                        LineDrawingAngleChanged(
                            angle: value,
                            length: double.parse(_angleController.text)));
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

  Future<void> _clearCanvas() async {
    BlocProvider.of<DrawingWidgetBloc>(context).add((SegmentDeleted()));
  }

  void _toggleSelectionMode(bool value) {
    context
        .read<DrawingPageBloc>()
        .add(DrawingPageSelectionModeChanged(selectionMode: value));
  }

  void _toggleDefaultMode() {
    context
        .read<DrawingPageBloc>()
        .add(DrawingPageModeChanged(mode: Mode.defaultMode));
  }

  void _bottomSheet() {
    showModalBottomSheet(
      enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return AppBottomSheet();
      },
    );
  }

  void _goToNextPage() {
    print('gotonextpage');
    List<Line2> lines = context.read<DrawingWidgetBloc>().state.lines;
    BlocProvider.of<ConfigPageBloc>(context).add(ConfigPageCreated(
        lines: lines));

    Navigator.of(context).pushNamed('/config');
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/drawing/drawing.dart';
import 'package:open_bsp/drawing/drawing_widget/bloc/drawing_widget_bloc.dart';
import 'package:open_bsp/drawing/drawing_widget/bloc/drawing_widget_event.dart';
import 'package:open_bsp/ui/two_coloumn_portrait_layout.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';
import 'package:open_bsp/ui/ui.dart';

import '../../../configuration/bloc/configuration_page_bloc.dart';
import '../../../bloc /shapes_page/tool_page_bloc.dart';
import '../../../model/line.dart';
import '../../../pages/widgets/app_title.dart';

/// On this page the user can draw a single line representing the the profile
/// of a metal sheet.
///
/// The length and angle of the lines can be changed in the left column.
class DrawingPage extends StatelessWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DrawingPageBloc(),
      child: DrawingView(),
    );
  }
}

/// The view of the drawing page.
class DrawingView extends StatelessWidget {
  final _angleController = TextEditingController();
  final _lengthController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text('Blechprofil zeichnen'),
              Container(width: 10),
              IconButton(
                  onPressed: () {
                    context.read<DrawingWidgetBloc>().add(LineDrawingUndo());
                  },
                  icon: Icon(Icons.arrow_circle_left)),
              SizedBox(width: 10),
              IconButton(
                  onPressed: () {
                    context.read<DrawingWidgetBloc>().add(LineDrawingRedo());
                  },
                  icon: Icon(Icons.arrow_circle_right))
            ]),
            AppTitle(),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: OrientationBuilder(builder: (context, orientation) {
        return orientation == Orientation.portrait
            ? buildPortraitLayout(context)
            : buildLandscapeLayout(context);
      }),
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
              onPressed: () => _goToNextPage(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the vertical layout of the page.
  /// The [DrawingWidget] is followed by two rows containing the options for
  /// configuring the line.
  ///
  /// The first row contains the selecting and deleting the line and the second row contains the
  /// angle and the length of the line.
  // TwoColumnPortraitLayout buildPortraitLayout(DrawingPageState state) {
  TwoColumnPortraitLayout buildPortraitLayout(BuildContext context) {
    return TwoColumnPortraitLayout(
      upperRow: Row(
        children: [Expanded(child: DrawingWidget())],
      ),
      lowerColumn: Column(
        children: [
          for (var widget in _buildMenuHeader(context)) widget,
          Divider(
            height: 20,
          ),
          Row(
            children: [
              Flexible(child: _buildAngleTextField(context)),
              SizedBox(width: 10),
              Flexible(child: _buildLengthTextField(context)),
              SizedBox(width: 10),
              Flexible(child: _buildSelectLineCheckboxListTile(context)),
              SizedBox(width: 10),
              Flexible(child: _buildDeleteElevatedButton(context)),
            ],
          ),
          Divider(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildMenuHeader(BuildContext context) {
    return [
      Text('Konfiguration', style: Theme.of(context).textTheme.titleLarge),
      SizedBox(
        height: 10,
      ),
      Text('Kante selektieren um Länge und Winkel anzupassen.',
          style: Theme.of(context).textTheme.titleSmall)
    ];
  }

  Widget buildDrawingWidget() {
    return Stack(children: [
      DrawingWidget(),
    ]);
  }

  CheckboxListTile _buildSelectLineCheckboxListTile(BuildContext context) {
    // CheckboxListTile _buildSelectLineCheckboxListTile(DrawingPageState state) {
    return CheckboxListTile(
        title: Text('Linie selektieren'),
        // value: state.selectionMode,
        value: context
            .select((DrawingWidgetBloc bloc) => bloc.state.selectionMode),
        onChanged: (bool? value) {
          _toggleSelectionMode(context, value!);
        });
  }

  Row buildLineConfigRow(BuildContext context) {
    return Row(
      children: [
        TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Winkel',
            ),
            onChanged: (text) {
              double? value = double.tryParse(text);
              if (value != null) {
                _changeAngle(context, value);
              }
            },
            controller: _angleController,
            keyboardType: TextInputType.number),
        Text('Winkel'),
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
        Text('Länge'),
      ],
    );
  }

  /// Builds the horizontal layout of the page.
  /// The settings are on the left while the [DrawingWidget] is on the right.
  TwoColumnLandscapeLayout buildLandscapeLayout(BuildContext context) {
    return TwoColumnLandscapeLayout(
        leftColumn: Column(
          children: [
            for (var widget in _buildMenuHeader(context)) widget,
            Divider(),
            _buildAngleTextField(context),
            SizedBox(height: 10),
            _buildLengthTextField(context),
            Divider(),
            Flexible(child: _buildSelectLineCheckboxListTile(context)),
            _buildDeleteElevatedButton(context),
          ],
        ),
        rightColumn: Column(
          children: [DrawingWidget()],
        ));
  }

  /// Build the text field for changing the angle of the selected line.
  TextField _buildAngleTextField(BuildContext context) {
    _angleController.text = context
        .select((DrawingWidgetBloc bloc) => bloc.state.currentAngle)
        .toStringAsFixed(1);

    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Winkel (°)',
      ),
      onChanged: (text) {
        double? value = double.tryParse(text);
        if (value != null) {
          _changeAngle(context, value);
        }
      },
      controller: _angleController,
      keyboardType: TextInputType.number,
    );
  }

  TextField _buildLengthTextField(BuildContext context) {
    _lengthController.text = context
        .select((DrawingWidgetBloc bloc) => bloc.state.currentLength)
        .toStringAsFixed(1);

    return TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Länge (mm)',
        ),
        onChanged: (text) {
          double? value = double.tryParse(text);
          if (value != null) {
            context.read<DrawingWidgetBloc>().add(LineDrawingLengthChanged(
                length: double.parse(_lengthController.text)));
          }
        },
        controller: _lengthController,
        keyboardType: TextInputType.number);
  }

  /// Deletes all drawn lines.
  Future<void> _clearCanvas(BuildContext context) async {
    BlocProvider.of<DrawingWidgetBloc>(context).add((LinesDeleted()));
  }

  /// Navigates to the next Page and passes the selected lines to the next Page.
  void _goToNextPage(BuildContext context) {
    List<Line> lines = context.read<DrawingWidgetBloc>().state.lines;

    /// Load tools from the database.
    context.read<ToolPageBloc>()
      ..add(ToolDataBackedUp())
      ..add(ToolPageCreated());

    BlocProvider.of<ConfigPageBloc>(context)
        .add(ConfigPageCreated(lines: lines, tools: []));

    Navigator.of(context).pushNamed('/config');
  }

  /// Toggles the selection mode in which the user can select one ore multiple
  /// [Line]s.
  void _toggleSelectionMode(BuildContext context, bool value) {
    context
        .read<DrawingPageBloc>()
        .add(DrawingPageSelectionModeChanged(selectionMode: value));
  }

  ElevatedButton _buildDeleteElevatedButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () => _clearCanvas(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete),
            SizedBox(
              width: 10,
            ),
            Text('Profil löschen')
          ],
        ));
  }

  /// Changes the angle of the selected [Line]s.
  /// Note that different events are triggered depending on the number of
  /// selected [Line]s.
  void _changeAngle(BuildContext context, double value) {
    context.read<DrawingWidgetBloc>().add(LineDrawingAngleChanged(
        angle: value, length: double.parse(_lengthController.text)));
  }
}

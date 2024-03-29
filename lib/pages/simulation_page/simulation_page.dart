import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/pages/simulation_page/simulation_page_sketcher.dart';
import 'package:open_bsp/pages/widgets/app_title.dart';

import '../../bloc/shapes_page/tool_page_bloc.dart';
import '../../model/simulation/tool.dart';
import '../../ui/ui.dart';

class SimulationPage extends StatefulWidget {
  const SimulationPage({Key? key}) : super(key: key);

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _timeController.text = '1';
  }

  @override
  Widget build(BuildContext context) {
    // Listens for changes in the tool selection.
    return MultiBlocListener(
      listeners: [
        BlocListener<ToolPageBloc, ToolPageState>(
            listenWhen: (prev, current) => prev.tools != current.tools,
            listener: (context, state) {
              // _setSelectedBeams(context, state.tools);
              _setSelectedTools(context, state.tools);
            }),
        BlocListener<SimulationPageBloc, SimulationPageState>(
            listenWhen: (prev, current) =>
                prev.selectedPlates != current.selectedPlates,
            listener: (context, state) {}),
        BlocListener<SimulationPageBloc, SimulationPageState>(
            listenWhen: (prev, current) =>
                prev.isSimulationRunning != current.isSimulationRunning,
            listener: (context, state) {
              _toggleDialog(state.isSimulationRunning);
            }),

        /// Bloc Listener to show dialog
        BlocListener<SimulationPageBloc, SimulationPageState>(
            listenWhen: (prev, current) =>
                prev.simulationError != current.simulationError,
            listener: (context, state) {
              if (state.simulationError == true) {
                _showErrorDialog(context, "Fehler",
                    "Sie müssen eine komplette Maschine und die Werkzeuge auswählen.");
              }
            }),
      ],
      child: BlocBuilder<SimulationPageBloc, SimulationPageState>(
          buildWhen: (prev, current) =>
              prev.collisionOffsets != current.collisionOffsets,
          builder: (context, state) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: buildAppBar(),
              backgroundColor: Colors.white,
              body: buildBody(),
            );
          }),
    );
  }

  /// Builds the body of the app.
  OrientationBuilder buildBody() {
    return OrientationBuilder(builder: (context, orientation) {
      return orientation == Orientation.portrait
          ? _buildPortraitLayout()
          : _buildLandscapeLayout();
    });
  }

  /// Build a row containing the buttons for adding tools and bending tools.
  Row buildButtonRow() {
    return Row(
      children: [
        buildMachineButton(),
        _buildNextLineButton(),
        _buildRotateRightButton(),
        _buildMirrorButton(),
        if (context.read<SimulationPageBloc>().state.isSimulationRunning ==
            true) ...[
          // _closeLoadingDialog(context),
          IconButton(
              onPressed: () => {
                    context.read<SimulationPageBloc>().add(SimulationStopped()),
                  },
              icon: new Icon(Icons.pause)),
        ] else ...[
          IconButton(
              onPressed: () => {
                    context
                        .read<SimulationPageBloc>()
                        .add(SimulationStarted(timeInterval: 2)),

                    // _showLoadingDialog(context)
                  },
              icon: new Icon(Icons.play_arrow))
        ],
        IconButton(
            onPressed: () => _bendPlate(), icon: new Icon(Icons.arrow_back)),
        IconButton(
            onPressed: () => _unBendPlate(),
            icon: new Icon(Icons.arrow_forward)),
      ],
    );
  }

  ElevatedButton _buildMirrorButton() {
    return ElevatedButton(
        onPressed: () => _mirrorCurrentPlate(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.flip), SizedBox(width: 10), Text('Mirror')],
        ));
  }

  ElevatedButton _buildRotateRightButton() {
    return ElevatedButton(
        onPressed: () => _rotateRight(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rotate_right),
            SizedBox(width: 10),
            Text('Rotate')
          ],
        ));
  }

  ElevatedButton _buildNextLineButton() {
    return ElevatedButton(
        onPressed: () => _nextLineOfPlate(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward),
            SizedBox(width: 10),
            Text('Next Line')
          ],
        ));
    // return IconButton(
    //     onPressed: () => _nextLineOfPlate(),
    //     icon: new Icon(Icons.navigate_next));
  }

  ElevatedButton buildMachineButton() {
    return ElevatedButton(
        onPressed: () => _openSelectToolPage(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add),
            SizedBox(width: 10),
            Text('Maschine'),
          ],
        ));
  }

  ElevatedButton _buildUnbendButton() {
    return ElevatedButton(
        onPressed: () => _unBendPlate(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward),
            SizedBox(width: 10),
            Text('Unbend'),
          ],
        ));
  }

  ElevatedButton _buildBendButton() {
    return ElevatedButton(
        onPressed: () => _bendPlate(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back),
            SizedBox(width: 10),
            Text('Bend'),
          ],
        ));
  }

  ElevatedButton _buildStartStopButton() {
    if (context.read<SimulationPageBloc>().state.isSimulationRunning == true) {
      return ElevatedButton(
          onPressed: () => {
                context.read<SimulationPageBloc>().add(SimulationStopped()),
              },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.pause), SizedBox(width: 10), Text('Pause')],
          ));
    } else {
      return ElevatedButton(
          onPressed: () => {
                context
                    .read<SimulationPageBloc>()
                    .add(SimulationStarted(timeInterval: 2)),
              },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow),
              SizedBox(width: 10),
              Text('Simulation starten')
            ],
          ));
    }
  }

  Row _buildSimulationResultsRow() {
    SimulationPageState state = context.read<SimulationPageBloc>().state;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Text('Ergebnis:', style: Theme.of(context).textTheme.titleLarge),
      if (state.simulationResults.isNotEmpty) ...[
        if (state.simulationResults.last.isBendable) ...[
          Text('Blech ist biegbar'),
          Icon(Icons.thumb_up, color: Colors.green),
        ] else ...[
          // Spacer(flex: 5),
          Text('Blech ist NICHT biegbar'),
          Icon(Icons.thumb_down, color: Colors.red),
        ],
      ]
    ]);
  }

  /// Build a row containing the controls for the simulation.
  Widget buildSimulationControlsRow() {
    return BlocBuilder<SimulationPageBloc, SimulationPageState>(
      buildWhen: (prev, current) =>
          prev.isSimulationRunning != current.isSimulationRunning,
      builder: (context, state) {
        return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('Ergebnis:'),
          if (state.simulationResults.isNotEmpty) ...[
            if (state.simulationResults.last.isBendable) ...[
              Text('Blech ist biegbar'),
              Icon(Icons.thumb_up, color: Colors.green),
            ] else ...[
              // Spacer(flex: 5),
              Text('Blech ist NICHT biegbar'),
              Icon(Icons.thumb_down, color: Colors.red),
            ],
          ]
        ]);
      },
    );
  }

  /// Build the appbar of the the page.
  AppBar buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Simulation'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _setCollisionLabel(
                  context.read<SimulationPageBloc>().state.inCollision),
              VerticalDivider(),
              AppTitle(),
            ],
          ),
        ],
      ),
    );
  }

  /// Open the [ToolPage] to select beams.
  void _openSelectToolPage() {
    Navigator.of(context).pushNamed("/shapes");
  }

  /// Set the selected tools for the sketcher.
  /// This is done by listening to the [ToolPageBloc] and setting the selected
  /// tools.
  /// The [ToolPageBloc] is listening to the [SimulationPageBloc] and setting
  /// the selected tools.
  /// Therefore, this method is called when the [ToolPageBloc] changes.
  void _setSelectedTools(BuildContext context, List<Tool> tools) {
    List<Tool> selectedTools = tools.where((tool) => tool.isSelected).toList();

    context
        .read<SimulationPageBloc>()
        .add(SimulationToolsChanged(tools: selectedTools));
  }

  void _nextLineOfPlate() {
    context
        .read<SimulationPageBloc>()
        .add(SimulationSelectedPlateLineChanged());
  }

  void _rotateRight() {
    SimulationPageState state = context.read<SimulationPageBloc>().state;
    context.read<SimulationPageBloc>().add(
        SimulationToolRotate(tool: state.selectedPlates.first, degrees: 90));

    context.read<SimulationPageBloc>().add(SimulationBendingBeamPlaced());
  }

  void _mirrorCurrentPlate() {
    SimulationPageState state = context.read<SimulationPageBloc>().state;

    context
        .read<SimulationPageBloc>()
        .add(SimulationToolMirrored(tool: state.selectedPlates.first));
    context.read<SimulationPageBloc>().add(SimulationBendingBeamPlaced());
  }

  void _unBendPlate() {
    SimulationPageState state = context.read<SimulationPageBloc>().state;
    context
        .read<SimulationPageBloc>()
        .add(SimulationPlateUnbended(plate: state.selectedPlates.first));

    context.read<SimulationPageBloc>().add(SimulationBendingBeamPlaced());
  }

  void _bendPlate() {
    SimulationPageState state = context.read<SimulationPageBloc>().state;
    context
        .read<SimulationPageBloc>()
        .add(SimulationPlateBended(plate: state.selectedPlates.first));

    context.read<SimulationPageBloc>().add(SimulationBendingBeamPlaced());
  }

  Text _setCollisionLabel(bool isColliding) {
    if (isColliding) {
      return Text('Kollision', style: TextStyle(color: Colors.red));
    } else {
      return Text('Keine Kollision', style: TextStyle(color: Colors.green));
    }
  }

  void _showLoadingDialog(BuildContext context) async {
    // show the loading dialog
    return showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // The loading indicator
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  // Some text
                  Text('Wird geladen...')
                ],
              ),
            ),
          );
        });
  }

  void _closeLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _toggleDialog(bool isSimulationRunning) {
    if (isSimulationRunning) {
      _showLoadingDialog(context);
    } else {
      _closeLoadingDialog(context);
    }
  }

  void _showErrorDialog(BuildContext context, String title, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(text),
          actions: <Widget>[
            new ElevatedButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _buildPortraitLayout() {}

  TwoColumnLandscapeLayout _buildLandscapeLayout() {
    return TwoColumnLandscapeLayout(
      leftColumn: Column(
        children: [
          for (var widget in _buildMenuHeader()) widget,
          buildMachineButton(),
          Divider(),
          for (var widget in _buildPositionPlateDescription()) widget,
          Row(
            children: [
              Flexible(child: _buildRotateRightButton()),
              SizedBox(width: 10),
              Flexible(child: _buildNextLineButton()),
            ],
          ),
          Flexible(child: _buildMirrorButton()),
          Divider(),
          for (var widget in _buildBendPlateDescription()) widget,
          Row(
            children: [
              Flexible(child: _buildBendButton()),
              SizedBox(width: 10),
              Flexible(child: _buildUnbendButton())
            ],
          ),
          Divider(),
          _buildStartStopButton(),
          SizedBox(height: 10),
          _buildSimulationResultsRow()
        ],
      ),
      rightColumn: Column(
        children: [
          SimulationPageSketcher(),
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

  List<Widget> _buildPositionPlateDescription() {
    return [
      Text('Blech positionieren',
          style: Theme.of(context).textTheme.titleLarge),
      SizedBox(
        height: 10,
      ),
      Text('Das Blech kann mit folgenden Optionen manuell positioniert werden.',
          style: Theme.of(context).textTheme.subtitle1),
    ];
  }

  List<Widget> _buildBendPlateDescription() {
    return [
      Text('Blech biegen', style: Theme.of(context).textTheme.titleLarge),
      SizedBox(
        height: 10,
      ),
      Text('Das Blech kann mit folgenden Optionen manuell gebogen werden.',
          style: Theme.of(context).textTheme.subtitle1),
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_sketcher.dart';

import '../../bloc /shapes_page/tool_page_bloc.dart';
import '../../bloc /ticker_widget/timer_widget_bloc.dart';
import '../../model/simulation/tool.dart';

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

  bool _requestNextCollision(
      bool isRunning, SimulationPageState prev, SimulationPageState current) {
    if (isRunning) {
      // return prev.inCollision != current.inCollision;
      return true;
    } else {
      return false;
    }
  }

  /// Builds the body of the app.
  Container buildBody() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            buildSketcher(),
            buildButtonRow(),
            Divider(),
            buildSimulationControlsRow()
          ],
        ),
      ),
    );
  }

  /// Build a row containing the buttons for adding tools and bending tools.
  Row buildButtonRow() {
    return Row(
      children: [
        ElevatedButton(
            onPressed: () => _openSelectToolPage(), child: Text('Maschine')),
        IconButton(
            onPressed: () => _nextLineOfPlate(),
            icon: new Icon(Icons.navigate_next)),
        IconButton(
            onPressed: () => _rotateRight(),
            icon: new Icon(Icons.rotate_right)),
        IconButton(
            onPressed: () => _mirrorCurrentPlate(),
            icon: new Icon(Icons.compare_arrows)),
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

  /// Builds the sketcher area of the page where the simulation takes place.
  Container buildSketcher() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
        ),
        child: BlocBuilder<SimulationPageBloc, SimulationPageState>(
            builder: (context, state) {
          return RepaintBoundary(
            child: CustomPaint(
              painter: SimulationSketcher(
                  beams: state.selectedBeams,
                  tracks: state.selectedTracks,
                  plates: state.selectedPlates,
                  rotateAngle: state.rotationAngle,
                  collisionOffsets: state.collisionOffsets,
                  debugOffsets: state.debugOffsets,
                  context: context),
            ),
          );
        }));
  }

  /// Build the appbar of the the page.
  AppBar buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Simulation'),
          _setCollisionLabel(
              context.read<SimulationPageBloc>().state.inCollision)
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

  void _startSimulation() {
    context.read<TimerWidgetBloc>().add(TimerStarted(duration: 60));
    context.read<SimulationPageBloc>().add(
        SimulationStarted(timeInterval: double.parse(_timeController.text)));
    _showLoadingDialog(context);
  }

  void _stopSimulation() {
    context.read<TimerWidgetBloc>().add(TimerStopped());
    _closeLoadingDialog(context);
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
                  Text('Loading...')
                ],
              ),
            ),
          );
        });
  }

  void _closeLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  SimpleDialog _showSimpleDialog(BuildContext context) {
    return SimpleDialog(
      title: const Text('Simulation'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            _startSimulation();
            Navigator.pop(context);
          },
          child: const Text('Start'),
        ),
        SimpleDialogOption(
          onPressed: () {
            _stopSimulation();
            Navigator.pop(context);
          },
          child: const Text('Stop'),
        ),
      ],
    );
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
}

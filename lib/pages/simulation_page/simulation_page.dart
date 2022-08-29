import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_sketcher.dart';
import 'package:open_bsp/pages/simulation_page/ticker_widget.dart';

import '../../bloc /shapes_page/tool_page_bloc.dart';
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
            listenWhen: (prev, current) => _requestNextCollision(current.isSimulationRunning, prev, current),
            listener: (context, state) {
              // context
              //     .read<SimulationPageBloc>()
              //     .add(SimulationNextCollisionRequested());
            }),
      ],
      child: BlocBuilder<SimulationPageBloc, SimulationPageState>(
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

  bool _requestNextCollision(bool isRunning, SimulationPageState prev, SimulationPageState current) {
    print('requestNextCollision');
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
            onPressed: () => _openSelectToolPage(),
            child: Text('Wangen & Schienen')),
        IconButton(
            onPressed: () => _nextLineOfPlate(),
            icon: new Icon(Icons.navigate_next)),
        IconButton(
            onPressed: () => _rotateRight(),
            icon: new Icon(Icons.rotate_right)),
        IconButton(
            onPressed: () => _mirrorCurrentPlate(),
            icon: new Icon(Icons.compare_arrows))
      ],
    );
  }

  /// Build a row containing the controls for the simulation.
  Row buildSimulationControlsRow() {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _timeController,
            onChanged: (value) {
              print('test');
            },
          ),
        ),
        Text('Zeit'),
        IconButton(
            onPressed: () =>
                context.read<SimulationPageBloc>().state.isSimulationRunning
                    ? _stopSimulation()
                    : _startSimulation(),
            icon: context.read<SimulationPageBloc>().state.isSimulationRunning
                ? new Icon(Icons.pause)
                : new Icon(Icons.play_arrow)),
        TimerWidget(),
      ],
    );
  }

  /// Builds the sketcher area of the page where the simulation takes place.
  Container buildSketcher() {
    return Container(
        height: 300,
        width: 500,
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
            // buildWhen: (prev, current) => prev.lines != current.lines,
            builder: (context, state) {
          return RepaintBoundary(
            child: CustomPaint(
              painter: SimulationSketcher(
                  beams: state.selectedBeams,
                  tracks: state.selectedTracks,
                  plates: state.selectedPlates,
                  rotateAngle: state.rotationAngle,
                  debugOffsets: state.collisionOffsets,
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
  }

  void _mirrorCurrentPlate() {
    SimulationPageState state = context.read<SimulationPageBloc>().state;
    context
        .read<SimulationPageBloc>()
        .add(SimulationToolMirrored(tool: state.selectedPlates.first));
  }

  Text _setCollisionLabel(bool isColliding) {
    if (isColliding) {
      return Text('Kollision', style: TextStyle(color: Colors.red));
    } else {
      return Text('Keine Kollision', style: TextStyle(color: Colors.green));
    }
  }

  void _startSimulation() {
    context.read<SimulationPageBloc>().add(
        // SimulationStarted(timeInterval: double.parse(_timeController.text)));
        SimulationStarted(timeInterval: 10));
  }

  void _stopSimulation() {
    context.read<SimulationPageBloc>().add(SimulationStopped());
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration =
    context.select((SimulationPageBloc bloc) => bloc.state.duration);
    final minutesStr =
    ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text(
      '$minutesStr:$secondsStr',
      style: Theme.of(context).textTheme.bodyText1,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_sketcher.dart';
import 'package:open_bsp/pages/simulation_page/timer_widget.dart';
import 'package:progress_state_button/progress_button.dart';

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
                prev.collisionOffsets != current.collisionOffsets,
            listener: (context, state) {}),
        // BlocListener<SimulationPageBloc, SimulationPageState>(
        //     listenWhen: (prev, current) => _requestNextCollision(
        //         current.isSimulationRunning, prev, current),
        //     listener: (context, state) {
        //       // context
        //       //     .read<SimulationPageBloc>()
        //       //     .add(SimulationNextCollisionRequested());
        //     }),
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
                  },
              icon: new Icon(Icons.play_arrow))
        ],
        IconButton(
            onPressed: () => _refoldPlate(), icon: new Icon(Icons.arrow_back)),
        IconButton(
            onPressed: () => _unFoldPlate(),
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
        return Row(
          children: [
            if (state.isSimulationRunning) ...[
              CircularProgressIndicator(),
            ] else ...[
              CircularProgressIndicator(color: Colors.grey, value: 1)
            ],
          ],
        );
      },
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
  }

  void _mirrorCurrentPlate() {
    SimulationPageState state = context.read<SimulationPageBloc>().state;
    context
        .read<SimulationPageBloc>()
        .add(SimulationToolMirrored(tool: state.selectedPlates.first));
  }

  void _unFoldPlate() {
    SimulationPageState state = context.read<SimulationPageBloc>().state;
    context
        .read<SimulationPageBloc>()
        .add(SimulationPlateUnfolded(plate: state.selectedPlates.first));
  }

  void _refoldPlate() {
    SimulationPageState state = context.read<SimulationPageBloc>().state;
    context
        .read<SimulationPageBloc>()
        .add(SimulationPlateRefolded(plate: state.selectedPlates.first));
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
    // SimulationStarted(timeInterval: 10));
  }

  void _stopSimulation() {
    context.read<TimerWidgetBloc>().add(TimerStopped());
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

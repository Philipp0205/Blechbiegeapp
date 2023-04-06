import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/simulation_page/simulation_page_bloc.dart';
import '../../bloc/simulation_page/simulation_sketcher.dart';


class SimulationPageSketcher extends StatefulWidget {
  const SimulationPageSketcher({Key? key}) : super(key: key);

  @override
  State<SimulationPageSketcher> createState() => _SimulationPageSketcherState();
}

class _SimulationPageSketcherState extends State<SimulationPageSketcher> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.4), width: 1),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5)),
        ),
        child: BlocBuilder<SimulationPageBloc, SimulationPageState>(
            builder: (context, state) {
          return CustomPaint(
            painter: SimulationSketcher(
                beams: state.selectedBeams,
                tracks: state.selectedTracks,
                plates: state.selectedPlates,
                rotateAngle: state.rotationAngle,
                collisionOffsets: state.collisionOffsets,
                debugOffsets: state.debugOffsets,
                context: context),
          );
        }));
  }
}

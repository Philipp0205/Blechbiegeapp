import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_sketcher.dart';
import 'package:open_bsp/pages/configuration_page/add_shape_bottom_sheet.dart';

import '../../model/simulation/shape.dart';

class SimulationPage extends StatefulWidget {
  const SimulationPage({Key? key}) : super(key: key);

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimulationPageBloc, SimulationPageState>(
        builder: (context, state) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Simulation')],
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                    height: 300,
                    width: 500,
                    decoration: BoxDecoration(border: Border.all(width: 2)),
                    child: BlocBuilder<SimulationPageBloc, SimulationPageState>(
                        builder: (context, state) {
                      return CustomPaint(
                        painter:
                            SimulationSketcher(shapes: createDebuggingShapes()),
                      );
                    })),
              )
            ],
          ),
        ),
      );
    });
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

    Shape lowerBeam = new Shape(
        name: "lower Beam",
        path: [bottom1, bottom2, bottom3, bottom4, bottom1],
        type: ShapeType.upperBeam);

    Offset top1 = new Offset(width, 260);
    Offset top2 = new Offset(width / 2, 260);
    Offset top3 = new Offset(220, 230);
    Offset top4 = new Offset(width, 230);

    Shape upperBeam = new Shape(
        name: "upperBeam",
        path: [top1, top2, top3, top4],
        type: ShapeType.lowerBeam);

    Offset back1 = new Offset(0, 260);
    Offset back2 = new Offset(170, 260);
    Offset back3 = new Offset(170, 230);
    Offset back4 = new Offset(0, 230);

    Shape backStop = new Shape(
        name: "back",
        path: [back1, back2, back3, back4, back1],
        type: ShapeType.backstop);

    shapes.addAll([lowerBeam, upperBeam, backStop]);

    return shapes;
  }
}

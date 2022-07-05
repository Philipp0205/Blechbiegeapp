import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_sketcher.dart';
import 'package:open_bsp/pages/configuration_page/add_shape_bottom_sheet.dart';

import '../../model/Line2.dart';
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

    return shapes;
  }


}

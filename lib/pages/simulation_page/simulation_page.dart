import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_sketcher.dart';
import 'package:open_bsp/pages/configuration_page/add_tool_bottom_sheet.dart';

import '../../model/line.dart';
import '../../model/simulation/tool.dart';
import '../../model/simulation/tool_type.dart';

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
  List<Tool> createDebuggingShapes() {
    List<Tool> shapes = [];

    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width - 13;
    double height = 295;

    Offset bottom1 = new Offset(width, height);
    Offset bottom2 = new Offset(width / 2, height);
    Offset bottom3 = new Offset(width / 2, 270);
    Offset bottom4 = new Offset(width, 270);

    // create 4 [Line2] consisting of the 4 points above
    Line line1 = Line(start: bottom1, end: bottom2, isSelected: false);
    Line line2 = Line(start: bottom2, end: bottom3, isSelected: false);
    Line line3 = Line(start: bottom3, end: bottom4, isSelected: false);
    Line line4 = Line(start: bottom4, end: bottom1, isSelected: false);

    // create [Shape] consisting of the 4 [Line2] above.
    Tool lowerBeam = Tool(
      name: 'Unterwange',
      type: ToolType.lowerBeam,
      lines: [line1, line2, line3, line4],
      isSelected: false
    );

    Offset top1 = new Offset(width, 260);
    Offset top2 = new Offset(width / 2, 260);
    Offset top3 = new Offset(220, 230);
    Offset top4 = new Offset(width, 230);

    // create 4 [Line2] consisting of the 4 points above
    Line line5 = Line(start: top1, end: top2, isSelected: false);
    Line line6 = Line(start: top2, end: top3, isSelected: false);
    Line line7 = Line(start: top3, end: top4, isSelected: false);
    Line line8 = Line(start: top4, end: top1, isSelected: false);

    Tool upperBeam = new Tool(
        name: "Oberwange",
        lines: [line5, line6, line7, line8],
        type: ToolType.lowerBeam,
      isSelected: false
    );

    Offset bending1 = new Offset(0, 260);
    Offset bending2 = new Offset(170, 260);
    Offset beinding3 = new Offset(170, 230);
    Offset bending4 = new Offset(0, 230);

    // Create 4 [Line2] consisting of the 4 points above
    Line bendingLine1 =
    Line(start: bending1, end: bending2, isSelected: false);
    Line bendingLine2 =
    Line(start: bending2, end: beinding3, isSelected: false);
    Line bendingLine3 =
    Line(start: beinding3, end: bending4, isSelected: false);
    Line bendingLine4 =
    Line(start: bending4, end: bending1, isSelected: false);

    Tool bendingBeam = new Tool(
        name: "Biegewange",
        lines: [bendingLine1, bendingLine2, bendingLine3, bendingLine4],
        type: ToolType.bendingBeam,
    isSelected: false);

    shapes.addAll([lowerBeam, upperBeam, bendingBeam]);

    return shapes;
  }


}

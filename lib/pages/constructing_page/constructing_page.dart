import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/pages/constructing_page/constructing_sketcher.dart';

import '../../bloc /constructing/constructing_page_bloc.dart';

class ConstructingPage extends StatefulWidget {
  const ConstructingPage({Key? key}) : super(key: key);

  @override
  _ConstructingPageState createState() => _ConstructingPageState();
}

class _ConstructingPageState extends State<ConstructingPage> {
  bool showCoordinates = true;
  bool showEdgeLengths = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConstructingPageBloc, ConstructingPageState>(
        builder: (context, state) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Biegeapp')],
          ),
        ),
        backgroundColor: Colors.yellow[50],
        body: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Test',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  height: 300,
                  width: 500,
                  // color: Colors.yellow[50],
                  decoration: BoxDecoration(
                      border: Border.all(
                    width: 2,
                  )),
                  child: CustomPaint(
                    painter: ConstructingSketcher(
                      lines2: state.segment,
                      coordinatesShown: state.showCoordinates,
                      edgeLengthsShown: state.showEdgeLengths,
                      anglesShown: state.showAngles,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                      value: state.showCoordinates,
                      onChanged: (bool? value) {
                        context.read<ConstructingPageBloc>().add(
                            ConstructingPageCoordinatesShown(
                                showCoordinates: value!));
                      }),
                  Text('Koordinaten'),
                  Checkbox(
                      value: state.showEdgeLengths,
                      onChanged: (bool? value) {
                        context.read<ConstructingPageBloc>().add(
                            ConstructingPageEdgeLengthsShown(
                                showEdgeLengths: value!));
                      }),
                  Text('Längen'),
                  Checkbox(
                      value: state.showAngles,
                      onChanged: (bool? value) {
                        context.read<ConstructingPageBloc>().add(
                            ConstructingPageAnglesShown(
                                showAngles: value!));
                      }),

                  Text('Winkel'),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}

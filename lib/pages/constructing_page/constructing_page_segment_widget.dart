import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/constructing/constructing_page_bloc.dart';

import 'constructing_sketcher.dart';

class ConstructingPageSegmentWidget extends StatefulWidget {
  const ConstructingPageSegmentWidget({Key? key}) : super(key: key);

  @override
  _ConstructingPageSegmentWidgetState createState() =>
      _ConstructingPageSegmentWidgetState();
}

class _ConstructingPageSegmentWidgetState
    extends State<ConstructingPageSegmentWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 500,
      decoration: BoxDecoration(
          border: Border.all(
        width: 2,
      )),
      child: BlocBuilder<ConstructingPageBloc, ConstructingPageState>(
          builder: (context, state) {
        return CustomPaint(
          painter: ConstructingSketcher(
              lines: state.segment,
              coordinatesShown: state.showCoordinates,
              edgeLengthsShown: state.showEdgeLengths,
              anglesShown: state.showAngles,
              s: state.s,
              r: state.r),
        );
      }),
    );
  }
}

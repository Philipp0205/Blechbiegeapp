import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/configuration_page/configuration_page_bloc.dart';

import 'configuration_sketcher.dart';

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
      child: BlocBuilder<ConfigurationPageBloc, ConstructingPageState>(
          builder: (context, state) {
        return CustomPaint(
          painter: ConfigurationSketcher(
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

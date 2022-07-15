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
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)),
      ),
      child: BlocBuilder<ConfigPageBloc, ConfigPageState>(
          builder: (context, state) {
        return GestureDetector(
          onPanDown: (details) => onPanDown(context, details, state),
          child: CustomPaint(
            painter: ConfigurationSketcher(
                segments: state.segment,
                coordinatesShown: state.showCoordinates,
                edgeLengthsShown: state.showEdgeLengths,
                anglesShown: state.showAngles,
                s: state.s,
                r: state.r,
                lines: state.lines),
          ),
        );
      }),
    );
  }

  /// Called when the suer tabs on the screen
  /// User can selectect a line of a tool and this line is marked as an
  /// adapter line.
  ///
  /// This means that other tools can be attached to this tool.
  void onPanDown(
      BuildContext context, DragDownDetails details, ConfigPageState state) {
    print('onpanDown');
    RenderBox box = context.findRenderObject() as RenderBox;
      Offset point = box.globalToLocal(details.globalPosition);
      Offset offset = new Offset(point.dx, point.dy);

      context.read<ConfigPageBloc>().add(ConfigMarkAdapterLine(offset: offset));
  }
}

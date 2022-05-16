import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/sketcher_controller.dart';
import '../../model/segment.dart';
import '../../services/service_locator.dart';
import '../../sketcher.dart';

class BuildAllPaths extends StatefulWidget {
  @override
  State<BuildAllPaths> createState() => _BuildAllPathsState();
}

class _BuildAllPathsState extends State<BuildAllPaths> {
  GlobalKey _globalKey = new GlobalKey();

  SketcherController controller = getIt<SketcherController>();

  @override
  Widget build(
    BuildContext context,
  ) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        padding: EdgeInsets.all(4.0),
        alignment: Alignment.topLeft,
        child: StreamBuilder<List<Segment>>(
          stream: controller.linesStreamController.stream,
          builder: (context, snapshot) {
            return ChangeNotifierProvider<SketcherController>(
              create: (context) => controller,
              child: CustomPaint(
                painter: Sketcher(
                  lines: controller.segments,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

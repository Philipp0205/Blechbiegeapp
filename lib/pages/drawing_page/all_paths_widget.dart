import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/services/segment_data_service.dart';
import 'package:provider/provider.dart';

import '../../model/segment_model.dart';
import '../../services/viewmodel_locator.dart';
import '../../viewmodel/all_paths_view_model.dart';
import 'sketcher.dart';

class AllPathsWidget extends StatefulWidget {
  @override
  State<AllPathsWidget> createState() => _AllPathsWidgetState();
}

class _AllPathsWidgetState extends State<AllPathsWidget> {
  @override
  Widget build(BuildContext context) {
    // return ChangeNotifierProvider<AllPathsViewModel>.value(
    //   value: AllPathsViewModel(),
    // child:
    return Consumer<AllPathsViewModel>(
      builder: (context, model, child) => RepaintBoundary(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.transparent,
          padding: EdgeInsets.all(4.0),
          alignment: Alignment.topLeft,
          child: StreamBuilder<List<Segment>>(
            stream: model.segmentsStreamController.stream,
            builder: (context, snapshot) {
              model.addListener(() {
                print('allpathsviewmodel triggered');
              });
              return CustomPaint(
                painter: Sketcher(
                  lines: model.segments,
                ),
              );
            },
          ),
        ),
        // ),
      ),
    );
  }
}

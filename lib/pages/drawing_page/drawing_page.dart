import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_bsp/bloc%20/all_paths/all_paths_bloc.dart';
import 'package:open_bsp/data/segments_repository.dart';
import 'package:open_bsp/pages/drawing_page/all_paths_widget2.dart';
import 'package:open_bsp/services/segment_data_service.dart';
import 'package:open_bsp/services/viewmodel_locator.dart';

import '../../bloc /current_path/current_path_bloc.dart';
import '../../bloc /modes/mode_cubit.dart';
import '../../model/appmodes.dart';
import '../../model/segment.dart';
import '../../viewmodel/all_paths_view_model.dart';
import '../../viewmodel/current_path_view_model.dart';
import '../../viewmodel/modes_controller_view_model.dart';
import 'current_path_widget2.dart';

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {

  // SketcherController viewmodel =  getIt<SketcherController>();
  AllPathsViewModel _allPathsVM =  getIt<AllPathsViewModel>();
  SegmentDataService _segmentDataService =  getIt<SegmentDataService>();
  ModesViewModel _modesVM =  getIt<ModesViewModel>();
  CurrentPathViewModel _currentPathVM =  getIt<CurrentPathViewModel>();

  @override
  Widget build(BuildContext context) {
    final SegmentsRepository segmentsRepository = new SegmentsRepository();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Biegeapp'),
            Text(AppModes().getModeName(_modesVM.selectedMode))
          ],
        ),
      ),
      backgroundColor: Colors.yellow[50],
      body: Container(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => CurrentPathBloc(segmentsRepository),
            ),
            BlocProvider(
              create: (_) => AllPathsBloc(),
            ),
            BlocProvider(
              create: (_) => ModeCubit(),
            ),
          ],
          child: Stack(children: [
            AllPathsWidget2(),
            CurrentPathWidget2(),
            // AllPathsWidget(),
            // CurrentPathWidget()
          ]),
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(child: Icon(Icons.delete), onTap: clear),
          SpeedDialChild(
              child: Icon(Icons.select_all), onTap: toggleSelectionMode),
          SpeedDialChild(child: Icon(Icons.circle), onTap: _modesVM.toggleDefaultMode),
        ],
      ),
    );
  }

  Future<void> clear() async {
    BlocProvider.of<CurrentPathBloc>(context).add(CurrentSegmentDeleted());
    BlocProvider.of<AllPathsBloc>(context).add(AllPathsDeleted());

  }

  void toggleSelectionMode() {
    setState(() {
      _modesVM.toggleSelectionMode();
    });
  }

  void extendSegment(Segment line, double length) {
    // deleteLine(line);
    Point pointA = new Point(line.path.first.dx, line.path.first.dy);
    Point pointB = new Point(line.path.last.dx, line.path.last.dy);

    double lengthAB = pointA.distanceTo(pointB);

    double x = pointB.x + (pointB.x - pointA.x) / lengthAB * length;
    double y = pointB.y + (pointB.y - pointA.y) / lengthAB * length;

    Offset pointC = new Offset(x, y);
    Segment newLine = new Segment(
        [line.path.first, pointC], _currentPathVM.selectedColor, _currentPathVM.selectedWidth);

    // _currentPathVM.currentlyDrawnSegment = newLine;
  }



}

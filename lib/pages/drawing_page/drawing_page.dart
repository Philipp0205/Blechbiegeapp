import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';
import 'package:open_bsp/pages/drawing_page/all_paths_widget2.dart';
import 'package:open_bsp/services/viewmodel_locator.dart';

import '../../bloc /current_path/segment_widget_bloc.dart';
import '../../bloc /current_path/current_segment_event.dart';
import '../../model/appmodes.dart';
import '../../viewmodel/current_path_view_model.dart';
import 'bottom_sheet.dart';
import 'segment_widget.dart';

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  // SketcherController viewmodel =  getIt<SketcherController>();
  CurrentPathViewModel _currentPathVM = getIt<CurrentPathViewModel>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawingPageBloc, DrawingPageState>(
        builder: (context, state) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Biegeapp'), Text(state.mode.name)],
          ),
        ),
        backgroundColor: Colors.yellow[50],
        body: Container(
          child: Stack(children: [
            AllPathsWidget2(),
            SegmentWidget(),
            // AllPathsWidget(),
            // CurrentPathWidget()
          ]),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          children: [
            SpeedDialChild(child: Icon(Icons.delete), onTap: clear),
            SpeedDialChild(
                child: Icon(Icons.select_all), onTap: toggleSelectionMode),
            SpeedDialChild(child: Icon(Icons.circle), onTap: toggleDefaultMode),
            SpeedDialChild(
                child: Icon(Icons.circle_notifications), onTap: _bottomSheet),
          ],
        ),
      );
    });
  }

  Future<void> clear() async {
    BlocProvider.of<SegmentWidgetBloc>(context).add((SegmentDeleted()));
    // BlocProvider.of<AllSegmentsBloc>(context).add(AllSegmentsDeleted());
  }

  void toggleSelectionMode() {
    context
        .read<DrawingPageBloc>()
        .add(DrawingPageModeChanged(mode: Mode.selectionMode));
  }

  void toggleDefaultMode() {
    context
        .read<DrawingPageBloc>()
        .add(DrawingPageModeChanged(mode: Mode.defaultMode));
    // context.read<SegmentWidgetBloc>().add(CurrentSegmentUnselected());
  }

  void _bottomSheet() {
    showModalBottomSheet(
      enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return AppBottomSheet();
      },
    );
  }
}

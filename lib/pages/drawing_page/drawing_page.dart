import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';
import 'package:open_bsp/bloc%20/segment_widget/current_segment_event.dart';

import '../../bloc /constructing/constructing_page_bloc.dart';
import '../../bloc /segment_widget/segment_widget_bloc.dart';
import '../../model/appmodes.dart';
import '../../model/segment_widget/segment.dart';
import 'bottom_sheet.dart';
import 'segment_widget.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawingPageBloc, DrawingPageState>(
        builder: (context, state) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
        backgroundColor: Color(0xff009374),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Biegeapp'), Text(state.mode.name)],
          ),
        ),
        backgroundColor: Colors.yellow[50],
        body: Container(
          child: Stack(children: [
            SegmentWidget(),
          ]),
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              left: 40,
              bottom: 20,
              child: SpeedDial(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                icon: Icons.add,
                activeIcon: Icons.close,
                children: [
                  SpeedDialChild(child: Icon(Icons.delete), onTap: clear),
                  SpeedDialChild(
                      child: Icon(Icons.select_all),
                      onTap: toggleSelectionMode),
                  SpeedDialChild(
                      child: Icon(Icons.circle), onTap: toggleDefaultMode),
                  SpeedDialChild(
                      child: Icon(Icons.circle_notifications),
                      onTap: _bottomSheet),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 10,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.arrow_right),
                onPressed: () => _goToNextPage(),
              ),
            ),
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

  void _goToNextPage() {
    List<Segment> segment = context.read<SegmentWidgetBloc>().state.segment;
    print('gotonextpage');
    BlocProvider.of<ConstructingPageBloc>(context)
        .add(ConstructingPageCreated(segment: segment));

    Navigator.of(context).pushNamed('/second');
  }
}

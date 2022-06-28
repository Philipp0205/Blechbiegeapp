import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';
import 'package:open_bsp/bloc%20/drawing_page/segment_widget/drawing_widget_event.dart';

import '../../bloc /configuration_page/configuration_page_bloc.dart';
import '../../bloc /drawing_page/segment_widget/drawing_widget_bloc.dart';
import '../../model/appmodes.dart';
import '../../model/segment_widget/segment.dart';
import 'bottom_sheet.dart';
import 'drawing_widget.dart';

/// On this page the user can draw a single line representing the the profile
/// of a metal sheet.
///
/// The length and angle of the lines can be changed in a bottom sheet.
class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  bool editLines = false;

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
        backgroundColor: Colors.white,
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  height: 300,
                  width: 500,
                  child: Stack(children: [
                    DrawingWidget(),
                  ]),
                ),
                Divider(color: Colors.green),
                Text(
                  'Einstellungen',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Checkbox(value: editLines, onChanged: (bool? value) {
                      setState(() {
                        editLines = value!;
                      });
                    }),
                    Text('Linien selektieren')
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Stack(
          children: [
            /// Left Button
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
                  SpeedDialChild(
                      child: Icon(Icons.delete), onTap: _clearCanvas),
                  SpeedDialChild(
                      child: Icon(Icons.select_all),
                      onTap: _toggleSelectionMode),
                  SpeedDialChild(
                      child: Icon(Icons.circle), onTap: _toggleDefaultMode),
                  SpeedDialChild(
                      child: Icon(Icons.circle_notifications),
                      onTap: _bottomSheet),
                ],
              ),
            ),

            /// Right Button
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

  Future<void> _clearCanvas() async {
    BlocProvider.of<DrawingWidgetBloc>(context).add((SegmentDeleted()));
  }

  void _toggleSelectionMode() {
    context
        .read<DrawingPageBloc>()
        .add(DrawingPageModeChanged(mode: Mode.selectionMode));
  }

  void _toggleDefaultMode() {
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
    List<Segment> segment = context.read<DrawingWidgetBloc>().state.segment;
    print('gotonextpage');
    BlocProvider.of<ConfigPageBloc>(context)
        .add(ConfigPageCreated(segment: segment));

    Navigator.of(context).pushNamed('/second');
  }
}

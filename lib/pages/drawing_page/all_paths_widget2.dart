import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/all_paths/all_segments_bloc.dart';

import 'sketcher.dart';

class AllPathsWidget2 extends StatefulWidget {
  @override
  State<AllPathsWidget2> createState() => _AllPathsWidget2State();
}

class _AllPathsWidget2State extends State<AllPathsWidget2> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllSegmentsBloc, AllPathsState>(
      builder: (context, state) {
        return RepaintBoundary(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.transparent,
            padding: EdgeInsets.all(4.0),
            alignment: Alignment.topLeft,
            child: CustomPaint(
              // painter: Sketcher(
              //   lines: state.segments,
              // ),
            ),
          ),
        );
      },
    );
  }
}

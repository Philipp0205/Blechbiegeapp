import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/all_paths/all_segments_bloc.dart';
import 'package:open_bsp/bloc%20/constructing/constructing_page_bloc.dart';
import 'package:open_bsp/bloc%20/current_path/segment_widget_bloc.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';
import 'package:open_bsp/bloc%20/modes/mode_cubit.dart';
import 'package:open_bsp/data/segments_repository.dart';
import 'package:open_bsp/pages/constructing_page/constructing_page.dart';
import 'package:open_bsp/pages/drawing_page/drawing_page.dart';
import 'package:open_bsp/services/color_service.dart';
import 'package:open_bsp/services/segment_data_service.dart';
import 'package:open_bsp/services/viewmodel_locator.dart';
import 'package:open_bsp/viewmodel/current_path_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    ColorService colorService = new ColorService();
    return RepositoryProvider(
      create: (context) => SegmentsRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SegmentWidgetBloc(),
          ),
          BlocProvider(
            create: (_) => DrawingPageBloc(),
          ),
          BlocProvider(
            create: (_) => ConstructingPageBloc(),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          // home: DrawingPage(),
          theme: ThemeData(
              primaryColor: Color(0xff009374),
              primarySwatch:
                  colorService.buildMaterialColor(Color(0xff009374))),
          initialRoute: '/',
          routes: {
            '/': (context) => const DrawingPage(),
            '/second': (context) => const ConstructingPage()
          },
          // ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/current_path/current_path_bloc.dart';
import 'package:open_bsp/pages/drawing_page/drawing_page.dart';
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
    return BlocProvider(
      create: (_) => CurrentPathBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        home: DrawingPage(),
        initialRoute: '/',
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/configuration_page/configuration_page_bloc.dart';
import 'package:open_bsp/drawing/drawing_page/bloc/drawing_page_bloc.dart';
import 'package:open_bsp/bloc%20/shapes_page/tool_page_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/drawing/drawing_widget/bloc/drawing_widget_bloc.dart';
import 'package:open_bsp/pages/configuration_page/configuration_page.dart';
import 'package:open_bsp/drawing/drawing_page/view/drawing_page.dart';
import 'package:open_bsp/pages/simulation_page/simulation_page.dart';
import 'package:open_bsp/pages/tool_page/tool_page.dart';
import 'package:open_bsp/persistence/database_provider.dart';
import 'package:open_bsp/persistence/repositories/tool_repository.dart';
import 'package:open_bsp/services/color_service.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    ColorService colorService = new ColorService();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ToolRepository>(
          create: (context) => ToolRepository(DatabaseProvider()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => DrawingWidgetBloc(),
          ),
          BlocProvider(
            create: (_) => DrawingPageBloc(),
          ),
          BlocProvider(
            create: (context) => ConfigPageBloc(context.read<ToolRepository>())
              ..add(ConfigRegisterAdapters()),
          ),
          BlocProvider(
            create: (_) => SimulationPageBloc(),
          ),
          BlocProvider(
            create: (context) => ToolPageBloc(context.read<ToolRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          // home: DrawingPage(),
          theme: ThemeData(
              primaryColor: Color(0xffD22630),
              primarySwatch:
                  colorService.buildMaterialColor(Color(0xffD22630))),
          initialRoute: '/',
          routes: {
            '/': (context) => const DrawingPage(),
            // '/': (context) => DrawingPage1(),
            '/config': (context) => const ConfigurationPage(),
            '/third': (context) => const SimulationPage(),
            '/shapes': (context) => const ToolPage()
          },
          // ),
        ),
      ),
    );
  }
}

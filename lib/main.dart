import 'package:flutter/material.dart';
import 'package:open_bsp/model/appmodes.dart';
import 'package:open_bsp/pages/drawing_page/drawing_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AppModes()),
    ], child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: DrawingPage(),
      initialRoute: '/',
    );
  }
}

import 'package:get_it/get_it.dart';
import 'package:open_bsp/controller/linking_controller.dart';
import 'package:open_bsp/controller/sketcher_controller.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<SketcherController>(() => SketcherController());
  getIt.registerLazySingleton<LinkingController>(() => LinkingController());
}

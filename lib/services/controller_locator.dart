import 'package:get_it/get_it.dart';
import 'package:open_bsp/controller/all_paths_controller.dart';
import 'package:open_bsp/controller/current_path_controller.dart';
import 'package:open_bsp/controller/linking_controller.dart';
import 'package:open_bsp/controller/modes_controller.dart';
import 'package:open_bsp/controller/sketcher_controller.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<ModesController>(() => ModesController());
  getIt.registerLazySingleton<SketcherController>(() => SketcherController());
  getIt.registerLazySingleton<LinkingController>(() => LinkingController());
  getIt.registerLazySingleton<CurrentPathController>(() => CurrentPathController());
  getIt.registerLazySingleton<AllPathsController>(() => AllPathsController());
}

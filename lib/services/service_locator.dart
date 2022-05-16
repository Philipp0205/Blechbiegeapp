import 'package:get_it/get_it.dart';
import 'package:open_bsp/controller/sketcher_controller.dart';

final getIt = GetIt.instance;

void setup() {
  // getIt.registerFactory<SketcherDataViewModel>(() => SketcherDataViewModel());
  getIt.registerLazySingleton<SketcherController>(() => SketcherController());
}

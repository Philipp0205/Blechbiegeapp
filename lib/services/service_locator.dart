import 'package:get_it/get_it.dart';
import 'package:open_bsp/view_model/sketcher_data_service.dart';

final getIt = GetIt.instance;

void setup() {
  // getIt.registerFactory<SketcherDataViewModel>(() => SketcherDataViewModel());
  getIt.registerLazySingleton<SketcherDataViewModel>(() => SketcherDataViewModel());
}

import 'package:get_it/get_it.dart';
import 'package:open_bsp/services/segment_data_service.dart';

import '../viewmodel/all_paths_view_model.dart';
import '../viewmodel/current_path_view_model.dart';
import '../viewmodel/modes_controller_view_model.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<ModesViewModel>(() => ModesViewModel());
  getIt.registerLazySingleton<CurrentPathViewModel>(() => CurrentPathViewModel());
  getIt.registerLazySingleton<AllPathsViewModel>(() => AllPathsViewModel());
  
  getIt.registerLazySingleton<SegmentDataService>(() => SegmentDataService());
}

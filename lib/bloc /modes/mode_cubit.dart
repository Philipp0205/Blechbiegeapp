import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/modes/modes_state.dart';

import '../../model/appmodes.dart';

class ModeCubit extends Cubit<ModesState> {
  ModeCubit() : super(ModesInitial(mode: Mode.defaultMode));
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../model/appmodes.dart';

part 'drawing_page_event.dart';

part 'drawing_page_state.dart';

class DrawingPageBloc extends Bloc<DrawingPageEvent, DrawingPageState> {
  DrawingPageBloc()
      : super(DrawingPageInitial(
          mode: Mode.defaultMode,
          selectionMode: false,
          setAdapterMode: false,
          currentAngle: 0,
          currentLength: 0,
        )) {
    on<DrawingPageSelectionModeChanged>(_onSelectionModeChanged);
  }

  void _onSelectionModeChanged(
      DrawingPageSelectionModeChanged event, Emitter<DrawingPageState> emit) {
    emit(state.copyWith(selectionMode: event.selectionMode));
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../model/appmodes.dart';

part 'drawing_page_event.dart';
part 'drawing_page_state.dart';

class DrawingPageBloc extends Bloc<DrawingPageEvent, DrawingPageState> {
  DrawingPageBloc() : super(DrawingPageInitial(mode: Mode.defaultMode)) {
    on<DrawingPageModeChanged>(_onSelectionModePressed);
  }

  void _onSelectionModePressed(
      DrawingPageModeChanged event, Emitter<DrawingPageState> emit) {
    emit(ModeSelectionSuccess(mode: event.mode));
  }
}

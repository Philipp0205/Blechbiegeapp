import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../model/appmodes.dart';

part 'drawing_page_event.dart';

part 'drawing_page_state.dart';

class DrawingPageBloc extends Bloc<DrawingPageEvent, DrawingPageState> {
  DrawingPageBloc() : super(DrawingPageInitial(mode: Mode.defaultMode)) {
    on<DrawingPageModeSelectionPressed>(_onSelectionModePressed);
  }

  void _onSelectionModePressed(
      DrawingPageModeSelectionPressed event, Emitter<DrawingPageState> emit) {
    print('onSelectionModePressed');
    emit(ModeSelectionSuccess(mode: event.mode));
  }
}

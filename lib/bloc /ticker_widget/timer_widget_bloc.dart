import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'timer_widget_event.dart';
part 'timer_widget_state.dart';

class TimerWidgetBloc extends Bloc<TimerWidgetEvent, TimerWidgetState> {
  TimerWidgetBloc() : super(TickerWidgetInitial()) {
    on<TimerWidgetEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

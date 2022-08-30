import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../pages/simulation_page/ticker.dart';

part 'timer_widget_event.dart';

part 'timer_widget_state.dart';

class TimerWidgetBloc extends Bloc<TimerWidgetEvent, TimerWidgetState> {
  TimerWidgetBloc({required Ticker ticker})
      : _ticker = ticker,
        super(TimerWidgetInitial(_duration)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerTicked>(_onTicked);
    on<TimerStopped>(_onStopped);
  }

  final Ticker _ticker;
  static const int _duration = 60;

  StreamSubscription<int>? _tickerSubscription;

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerWidgetState> emit) {
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(TimerTicked(duration: duration)));
  }

  void _onPaused(TimerPaused event, Emitter<TimerWidgetState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  void _onResumed(TimerResumed resume, Emitter<TimerWidgetState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerWidgetState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerWidgetInitial(_duration));
  }

  void _onTicked(TimerTicked event, Emitter<TimerWidgetState> emit) {
    emit(
      event.duration > 0
          ? TimerRunInProgress(event.duration)
          : const TimerRunComplete(),
    );
  }

  void _onStopped(TimerStopped event, Emitter<TimerWidgetState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerWidgetInitial(_duration));
  }
}

part of 'timer_widget_bloc.dart';

abstract class TimerWidgetEvent extends Equatable {
  const TimerWidgetEvent();

  @override
  List<Object> get props => [];
}

class TimerStarted extends TimerWidgetEvent {
  const TimerStarted({required this.duration});

  final int duration;
}

class TimerPaused extends TimerWidgetEvent {
  const TimerPaused();
}

class TimerResumed extends TimerWidgetEvent {
  const TimerResumed();
}

class TimerReset extends TimerWidgetEvent {
  const TimerReset();
}

class TimerTicked extends TimerWidgetEvent {
  const TimerTicked({required this.duration});

  final int duration;

  @override
  List<Object> get props => [duration];
}

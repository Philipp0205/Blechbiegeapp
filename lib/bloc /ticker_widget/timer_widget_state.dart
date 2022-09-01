part of 'timer_widget_bloc.dart';

abstract class TimerWidgetState extends Equatable {
  final int duration;

  const TimerWidgetState(this.duration);

  @override
  List<Object> get props => [duration];
}

class TimerWidgetInitial extends TimerWidgetState {
  const TimerWidgetInitial(int duration) : super(duration);

  @override
  String toString() => 'TimerInitial { duration: $duration }';
}

class TimerRunPause extends TimerWidgetState {
  const TimerRunPause(int duration) : super(duration);

  @override
  String toString() => 'TimerRunPause { duration: $duration }';
}

class TimerRunInProgress extends TimerWidgetState {
  const TimerRunInProgress(int duration) : super(duration);

  @override
  String toString() => 'TimerRunInProgress { duration: $duration }';
}

class TimerRunComplete extends TimerWidgetState {
  const TimerRunComplete() : super(0);
}

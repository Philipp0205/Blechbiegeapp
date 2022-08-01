part of 'simulation_page_bloc.dart';

abstract class SimulationPageEvent extends Equatable {
  const SimulationPageEvent();

  @override
  List<Object?> get props => [];
}

/// Event which gets fired when the page is created.
/// The event contains the initial values likes [lines] for the page.
class SimulationPageCreated extends SimulationPageEvent {
  final List<Line> lines;

  const SimulationPageCreated({required this.lines});
}

/// The event contains the new [Tool]s.
/// The event is used to change the [Tool]s in the [SimulationPageState].
class SimulationToolsChanged extends SimulationPageEvent {
  final List<Tool> tools;
  const SimulationToolsChanged({required this.tools});
}

/// The event contains the new s value.
/// The event is used to change the s value in the [SimulationPageState].
class SimulationSChanged extends SimulationPageEvent {
  final double s;
  const SimulationSChanged({required this.s});
}

/// The event contains if the [Tool] should be rotated clockswise or
/// anti-clockwise.
/// The event is used to change the [Tool]s in the [SimulationPageState].
class SimulationToolRotate extends SimulationPageEvent {
  final Tool tool;
  final double degrees;

  const SimulationToolRotate({required this.tool, required this.degrees});
}

/// The event contains nothing.
/// The event is called when the next line of a plate is placed on the lower
/// track.
class SimulationSelectedPlateLineChanged extends SimulationPageEvent {
  const SimulationSelectedPlateLineChanged();
}



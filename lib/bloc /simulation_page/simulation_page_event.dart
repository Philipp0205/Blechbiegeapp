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



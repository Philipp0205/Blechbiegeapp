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

/// Event that triggers when the selected [Tools]s change.
/// The event contains the new selected [Tools]s.
class SimulationSelectedToolsChanged extends SimulationPageEvent {
  final List<Tool> selectedTools;
  const SimulationSelectedToolsChanged({required this.selectedTools});
}

/// Event tat triggers when the selected tracks change.
///  The event contains the new selected tracks.
class SimulationSelectedTracksChanged extends SimulationPageEvent {
  final List<Tool> selectedTracks;
  const SimulationSelectedTracksChanged({required this.selectedTracks});
}



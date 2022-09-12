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

/// Do I need that?
class SimulationPlatePlaced extends SimulationPageEvent {
  final List<Tool> selectedPlates;

  const SimulationPlatePlaced({required this.selectedPlates});
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

/// The event contains nothing.
/// The event is called when the current tool is mirrored.
/// The event is used to change the [Tool]s in the [SimulationPageState].
class SimulationToolMirrored extends SimulationPageEvent {
  final Tool tool;

  const SimulationToolMirrored({required this.tool});
}

// The event is called when after a collision test.
class SimulationCollisionDetected extends SimulationPageEvent {
  final List<Offset> collisionOffsets;
  final List<Offset> plateOffsets;

  const SimulationCollisionDetected(
      {required this.collisionOffsets, required this.plateOffsets});
}

/// The event is called when the user starts the simulation.
class SimulationStarted extends SimulationPageEvent {
  final double timeInterval;

  const SimulationStarted({required this.timeInterval});
}

/// The event is called when the user stops the simulation.
class SimulationStopped extends SimulationPageEvent {
  const SimulationStopped();
}

class SimulationTicked extends SimulationPageEvent {
  const SimulationTicked();
}

/// Unfolds plate
class SimulationPlateUnfolded extends SimulationPageEvent {
  final Tool plate;

  const SimulationPlateUnfolded({required this.plate});
}

/// Refolds plate
class SimulationPlateRefolded extends SimulationPageEvent {
  final Tool plate;

  const SimulationPlateRefolded({required this.plate});
}

part of 'simulation_page_bloc.dart';

class SimulationPageState extends Equatable {
  final List<Tool> shapes;
  final List<Line> lines;
  final List<Tool> selectedBeams;
  final List<Tool> selectedTracks;
  final List<Tool> selectedPlates;
  final double rotationAngle;
  final bool inCollision;
  final bool isSimulationRunning;
  final double duration;
  final List<Offset> collisionOffsets;
  final List<Offset> debugOffsets;

  /// In what states can the simulation page be in?
  const SimulationPageState(
      {required this.shapes,
      required this.lines,
      required this.selectedPlates,
      required this.selectedBeams,
      required this.selectedTracks,
      required this.rotationAngle,
      required this.collisionOffsets,
      required this.debugOffsets,
      required this.inCollision,
      required this.isSimulationRunning,
      required this.duration});

  @override
  List<Object> get props => [
        shapes,
        lines,
        selectedBeams,
        selectedTracks,
        selectedPlates,
        rotationAngle,
        collisionOffsets,
        inCollision,
        isSimulationRunning,
        duration,
      ];

  SimulationPageState copyWith({
    List<Tool>? shapes,
    List<Line>? lines,
    List<Tool>? selectedBeams,
    List<Tool>? selectedTracks,
    List<Tool>? selectedPlates,
    double? rotationAngle,
    bool? inCollision,
    bool? isSimulationRunning,
    double? duration,
    List<Offset>? collisionOffsets,
    List<Offset>? debugOffsets,
  }) {
    return SimulationPageState(
      shapes: shapes ?? this.shapes,
      lines: lines ?? this.lines,
      selectedBeams: selectedBeams ?? this.selectedBeams,
      selectedTracks: selectedTracks ?? this.selectedTracks,
      selectedPlates: selectedPlates ?? this.selectedPlates,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      inCollision: inCollision ?? this.inCollision,
      isSimulationRunning: isSimulationRunning ?? this.isSimulationRunning,
      duration: duration ?? this.duration,
      collisionOffsets: collisionOffsets ?? this.collisionOffsets,
      debugOffsets: debugOffsets ?? this.debugOffsets,
    );
  }
}

/// Initial values when the Bloc is created the first time.
class SimulationPageInitial extends SimulationPageState {
  SimulationPageInitial({
    required List<Tool> tools,
    required List<Tool> selectedBeams,
    required List<Tool> selectedTracks,
    required List<Tool> selectedPlates,
    required List<Line> lines,
    required double rotationAngle,
    required List<Offset> collisionOffsets,
    required List<Offset> debugOffsets,
    required bool inCollision,
    required bool isSimulationRunning,
    required double duration,
  }) : super(
          shapes: tools,
          lines: lines,
          selectedPlates: selectedPlates,
          selectedBeams: selectedBeams,
          selectedTracks: selectedTracks,
          rotationAngle: rotationAngle,
          collisionOffsets: collisionOffsets,
          debugOffsets: debugOffsets,
          inCollision: inCollision,
          isSimulationRunning: isSimulationRunning,
          duration: duration,
        );
}

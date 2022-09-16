part of 'simulation_page_bloc.dart';

class SimulationPageState extends Equatable {
  final List<Tool> shapes;
  final List<Line> lines;
  final List<Tool> selectedBeams;
  final List<Tool> selectedTracks;
  final List<Tool> selectedPlates;
  final List<BendResult> bendingHistory;
  final List<DebugOffset> debugOffsets;
  final double rotationAngle;
  final bool inCollision;
  final bool isSimulationRunning;
  final double duration;
  final int currentTick;
  final List<Offset> collisionOffsets;
  final List<SimulationToolResult> simulationResults;

  const SimulationPageState(
      {required this.shapes,
      required this.lines,
      required this.selectedPlates,
      required this.selectedBeams,
      required this.selectedTracks,
      required this.bendingHistory,
      required this.debugOffsets,
      required this.rotationAngle,
      required this.collisionOffsets,
      required this.inCollision,
      required this.isSimulationRunning,
      required this.duration,
      required this.currentTick,
      required this.simulationResults});

  @override
  List<Object> get props => [
        shapes,
        lines,
        selectedBeams,
        selectedTracks,
        selectedPlates,
        bendingHistory,
        rotationAngle,
        collisionOffsets,
        inCollision,
        isSimulationRunning,
        duration,
        currentTick,
        simulationResults,
        bendingHistory,
        debugOffsets,
      ];

  SimulationPageState copyWith({
    List<Tool>? shapes,
    List<Line>? lines,
    List<Tool>? selectedBeams,
    List<Tool>? selectedTracks,
    List<Tool>? selectedPlates,
    List<BendResult>? bendingHistory,
    List<DebugOffset>? debugOffsets,
    List<SimulationToolResult>? simulationResults,
    double? rotationAngle,
    bool? inCollision,
    bool? isSimulationRunning,
    double? duration,
    int? currentTick,
    List<Offset>? collisionOffsets,
  }) {
    return SimulationPageState(
      shapes: shapes ?? this.shapes,
      lines: lines ?? this.lines,
      selectedBeams: selectedBeams ?? this.selectedBeams,
      selectedTracks: selectedTracks ?? this.selectedTracks,
      selectedPlates: selectedPlates ?? this.selectedPlates,
      bendingHistory: bendingHistory ?? this.bendingHistory,
      debugOffsets: debugOffsets ?? this.debugOffsets,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      inCollision: inCollision ?? this.inCollision,
      isSimulationRunning: isSimulationRunning ?? this.isSimulationRunning,
      duration: duration ?? this.duration,
      currentTick: currentTick ?? this.currentTick,
      collisionOffsets: collisionOffsets ?? this.collisionOffsets,
      simulationResults: simulationResults ?? this.simulationResults,
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
    required List<BendResult> bendingHistory,
    required List<Line> lines,
    required List<DebugOffset> debugOffsets,
    required List<Offset> collisionOffsets,
    required double rotationAngle,
    required bool inCollision,
    required bool isSimulationRunning,
    required double duration,
    required int currentTick,
    required List<SimulationToolResult> simulationResult,
  }) : super(
          shapes: tools,
          lines: lines,
          selectedPlates: selectedPlates,
          selectedBeams: selectedBeams,
          selectedTracks: selectedTracks,
          bendingHistory: bendingHistory,
          debugOffsets: debugOffsets,
          rotationAngle: rotationAngle,
          collisionOffsets: collisionOffsets,
          inCollision: inCollision,
          isSimulationRunning: isSimulationRunning,
          duration: duration,
          currentTick: currentTick,
          simulationResults: simulationResult,
        );
}

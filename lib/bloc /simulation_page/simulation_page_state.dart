part of 'simulation_page_bloc.dart';

class SimulationPageState extends Equatable {
  final List<Tool> shapes;
  final List<Line> lines;
  final List<Tool> selectedBeams;
  final List<Tool> selectedTracks;
  final List<Tool> selectedPlates;
  final double rotationAngle;

  const SimulationPageState({
    required this.shapes,
    required this.lines,
    required this.selectedPlates,
    required this.selectedBeams,
    required this.selectedTracks,
    required this.rotationAngle,
  });

  @override
  List<Object> get props => [
        shapes,
        lines,
        selectedBeams,
        selectedTracks,
        selectedPlates,
        rotationAngle
      ];

  SimulationPageState copyWith({
    List<Tool>? shapes,
    List<Line>? lines,
    List<Tool>? selectedBeams,
    List<Tool>? selectedTracks,
    List<Tool>? selectedPlates,
    double? rotationAngle,
  }) {
    return SimulationPageState(
      shapes: shapes ?? this.shapes,
      lines: lines ?? this.lines,
      selectedBeams: selectedBeams ?? this.selectedBeams,
      selectedTracks: selectedTracks ?? this.selectedTracks,
      selectedPlates: selectedPlates ?? this.selectedPlates,
      rotationAngle: rotationAngle ?? this.rotationAngle,
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
  }) : super(
          shapes: tools,
          lines: lines,
          selectedPlates: selectedPlates,
          selectedBeams: selectedBeams,
          selectedTracks: selectedTracks,
          rotationAngle: rotationAngle,
        );
}

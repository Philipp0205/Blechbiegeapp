part of 'simulation_page_bloc.dart';

class SimulationPageState extends Equatable {
  final List<Shape> shapes;
  final List<Line> lines;

  const SimulationPageState({required this.shapes, required this.lines});

  SimulationPageState copyWith({
    List<Shape>? shapes,
    List<Line>? lines,
  }) {
    return SimulationPageState(
      shapes: shapes ?? this.shapes,
      lines: lines ?? this.lines,
    );
  }

  @override
  List<Object> get props => [shapes];
}

/// Initial values when the Bloc is created the first time.
class SimulationPageInitial extends SimulationPageState {
  SimulationPageInitial({
    required List<Shape> shapes,
    required List<Line> lines,
  }) : super(shapes: shapes, lines: lines);
}

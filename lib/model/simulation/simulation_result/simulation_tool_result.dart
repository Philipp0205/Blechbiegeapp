import '../tool.dart';
import 'collision_result.dart';

class SimulationToolResult {
  final Tool tool;
  final double angleOfTool;
  final List<CollisionResult> collisionResults;

  const SimulationToolResult(
      {required this.tool,
      required this.angleOfTool,
      required this.collisionResults});

  SimulationToolResult copyWith({
    Tool? tool,
    double? angleOfTool,
    List<CollisionResult>? collisionResults,
  }) {
    return SimulationToolResult(
      tool: tool ?? this.tool,
      angleOfTool: angleOfTool ?? this.angleOfTool,
      collisionResults: collisionResults ?? this.collisionResults,
    );
  }
}

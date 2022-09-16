import '../tool.dart';
import 'collision_result.dart';

class SimulationToolResult {
  final Tool tool;
  final double angleOfTool;
  final List<CollisionResult> collisionResults;
  final int numberOfCheckedLines;
  final bool isBendable;

  const SimulationToolResult(
      {required this.tool,
      required this.angleOfTool,
      required this.collisionResults,
      required this.numberOfCheckedLines,
      required this.isBendable});

  SimulationToolResult copyWith({
    Tool? tool,
    double? angleOfTool,
    List<CollisionResult>? collisionResults,
    int? checkedLines,
    bool? isBendable,
  }) {
    return SimulationToolResult(
      collisionResults: collisionResults != null
          ? List.from(collisionResults)
          : List.from(this.collisionResults),
      tool: tool ?? this.tool,
      angleOfTool: angleOfTool ?? this.angleOfTool,
      numberOfCheckedLines: checkedLines ?? this.numberOfCheckedLines,
      isBendable: isBendable ?? this.isBendable,
    );
  }
}

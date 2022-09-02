import 'dart:collection';

import '../tool.dart';
import 'collision_result.dart';

class SimulationToolResult {
  final Tool tool;
  final List<CollisionResult> collisionResults;

  const SimulationToolResult(
      {required this.tool, required this.collisionResults});

  SimulationToolResult copyWith({
    Tool? tool,
    List<CollisionResult>? collisionResults,
  }) {
    return SimulationToolResult(
      tool: tool ?? this.tool,
      collisionResults: collisionResults ?? this.collisionResults,
    );
  }
}

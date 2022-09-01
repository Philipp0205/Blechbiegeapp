import 'package:open_bsp/model/simulation/tool.dart';

class SimulationToolResult {
  final Tool tool;
  final Map<double, bool> angleCollisionMap;

  SimulationToolResult({
    required this.tool,
    required this.angleCollisionMap,
  });

  SimulationToolResult copyWith({
    Tool? tool,
    Map<double, bool>? angleCollisionMap,
  }) {
    return SimulationToolResult(
      tool: tool ?? this.tool,
      angleCollisionMap: angleCollisionMap ?? this.angleCollisionMap,
    );
  }

  void addResult(double angle, bool result) {
    angleCollisionMap.addEntries([MapEntry(angle, result)]);
  }
}

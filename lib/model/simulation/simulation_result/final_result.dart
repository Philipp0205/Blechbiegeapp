import 'package:open_bsp/model/simulation/simulation_result/simulation_tool_result.dart';

class FinalResult {
  final bool result; // true if the simulation was successful
  final List<SimulationToolResult>
      simulationResults; // the results of the simulation

  const FinalResult({
    required this.result,
    required this.simulationResults,
  });
}

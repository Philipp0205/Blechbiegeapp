import 'package:hive/hive.dart';

import '../../model/simulation/tool.dart';
import '../database_provider.dart';

class ToolRepository {
  final DatabaseProvider databaseProvider;

  ToolRepository(this.databaseProvider);

  Future<List<Tool>> getTools() async {
    Box box = await databaseProvider.createBox('tools');
    return box.toMap().values.toList().cast<Tool>();
  }
  
  Future<void> addTool(Tool tool) async {
    Box box = await databaseProvider.createBox('tools');
    box.add(tool);
  }

  Future<void> deleteTool(Tool tool) async {
    Box box = await databaseProvider.createBox('tools');
    box.delete(tool);
  }

  Future<void> updateTool(Tool tool) async {
    Box box = await databaseProvider.createBox('tools');
    box.put(tool, tool);
  }
}

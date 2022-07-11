import 'package:hive/hive.dart';

import '../../model/simulation/tool.dart';
import '../database_provider.dart';

class ToolRepository {
  final DatabaseProvider databaseProvider;

  ToolRepository(this.databaseProvider);

  /// get all tools from the database.
  Future<List<Tool>> getTools() async {
    Box box = await databaseProvider.createBox('tools');
    return box.toMap().values.toList().cast<Tool>();
  }

  // Add given [tool] to the database.
  Future<void> addTool(Tool tool) async {
    Box box = await databaseProvider.createBox('tools');
    box.add(tool);
  }

  /// Delete the tool with the given [index].
  Future<void> deleteTool(int index) async {
    Box box = await databaseProvider.createBox('tools');
    box.deleteAt(index);
  }

  /// Update given [tool] in the database.
  Future<void> updateTool(int index, Tool tool) async {
    Box box = await databaseProvider.createBox('tools');
    box.put(index, tool);
  }

  /// Delete all tools from the database.
  Future<void> deleteAllTools() async {
    Box box = await databaseProvider.createBox('tools');
    box.clear();
  }

}

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../model/OffsetAdapter.dart';
import '../../model/line.dart';
import '../../model/simulation/tool.dart';
import '../../model/simulation/tool_type.dart';
import '../../model/simulation/tool_type2.dart';
import '../database_provider.dart';

class ToolRepository {
  final DatabaseProvider databaseProvider;
  final String boxName = 'shapes5';

  ToolRepository(this.databaseProvider);

  /// Initializes the box with the name [boxName].
  void initRepo() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ToolAdapter());
    Hive.registerAdapter(LineAdapter());
    Hive.registerAdapter(OffsetAdapter());
    Hive.registerAdapter(ToolTypeAdapter());
    Hive.registerAdapter(ToolType2Adapter());
    Hive.openBox(boxName);
  }

  /// get all tools from the database.
  Future<List<Tool>> getTools() async {
    Box box = await databaseProvider.createBox(boxName);
    print('getTools ${box.values.length}');
    return box.toMap().values.toList().cast<Tool>();
  }

  // Add given [tool] to the database.
  Future<void> addTool(Tool tool) async {
    Box box = await databaseProvider.createBox(boxName);
    String key = _getKey(tool);
    box.put(key, tool);
  }

  /// Delete the tool with the given [index].
  Future<void> deleteTool(Tool tool) async {
    print('repo delete tool ${tool.name}');
    Box box = await databaseProvider.createBox(boxName);
    String key = _getKey(tool);
    box.delete(key);
  }

  /// Update given [tool] in the database.
  Future<void> updateTool(Tool oldTool, Tool tool) async {
    Box box = await databaseProvider.createBox(boxName);
    String key = _getKey(oldTool);
    box.put(key, tool);
  }

  /// Delete all tools from the database.
  Future<void> deleteAllTools() async {
    Box box = await databaseProvider.createBox(boxName);
    box.clear();
  }

  String _getKey(Tool tool) {
    return tool.name.toLowerCase().replaceAll(' ', '-');
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_bsp/model/simulation/enums/position_enum.dart';
import 'package:path_provider/path_provider.dart';

import '../../model/OffsetAdapter.dart';
import '../../model/line.dart';
import '../../model/simulation/enums/tool_category_enum.dart';
import '../../model/simulation/tool.dart';
import '../../model/simulation/tool_type.dart';
import '../../model/simulation/tool_type2.dart';
import '../database_provider.dart';

class ToolRepository {
  final DatabaseProvider databaseProvider;
  String boxName = 'shapes9';

  ToolRepository(this.databaseProvider);

  /// Initializes the box with the name [boxName].
  void initRepo() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ToolAdapter());
    Hive.registerAdapter(LineAdapter());
    Hive.registerAdapter(OffsetAdapter());
    Hive.registerAdapter(ToolTypeAdapter());
    Hive.registerAdapter(ToolType2Adapter());
    Hive.registerAdapter(ToolCategoryEnumAdapter());
    Hive.registerAdapter(PositionEnumAdapter());
    Hive.openBox(boxName);
  }

  /// get all tools from the database.
  Future<List<Tool>> getTools() async {
    Box box = await databaseProvider.createBox(boxName);
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

  void loadBackup() async {
    Hive.initFlutter();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    // Hive.init(appDocDir.path);

    await Hive.openBox('shapes9');
    Box box = Hive.box('shapes9');

    String hiveLoc = appDocDir.path.toString() + '/shapes10.hive';
    await box.close;

    ByteData data = await rootBundle.load('assets/data/shapes10.hive');
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    File(hiveLoc).writeAsBytes(bytes, flush: true);
    Box box2 = await Hive.openBox('shapes10');
    print(box2.length);
    Box oldBox = await Hive.openBox('shapes9');

    List<Tool> oldTools = await oldBox.toMap().values.toList().cast<Tool>();
    List<Tool> newTools = await box2.toMap().values.toList().cast<Tool>();

    for (Tool tool in newTools) {
      if (oldTools.contains(tool) == false) {
        addTool(tool);
      }
    }
  }

  void loadBackup2() async {
    restoreHiveBox('shapes10', 'assets/data/shapes10.hive');
    Box box = Hive.box('shapes10');
    print(box.length);
  }

  Future<void> backupHiveBox<T>(String boxName, String backupPath) async {
    final box = await Hive.openBox<T>(boxName);
    final boxPath = box.path;
    await box.close();

    try {
      File(boxPath!).copy(backupPath);
    } finally {
      await Hive.openBox<T>(boxName);
    }
  }

  Future<void> restoreHiveBox<T>(String boxName, String backupPath) async {
    Box box = await databaseProvider.createBox(boxName);
    // final box = await Hive.openBox<T>(boxName);
    // File(backupPath)
    final boxPath = box.path;
    await box.close();

    try {
      File(backupPath).copy(boxPath!);
    } finally {
      await Hive.openBox<T>(boxName);
    }
  }
}

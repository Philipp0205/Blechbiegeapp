import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';

import '../model/simulation/tool.dart';
import '../persistence/repositories/tool_repository.dart';

class JsonSerializer {
  Future<File?> createBackupFile(ToolRepository toolRepository) async {
    // List<Tool> allTools = await toolRepository.getTools();
    // Box toolsBox = Hive.box('shapes9');
    //
    // /// This example uses the OS temp directory
    // File backupFile = File('${Directory.systemTemp.path}/backup_tools.json');
    //
    // try {
    //   /// barcodeBox is the [Box] object from the Hive package, usually exposed inside a [ValueListenableBuilder] or via [Hive.box()]
    //   List<String> jsonList = [];
    //   toolsBox.values.toList().forEach((tool) {
    //   });
    //
    //   print('');
    //
    //   backupFile = await backupFile.writeAsString(jsonEncode(toolsBox.values));
    //
    //   return backupFile;
    // } catch (e) {
    //   // TODO: handle exception
    // }
  }
}

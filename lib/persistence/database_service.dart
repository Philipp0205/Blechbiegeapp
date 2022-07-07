import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {

  /// Create a new box for the given [boxName]
  /// If the box already exists, it will be opened.
  Future<Box> createBox(String boxName) async {
    await Hive.initFlutter();
    return await Hive.openBox(boxName);
  }

  /// Write the given [value] to the given [boxName]
  Future<void> writeToBox(String boxName, String key, dynamic value) async {
    final box = await createBox(boxName);
    box.put(key, value);
  }

  /// Read the given [key] from the given [boxName]
  Future<dynamic> readFromBox(String boxName, String key) async {
    final box = await createBox(boxName);
    return box.get(key);
  }
  
}

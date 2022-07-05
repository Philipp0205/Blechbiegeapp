import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // open database and create it if it doesn't exist
  Future<Database> initShapesDatabase() async {
    return await openDatabase(join(await getDatabasesPath(), 'shapes.db'),
        onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE shapes(id INTEGER PRIMARY KEY, name TEXT, )',
      );
    });
  }
}

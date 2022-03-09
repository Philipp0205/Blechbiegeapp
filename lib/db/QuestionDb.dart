import 'package:open_bsp/models/question.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Database {
  static final TestDb instance = TestDb._init();

  static Database? _database;

  TestDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Dog>> dogs() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('dogs');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Dog(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }

// Define a function that inserts dogs into the database
  Future<void> insertDog(Dog dog) async {
    final db = await instance.database;

    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  testInsert() async {
    // Create a Dog and add it to the dogs table
    var fido = const Dog(
      id: 0,
      name: 'Fido',
      age: 35,
    );

    await insertDog(fido);
  }
}

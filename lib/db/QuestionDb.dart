import 'package:open_bsp/models/category.dart';
import 'package:open_bsp/models/question.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class QuestionDb {
  static final QuestionDb instance = QuestionDb._init();

  static Database? _database;

  QuestionDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB('questions.db');
    return _database!;
  }

  Future<Database> initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    print("dbPath: " + dbPath);

    final path = join(dbPath, filePath);

    return await openDatabase(path, onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
      );
    }, version: 1);
  }

  void initDB2() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'questions.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE dogss(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        );
      },
      version: 1,
    );
  }

  void testTable() async {
    final db = await database;
    db.execute(
      'CREATE TABLE questions('
      'id INTEGER PRIMARY KEY, '
      'question TEXT, '
      'correctAnswer TEXT, '
      'falseAnswer1 TEXT, '
      'falseAnswer2 TEXT'
      ')',
    );
  }

  void categoryTable() async {
    final db = await database;
    db.execute(
      'CREATE TABLE categories('
      'id INTEGER PRIMARY KEY, '
      'name TEXT, '
      'imagePath TEXT'
      ')',
    );
  }

  Future _createDB(Database db, int version) async {
    return db.execute(
      'CREATE TABLE questions('
      'id INTEGER PRIMARY KEY, '
      'question TEXT, '
      'correctAnswer TEXT, '
      'falseAnswer1 TEXT, '
      'falseAnswer2 TEXT'
      ')',
    );
  }

  void dropDatabase() async {
    print('Dropping table...');
    final db = await database;

    db.execute('DROP TABLE questions');
  }

  void execSql(String sql) async {
    final db = await database;
    db.execute(sql);
  }

  Future<List<Question>> getQuestions() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('questions');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      List<Option> options = [];

      Option option1 = new Option(true, maps[i]['correctAnswer']);
      Option option2 = new Option(false, maps[i]['falseAnswer1']);
      Option option3 = new Option(false, maps[i]['falseAnswer2']);

      options.addAll([option1, option2, option3]);
      return Question(
        id: maps[i]['id'],
        category: maps[i]['category'],
        question: maps[i]['question'],
        options: options,
      );
    });
  }

  Future<List<Category>> getCategories() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('categories');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      String name = maps[i]['imagePath'];
      print('category: $name');

      return Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
        imagePath: maps[i]['imagePath'],
        color: maps[i]['color'],
      );
    });
  }

// Define a function that inserts dogs into the database
  Future<void> insertQuestion(Question question) async {
    final db = await instance.database;

    await db.insert(
      'questions',
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertCategory(Category category) async {
    final db = await instance.database;

    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Question>> getAllQuestionsOfCategory(String category) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query('questions', where: 'category = ?', whereArgs: [category]);

    return List.generate(maps.length, (i) {
      List<Option> options = [
        Option(true, maps[i]['correctAnswer']),
        Option(false, maps[i]['falseAnswer1']),
        Option(false, maps[i]['falseAnswer2']),
      ];

      return Question(
        id: maps[i]['id'],
        category: maps[i]['category'],
        question: maps[i]['question'],
        options: options,
      );
    });
  }

  testInsert() async {
    Option option1 = new Option(true, "Antwort 1");
    Option option2 = new Option(false, "Antwort 2");
    Option option3 = new Option(false, "Antwort 3");

    List<Option> options = [];
    options.add(option1);
    options.add(option2);
    options.add(option3);

    var sampleQuestion = new Question(
        id: 1,
        category: "Testkategorie",
        question: "Testfrage",
        options: options);
    await insertQuestion(sampleQuestion);
  }

  void closeDatabase() async {
    final db = await instance.database;
    db.close();
  }
}

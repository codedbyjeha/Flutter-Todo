import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        title TEXT,
        description TEXT,
        isCompleted INTEGER,
        createdAt TEXT,
        dueDate TEXT,
        completedAt TEXT,
        isReminderActive INTEGER,
        priority TEXT,
        category TEXT,
        repeatRule TEXT,
        tags TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT
        )
      ''');
      await db.execute("ALTER TABLE todos ADD COLUMN userId INTEGER");
      await db.execute("ALTER TABLE todos ADD COLUMN repeatRule TEXT");
      await db.execute("ALTER TABLE todos ADD COLUMN tags TEXT");
      await db.execute("ALTER TABLE todos ADD COLUMN completedAt TEXT");
    }
  }

  Future<int> insertTodo(Todo todo) async {
    Database db = await database;
    return await db.insert('todos', todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Todo>> getTodos(int userId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<int> updateTodo(Todo todo) async {
    Database db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    Database db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertUser(AppUser user) async {
    Database db = await database;
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<AppUser?> getUserByCredentials(String username, String password) async {
    Database db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return AppUser.fromMap(result.first);
  }

  Future<AppUser?> getUserByUsername(String username) async {
    Database db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return AppUser.fromMap(result.first);
  }

  Future<AppUser?> getUserById(int id) async {
    Database db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return AppUser.fromMap(result.first);
  }
}

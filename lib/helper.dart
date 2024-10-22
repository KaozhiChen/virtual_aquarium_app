import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'aquarium.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE fish (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fish_color TEXT,
            fish_speed REAL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS fish');
          await db.execute('''
            CREATE TABLE fish (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              fish_color TEXT,
              fish_speed REAL
            )
          ''');
        }
      },
    );
  }

  // save the speed and color
  Future<void> saveFish(String fishColor, double fishSpeed) async {
    final db = await database;
    await db.insert(
      'fish',
      {
        'fish_color': fishColor,
        'fish_speed': fishSpeed,
      },
    );
  }

  // clean list
  Future<void> clearFish() async {
    final db = await database;
    await db.delete('fish');
  }

  // load the fish
  Future<List<Map<String, dynamic>>> loadFish() async {
    try {
      final db = await database;
      final result = await db.query('fish');
      return result;
    } catch (e) {
      return [];
    }
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/movie.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "cineflow.db");

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history(
            id TEXT PRIMARY KEY,
            title TEXT,
            year TEXT,
            poster TEXT,
            type TEXT,
            genre TEXT,
            imdbRating TEXT
          )
        ''');
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await _database;
    return db.query("history", orderBy: "rowid DESC", limit: 10);
  }

  static Future<void> insertHistory(Movie movie) async {
    final db = await _database;
    await db.insert(
      "history",
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> clearHistory() async {
    final db = await _database;
    await db.delete("history");
  }
}

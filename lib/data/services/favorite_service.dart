import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FavoritesService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'favorites.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id TEXT PRIMARY KEY,
            title TEXT,
            poster TEXT,
            year TEXT,
            type TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertFavorite(Map<String, dynamic> movie) async {
    final db = await database;
    await db.insert(
      'favorites',
      movie,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query('favorites');
  }

  Future<void> deleteFavorite(String id) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
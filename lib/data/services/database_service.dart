// lib/data/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cineflow/data/models/movie.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> _openDB() async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'cineflow.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table historique
        await db.execute('''
          CREATE TABLE history(
            id TEXT PRIMARY KEY,
            title TEXT,
            year TEXT,
            Rated TEXT,
            released TEXT,
            runtime TEXT,
            genre TEXT,
            director TEXT,
            writer TEXT,
            actors TEXT,
            plot TEXT,
            language TEXT,
            country TEXT,
            awards TEXT,
            poster TEXT,
            ratings TEXT,
            metascore TEXT,
            imdbRating TEXT,
            imdbVotes TEXT,
            type TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        // Table downloads
        await db.execute('''
          CREATE TABLE downloads(
            id TEXT PRIMARY KEY,
            title TEXT,
            year TEXT,
            genre TEXT,
            poster TEXT,
            type TEXT,
            rating REAL
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<Database> initDB() => _openDB();

  // -------- HISTORY --------
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await initDB();
    return await db.query(
      'history',
      orderBy: 'timestamp DESC',
    );
  }

  static Future<void> insertHistory(Movie movie) async {
    final db = await initDB();
    await db.insert(
      'history',
      {
        'id': movie.imdbID,
        'title': movie.title,
        'year': movie.year,
        'genre': movie.genre,
        'poster': movie.poster,
        'type': movie.type,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // -------- DOWNLOADS --------
  static Future<void> insertDownload(Movie movie) async {
    final db = await initDB();
    await db.insert(
      'downloads',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteDownload(String id) async {
    final db = await initDB();
    await db.delete(
      'downloads',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> getDownloads() async {
    final db = await initDB();
    return await db.query(
      'downloads',
      orderBy: 'rowid DESC',
    );
  }
}

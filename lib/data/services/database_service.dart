import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cineflow/data/models/movie.dart';

class DatabaseService {
  static Database? _db;

  static const String _dbName = 'cineflow.db';
  static const int _dbVersion = 2; // ⚠️ on incrémente la version
  static const String tableHistory = 'history';
  static const String tableDownloads = 'downloads';

  // ---------- Ouverture unique de la DB ----------
  static Future<Database> _getDb() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _db!;
  }

  // ---------- Création initiale ----------
  static Future<void> _onCreate(Database db, int version) async {
    // Table historique
    await db.execute('''
      CREATE TABLE $tableHistory(
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

    // Table téléchargements
    await db.execute('''
      CREATE TABLE $tableDownloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        tmdb_id TEXT NOT NULL,
        title TEXT,
        year TEXT,
        genre TEXT,
        type TEXT,
        poster TEXT,
        rating REAL
      )
    ''');
  }

  // ---------- Upgrade (si la DB existe déjà en version 1) ----------
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // On ajoute la table downloads si elle n’existe pas
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableDownloads (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          tmdb_id TEXT NOT NULL,
          title TEXT,
          year TEXT,
          genre TEXT,
          type TEXT,
          poster TEXT,
          rating REAL
        )
      ''');
    }
  }

  // ---------- Compat pour ton ancien code ----------
  static Future<Database> initDB() async {
    // pour tout le code qui appelle encore initDB()
    return _getDb();
  }

  // ================== HISTORY ==================

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await _getDb();
    return await db.query(
      tableHistory,
      orderBy: 'timestamp DESC',
    );
  }

  static Future<void> insertHistory(Movie movie) async {
    final db = await _getDb();
    await db.insert(
      tableHistory,
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

  // ================== DOWNLOADS ==================

  static Future<List<Map<String, dynamic>>> getDownloads(int userId) async {
    final db = await _getDb();
    return db.query(
      tableDownloads,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  static Future<void> insertDownload(int userId, Movie movie) async {
    final db = await _getDb();

    await db.insert(
      tableDownloads,
      {
        'user_id': userId,
        'tmdb_id': movie.imdbID,
        'title': movie.title,
        'year': movie.year,
        'genre': movie.genre,
        'type': movie.type,
        'poster': movie.poster,
        'rating': movie.rating,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteDownload(int userId, String tmdbId) async {
    final db = await _getDb();
    await db.delete(
      tableDownloads,
      where: 'user_id = ? AND tmdb_id = ?',
      whereArgs: [userId, tmdbId],
    );
  }
}

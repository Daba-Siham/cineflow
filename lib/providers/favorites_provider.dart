import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavoritesProvider extends ChangeNotifier {
  Database? _db;

  // Liste complète des films favoris (chaque film est stocké comme Map)
  final List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> get favorites => List.unmodifiable(_favorites);

  // Ensemble des IDs favoris pour un accès rapide
  final Set<String> _favoriteIds = {};
  Set<String> get favoriteIds => _favoriteIds;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'movie_favorites.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            id TEXT PRIMARY KEY,
            title TEXT,
            poster TEXT,
            year TEXT,
            type TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  /// Charge tous les favoris depuis la DB au démarrage
  Future<void> loadFavorites() async {
    final db = await database;
    final rows = await db.query('favorites');

    _favorites
      ..clear()
      ..addAll(rows);

    _favoriteIds
      ..clear()
      ..addAll(rows.map((e) => e['id'] as String));

    notifyListeners();
  }

  // === Méthodes utilisées par MovieDetailsPage ===

  bool isFavorite(String imdbId) {
    return _favoriteIds.contains(imdbId);
  }

  Future<void> addFavorite(Map<String, dynamic> movieMap) async {
    final db = await database;

    await db.insert(
      'favorites',
      movieMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final id = movieMap['id'] as String;

    _favoriteIds.add(id);
    _favorites.removeWhere((m) => m['id'] == id);
    _favorites.add(movieMap);

    notifyListeners();
  }

  Future<void> removeFavorite(String imdbId) async {
    final db = await database;

    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [imdbId],
    );

    _favoriteIds.remove(imdbId);
    _favorites.removeWhere((m) => m['id'] == imdbId);

    notifyListeners();
  }
}

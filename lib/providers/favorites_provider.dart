// import 'package:flutter/foundation.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class FavoritesProvider extends ChangeNotifier {
//   Database? _db;

//   // Liste complète des films favoris (chaque film est stocké comme Map)
//   final List<Map<String, dynamic>> _favorites = [];
//   List<Map<String, dynamic>> get favorites => List.unmodifiable(_favorites);

//   // Ensemble des IDs favoris pour un accès rapide
//   final Set<String> _favoriteIds = {};
//   Set<String> get favoriteIds => _favoriteIds;

//   Future<Database> get database async {
//     if (_db != null) return _db!;
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'movie_favorites.db');

//     _db = await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE favorites (
//             id TEXT PRIMARY KEY,
//             title TEXT,
//             poster TEXT,
//             year TEXT,
//             type TEXT
//           )
//         ''');
//       },
//     );
//     return _db!;
//   }

//   /// Charge tous les favoris depuis la DB au démarrage
//   Future<void> loadFavorites() async {
//     final db = await database;
//     final rows = await db.query('favorites');

//     _favorites
//       ..clear()
//       ..addAll(rows);

//     _favoriteIds
//       ..clear()
//       ..addAll(rows.map((e) => e['id'] as String));

//     notifyListeners();
//   }

//   // === Méthodes utilisées par MovieDetailsPage ===

//   bool isFavorite(String imdbId) {
//     return _favoriteIds.contains(imdbId);
//   }

//   Future<void> addFavorite(Map<String, dynamic> movieMap) async {
//     final db = await database;

//     await db.insert(
//       'favorites',
//       movieMap,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );

//     final id = movieMap['id'] as String;

//     _favoriteIds.add(id);
//     _favorites.removeWhere((m) => m['id'] == id);
//     _favorites.add(movieMap);

//     notifyListeners();
//   }

//   Future<void> removeFavorite(String imdbId) async {
//     final db = await database;

//     await db.delete(
//       'favorites',
//       where: 'id = ?',
//       whereArgs: [imdbId],
//     );

//     _favoriteIds.remove(imdbId);
//     _favorites.removeWhere((m) => m['id'] == imdbId);

//     notifyListeners();
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:cineflow/data/services/favorite_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _service = FavoritesService();

  List<Map<String, dynamic>> _favorites = [];
  int? _userId;

  List<Map<String, dynamic>> get favorites => _favorites;

  void setUser(int? userId) {
    _userId = userId;
  }
  bool isFavorite(String imdbId) {
    return _favorites.any((m) => m['imdb_id'] == imdbId || m['id'] == imdbId);
  }


  Future<void> loadFavorites() async {
    if (_userId == null) return;
    final data = await _service.getFavorites(_userId!);
    _favorites = List<Map<String, dynamic>>.from(data);
    notifyListeners();
  }

  Future<void> addFavorite(Map<String, dynamic> movie) async {
    if (_userId == null) return;
    final ok = await _service.addFavorite(_userId!, movie);
    if (ok) {
      _favorites.add(movie);
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String imdbId) async {
    if (_userId == null) return;
    final ok = await _service.removeFavorite(_userId!, imdbId);
    if (ok) {
      _favorites.removeWhere((m) => m['imdb_id'] == imdbId);
      notifyListeners();
    }
  }

  Future<void> clearFavorites() async {
    if (_userId == null) return;
    final ok = await _service.clearFavorites(_userId!);
    if (ok) {
      _favorites.clear();
      notifyListeners();
    }
  }
  
}

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class FavoritesService {
//   static Database? _db;

//   Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await _initDB();
//     return _db!;
//   }

//   Future<Database> _initDB() async {

//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'favorites.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE favorites(
//             id TEXT PRIMARY KEY,
//             title TEXT,
//             poster TEXT,
//             year TEXT,
//             type TEXT
//           )
//         ''');
//       },
//     );
//   }

//   // CREATE
//   Future<void> insertFavorite(Map<String, dynamic> movie) async {
//     final db = await database;
//     await db.insert(
//       'favorites',
//       movie,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   // READ
//   Future<List<Map<String, dynamic>>> getFavorites() async {
//     final db = await database;
//     return await db.query('favorites');
//   }

//   //  DELETE
//   Future<void> deleteFavorite(String id) async {
//     final db = await database;
//     await db.delete(
//       'favorites',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cineflow/core/constants/api_constants.dart';

class FavoritesService {
  Future<List<dynamic>> getFavorites(int userId) async {
    final url = Uri.parse('${ApiConstants.favoritesBase}/$userId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  Future<bool> addFavorite(int userId, Map<String, dynamic> movie) async {
    final url = Uri.parse('${ApiConstants.favoritesBase}/$userId');
    final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(movie));
    return res.statusCode == 201;
  }

  Future<bool> removeFavorite(int userId, String imdbId) async {
    final url = Uri.parse('${ApiConstants.favoritesBase}/$userId/$imdbId');
    final res = await http.delete(url);
    return res.statusCode == 200;
  }

  Future<bool> clearFavorites(int userId) async {
    final url = Uri.parse('${ApiConstants.favoritesBase}/clear/$userId');
    final res = await http.delete(url);
    return res.statusCode == 200;
  }
}

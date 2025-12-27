// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:cineflow/data/models/movie.dart'; // <-- IMPORTANT

// class DatabaseService {

//   static Future<Database> initDB() async {
//     final path = join(await getDatabasesPath(), 'cineflow.db');
//     return openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE history(
//             id TEXT PRIMARY KEY,
//             title TEXT,
//             year TEXT,
//             Rated TEXT,
//             released TEXT,
//             runtime TEXT,
//             genre TEXT,
//             director TEXT,
//             writer TEXT,
//             actors TEXT,
//             plot TEXT,
//             language TEXT,
//             country TEXT,
//             awards TEXT,
//             poster TEXT,
//             ratings TEXT,
//             metascore TEXT,
//             imdbRating TEXT,
//             imdbVotes TEXT,
//             type TEXT,
//             timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
//           )
//         ''');
//       },
//     );
//   }

//   static Future<List<Map<String, dynamic>>> getHistory() async {
//     final db = await initDB();
//     return await db.query(
//       'history',
//       orderBy: 'timestamp DESC',
//     );
//   }

//   static Future<void> insertHistory(Movie movie) async {
//     final db = await initDB();
//     await db.insert(
//       'history',
//       {
//         'id': movie.imdbID,
//         'title': movie.title,
//         'year': movie.year,
//         'genre': movie.genre,
//         'poster': movie.poster,
//         'type': movie.type,
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
// }



import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class FavoritesApiService {
  static Future<List<Map<String, dynamic>>> fetchFavorites(int userId) async {
    final url = Uri.parse('${ApiConstants.favoritesBase}/$userId');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement des favoris');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((row) {
      return {
        'id': row['imdb_id'],
        'title': row['title'],
        'poster': row['poster'],
        'year': row['year'],
        'type': row['type'],
      };
    }).toList();
  }

  static Future<void> addFavorite(int userId, Map<String, dynamic> movieMap) async {
    final url = Uri.parse('${ApiConstants.favoritesBase}/$userId');

    final payload = {
      'imdbID': movieMap['id'],
      'Title': movieMap['title'],
      'Year': movieMap['year'],
      'Poster': movieMap['poster'],
      'Type': movieMap['type'],
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de l\'ajout du favori');
    }
  }

  static Future<void> removeFavorite(int userId, String imdbId) async {
    final url = Uri.parse('${ApiConstants.favoritesBase}/$userId/$imdbId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression du favori');
    }
  }
}

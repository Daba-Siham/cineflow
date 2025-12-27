// lib/data/services/api_service.dart
import 'dart:convert';
import '../models/movie.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/movie_detail.dart';

class ApiService {
  // Pour search des Films
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}?apikey=${ApiConstants.tmdbApiKey}&s=$query&page=$page&type=movie',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['Response'] == 'True') {
        final List results = data['Search'];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Erreur de connexion à OMDb');
    }
  }

  // ✅ AJOUT : Pour search des Séries
  Future<List<Movie>> searchSeries(String query, {int page = 1}) async {
    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}?apikey=${ApiConstants.tmdbApiKey}&s=$query&page=$page&type=series',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['Response'] == 'True') {
        final List results = data['Search'];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Erreur de connexion à OMDb');
    }
  }

  // Pour Détails d'un Film
  Future<MovieDetail?> getMovieDetail(String imdbId) async {
    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}?apikey=${ApiConstants.tmdbApiKey}&i=$imdbId&plot=full',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['Response'] == 'True') {
        return MovieDetail.fromJson(data);
      } else {
        return null; // film non trouvé
      }
    } else {
      throw Exception('Erreur de connexion à OMDb');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';

class ApiService {
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    print('➡️ OMDb CALL: $uri');
    final res = await http.get(uri);
    print('⬅️ STATUS: ${res.statusCode}');
    print('⬅️ BODY: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Erreur réseau: ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    if (data is Map<String, dynamic>) return data;
    throw Exception('Réponse invalide');
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final q = query.trim().isEmpty ? "star" : query.trim();
    final uri = Uri.parse(
      '${ApiConstants.omdbBaseUrl}?apikey=${ApiConstants.omdbApiKey}&s=$q&page=$page',
    );

    final data = await _getJson(uri);

    // ⚠️ SI OMDb RENVOIE UNE ERREUR, ON LA REMONTE
    if (data['Response'] == 'False') {
      final err = data['Error'] ?? 'Erreur OMDb inconnue';
      throw Exception(err);
    }

    final list = (data['Search'] as List? ?? []);
    return list.map((e) => Movie.fromJson(e)).toList();
  }

  Future<int> getTotalResults(String query) async {
    final q = query.trim().isEmpty ? "star" : query.trim();
    final uri = Uri.parse(
      '${ApiConstants.omdbBaseUrl}?apikey=${ApiConstants.omdbApiKey}&s=$q&page=1',
    );

    final data = await _getJson(uri);
    if (data['Response'] == 'False') {
      return 0;
    }

    return int.tryParse((data['totalResults'] ?? '0').toString()) ?? 0;
  }

  Future<List<Movie>> discoverMovies({
    required String query,
    String? type,
    String? year,
    int page = 1,
  }) async {
    final q = query.trim().isEmpty ? "star" : query.trim();
    final typeParam = (type == null || type.isEmpty) ? "" : "&type=$type";
    final yearParam = (year == null || year.isEmpty) ? "" : "&y=$year";

    final uri = Uri.parse(
      '${ApiConstants.omdbBaseUrl}?apikey=${ApiConstants.omdbApiKey}&s=$q&page=$page$typeParam$yearParam',
    );

    final data = await _getJson(uri);

    if (data['Response'] == 'False') {
      final err = data['Error'] ?? 'Erreur OMDb inconnue';
      throw Exception(err);
    }

    final list = (data['Search'] as List? ?? []);
    return list.map((e) => Movie.fromJson(e)).toList();
  }

  Future<MovieDetail?> getMovieDetail(String imdbId) async {
    final uri = Uri.parse(
      '${ApiConstants.omdbBaseUrl}?apikey=${ApiConstants.omdbApiKey}&i=$imdbId&plot=full',
    );

    final data = await _getJson(uri);
    if (data['Response'] == 'False') {
      final err = data['Error'] ?? 'Erreur OMDb inconnue';
      throw Exception(err);
    }
    return MovieDetail.fromJson(data);
  }

  Future<Map<String, dynamic>> getMovieDetailsMap(String imdbId) async {
    final uri = Uri.parse(
      '${ApiConstants.omdbBaseUrl}?apikey=${ApiConstants.omdbApiKey}&i=$imdbId&plot=short',
    );

    final data = await _getJson(uri);
    if (data['Response'] == 'False') {
      final err = data['Error'] ?? 'Erreur OMDb inconnue';
      throw Exception(err);
    }
    return data;
  }
}

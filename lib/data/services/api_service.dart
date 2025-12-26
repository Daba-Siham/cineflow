import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';

class ApiService {
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final res = await http.get(uri);
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

    if (data['Response'] == 'True') {
      final list = (data['Search'] as List? ?? []);
      return list.map((e) => Movie.fromJson(e)).toList();
    }
    return [];
  }

  Future<int> getTotalResults(String query) async {
    final q = query.trim().isEmpty ? "star" : query.trim();
    final uri = Uri.parse(
      '${ApiConstants.omdbBaseUrl}?apikey=${ApiConstants.omdbApiKey}&s=$q&page=1',
    );

    final data = await _getJson(uri);
    if (data['Response'] == 'True') {
      return int.tryParse((data['totalResults'] ?? '0').toString()) ?? 0;
    }
    return 0;
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

    if (data['Response'] == 'True') {
      final list = (data['Search'] as List? ?? []);
      return list.map((e) => Movie.fromJson(e)).toList();
    }
    return [];
  }

  Future<MovieDetail?> getMovieDetail(String imdbId) async {
    final uri = Uri.parse(
      '${ApiConstants.omdbBaseUrl}?apikey=${ApiConstants.omdbApiKey}&i=$imdbId&plot=full',
    );

    final data = await _getJson(uri);
    if (data['Response'] == 'True') {
      return MovieDetail.fromJson(data);
    }
    return null;
  }

  Future<Map<String, dynamic>> getMovieDetailsMap(String imdbId) async {
    final uri = Uri.parse(
      '${ApiConstants.omdbBaseUrl}?apikey=${ApiConstants.omdbApiKey}&i=$imdbId&plot=short',
    );

    final data = await _getJson(uri);
    if (data['Response'] == 'True') return data;
    return {};
  }
}

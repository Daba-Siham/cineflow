import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cineflow/core/constants/api_constants.dart';

class HistoryService {
  Future<List<dynamic>> getHistory(int userId) async {
    final url = Uri.parse('${ApiConstants.historyBase}/$userId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  Future<bool> addHistory(int userId, Map<String, dynamic> movie) async {
    final url = Uri.parse('${ApiConstants.historyBase}/$userId');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(movie),
    );
    return res.statusCode == 201;
  }

  Future<bool> clearHistory(int userId) async {
    final url = Uri.parse('${ApiConstants.historyBase}/$userId');
    final res = await http.delete(url);
    return res.statusCode == 200;
  }
}

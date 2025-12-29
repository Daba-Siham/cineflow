import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryProvider extends ChangeNotifier {
  final List<String> _queries = [];
  List<String> get queries => List.unmodifiable(_queries);

  String _storageKey = 'search_history_guest';

  Future<void> init({int? userId}) async {
    _storageKey =
        userId != null ? 'search_history_user_$userId' : 'search_history_guest';
    await _loadFromPrefs();
  }

  Future<void> switchUser(int? userId) async {
    _storageKey =
        userId != null ? 'search_history_user_$userId' : 'search_history_guest';
    await _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey) ?? [];

    _queries
      ..clear()
      ..addAll(saved);

    notifyListeners();
  }

  Future<void> addQuery(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    _queries.remove(q);
    _queries.insert(0, q);

    if (_queries.length > 15) {
      _queries.removeLast();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _queries);

    notifyListeners();
  }

  Future<void> removeQuery(String query) async {
    _queries.remove(query);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _queries);

    notifyListeners();
  }

  Future<void> clear() async {
    _queries.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }
}

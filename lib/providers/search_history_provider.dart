import 'package:flutter/material.dart';

class SearchHistoryProvider extends ChangeNotifier {
  final List<String> _items = [];

  List<String> get items => List.unmodifiable(_items);

  void add(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    if (!_items.contains(q)) {
      _items.insert(0, q);
      notifyListeners();
    }
  }

  void remove(String query) {
    _items.remove(query);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

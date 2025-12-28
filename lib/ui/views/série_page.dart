// lib/ui/views/series_page.dart
import 'package:flutter/material.dart';

import '../../core/utils/pagination_utils.dart';
import '../../data/models/movie.dart';
import '../widgets/empty_state.dart';
import '../widgets/movie_card.dart';
import '../widgets/pagination_bar.dart';

class SeriesPage extends StatefulWidget {
  final List<Movie> series;

  const SeriesPage({super.key, required this.series});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  static const int perPage = 12;
  int _currentPage = 1;
  int _groupStart = 1;

  int get totalPages =>
      (widget.series.length / perPage).ceil().clamp(1, 9999);

  List<Movie> get _pageItems =>
      paginate<Movie>(widget.series, _currentPage, perPage);

  void _onPageSelected(int p) {
    setState(() => _currentPage = p);
  }

  void _onPrevGroup() {
    if (_groupStart <= 1) return;
    setState(() {
      _groupStart = (_groupStart - 5).clamp(1, totalPages);
      _currentPage = _groupStart;
    });
  }

  void _onNextGroup() {
    final newStart = _groupStart + 5;
    if (newStart > totalPages) return;
    setState(() {
      _groupStart = newStart;
      _currentPage = _groupStart;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.series.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Toutes les séries')),
        body: Center(
          child: EmptyState(message: 'Aucune série à afficher.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Toutes les séries')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _pageItems.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: _pageItems[index]);
              },
            ),
          ),
          if (totalPages > 1)
            PaginationBar(
              currentPage: _currentPage,
              totalPages: totalPages,
              groupStart: _groupStart,
              isDark: isDark,
              onPrevGroup: _onPrevGroup,
              onNextGroup: _onNextGroup,
              onPageSelected: _onPageSelected,
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

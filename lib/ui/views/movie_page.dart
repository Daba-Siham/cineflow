import 'package:flutter/material.dart';

import '../../core/utils/pagination_utils.dart';
import '../../data/models/movie.dart';
import '../widgets/empty_state.dart';
import '../widgets/movie_card.dart';
import '../widgets/pagination_bar.dart';

class MoviesPage extends StatefulWidget {
  final List<Movie> movies;

  const MoviesPage({super.key, required this.movies});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  static const int perPage = 12;
  int _currentPage = 1;
  int _groupStart = 1;

  int get totalPages =>
      (widget.movies.length / perPage).ceil().clamp(1, 9999);

  List<Movie> get _pageItems =>
      paginate<Movie>(widget.movies, _currentPage, perPage);

  void _onPageSelected(int p) {
    setState(() {
      _currentPage = p;
    });
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

    if (widget.movies.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Tous les films')),
        body: Center(
          child: EmptyState(message: 'Aucun film à afficher.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tous les films')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 MovieCard par ligne
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

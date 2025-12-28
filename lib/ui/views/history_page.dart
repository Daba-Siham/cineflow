import 'package:cineflow/ui/widgets/pagination_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/ui/widgets/movie_card.dart';
import 'package:cineflow/ui/widgets/empty_state.dart';
import 'package:cineflow/data/models/movie.dart';

import '../../core/utils/pagination_utils.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const int perPage = 10;

  int _currentPage = 1;
  int _groupStart = 1;

  List<Movie> _pageItems(List<Movie> all) =>
      paginate<Movie>(all, _currentPage, perPage);

  void _onPageSelected(int p) {
    setState(() => _currentPage = p);
  }

  void _onPrevGroup(int totalPages) {
    if (_groupStart <= 1) return;
    setState(() {
      _groupStart = (_groupStart - 5).clamp(1, totalPages);
      _currentPage = _groupStart;
    });
  }

  void _onNextGroup(int totalPages) {
    final newStart = _groupStart + 5;
    if (newStart > totalPages) return;
    setState(() {
      _groupStart = newStart;
      _currentPage = _groupStart;
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<MovieProvider>().history;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (history.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Historique"),
        ),
        body: const Center(
          child: EmptyState(
            message: "Aucun film consulté pour le moment.",
          ),
        ),
      );
    }

    final totalPages = (history.length / perPage).ceil().clamp(1, 9999);

    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }
    if (_groupStart > totalPages) {
      _groupStart = ((totalPages - 4) > 1 ? (totalPages - 4) : 1);
    }

    final pageItems = _pageItems(history);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: pageItems.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  return MovieCard(movie: pageItems[index]);
                },
              ),
            ),
          ),
          if (totalPages > 1)
            PaginationBar(
              currentPage: _currentPage,
              totalPages: totalPages,
              groupStart: _groupStart,
              isDark: isDark,
              onPrevGroup: () => _onPrevGroup(totalPages),
              onNextGroup: () => _onNextGroup(totalPages),
              onPageSelected: _onPageSelected,
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/services/recommendation_service.dart';
import 'package:cineflow/ui/widgets/movie_card.dart';
import 'package:cineflow/ui/widgets/empty_state.dart';
import 'package:cineflow/ui/widgets/pagination_bar.dart';

import '../../core/utils/pagination_utils.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  static const int perPage = 12;

  bool _isLoading = true;
  String? _errorMessage;
  List<Movie> _recos = [];

  int _currentPage = 1;
  int _groupStart = 1;

  int get totalPages =>
      (_recos.length / perPage).ceil().clamp(1, 9999);

  List<Movie> get _pageItems =>
      paginate<Movie>(_recos, _currentPage, perPage);

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      // on utilise la nouvelle signature avec BuildContext + limit
      final list =
          await RecommendationService().getRecommendations(context, limit: 50);
      if (!mounted) return;
      setState(() {
        _recos = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            "Erreur lors du chargement des recommandations.";
        _isLoading = false;
      });
    }
  }

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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Suggestions automatiques"),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Suggestions automatiques"),
        ),
        body: Center(
          child: Text(_errorMessage!),
        ),
      );
    }

    if (_recos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Suggestions automatiques"),
        ),
        body: Center(
          child: EmptyState(
            message:
                "Consulte au moins un film pour avoir des recommandations.",
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Suggestions automatiques"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: _pageItems.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  return MovieCard(movie: _pageItems[index]);
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

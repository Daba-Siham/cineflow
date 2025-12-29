import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/providers/search_history_provider.dart';
import '../utils/pagination_utils.dart';
import 'movie_details_page.dart';
import '../widgets/history_section.dart';
import '../widgets/recommendation_section.dart';
import '../widgets/pagination_bar.dart';
import 'package:cineflow/providers/auth_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  bool _showAllRecent = false;

  static const int perPage = 10;
  int _currentPage = 1;
  int _groupStart = 1;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      context
          .read<SearchHistoryProvider>()
          .init(userId: auth.isLoggedIn ? auth.userId : null);
    });
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  void _resetPagination() {
    _currentPage = 1;
    _groupStart = 1;
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final query = value.trim();
    setState(() {});

    if (query.isEmpty) {
      context.read<MovieProvider>().clearSearch();
      _resetPagination();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _resetPagination();
      context.read<MovieProvider>().search(query);
    });
  }

  void _runSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;

    context.read<SearchHistoryProvider>().addQuery(q);

    _controller.text = q;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: _controller.text.length));

    _onSearchChanged(q);
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) return;

    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
    } else {
      if (mounted) setState(() => _isListening = true);

      await _speech.listen(
        localeId: 'fr_FR',
        onResult: (result) {
          final text = result.recognizedWords;
          _runSearch(text);
        },
      );
    }
  }

  void _clearAllRecent() {
    context.read<SearchHistoryProvider>().clear();
    setState(() {
      _showAllRecent = false;
    });
  }

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
    final movieProvider = context.watch<MovieProvider>();
    final historyProvider = context.watch<SearchHistoryProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final hasQuery = _controller.text.trim().isNotEmpty;

    const int maxVisible = 8;
    final List<String> allRecent = historyProvider.queries;
    final List<String> visibleSearches =
        _showAllRecent ? allRecent : allRecent.take(maxVisible).toList();

    final results = movieProvider.results;
    final totalPages =
        (results.length / perPage).ceil().clamp(1, 9999);
    if (_currentPage > totalPages && totalPages > 0) {
      _currentPage = totalPages;
    }
    if (_groupStart > totalPages && totalPages > 0) {
      _groupStart = ((totalPages - 4) > 1 ? (totalPages - 4) : 1);
    }
    final pageItems = paginate(results, _currentPage, perPage);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Rechercher un film...',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.clear();
                        context.read<MovieProvider>().clearSearch();
                        _resetPagination();
                        setState(() {});
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _toggleListening,
                  ),
                ],
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _onSearchChanged,
            onSubmitted: _runSearch,
          ),

          const SizedBox(height: 16),

          if (!hasQuery && allRecent.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recently Searched',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _clearAllRecent,
                  tooltip: 'Clear all',
                ),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: visibleSearches.length +
                    ((allRecent.length > maxVisible && !_showAllRecent) ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final bool isMoreButton =
                      index == visibleSearches.length &&
                      allRecent.length > maxVisible &&
                      !_showAllRecent;

                  if (isMoreButton) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _showAllRecent = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.black26
                                : Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'More ▾',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }

                  final q = visibleSearches[index];

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.black26
                            : Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _runSearch(q),
                          child: Text(
                            q,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            context
                                .read<SearchHistoryProvider>()
                                .removeQuery(q);
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color:
                                isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
          ],

          // Contenu principal
          Expanded(
            child: Builder(
              builder: (context) {
                if (!hasQuery) {
                  return const SingleChildScrollView(
                    child: Column(
                      children: [
                        HistorySection(),
                        SizedBox(height: 20),
                        RecommendationSection(),
                        SizedBox(height: 20),
                      ],
                    ),
                  );
                }

                if (movieProvider.isLoading &&
                    movieProvider.results.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (movieProvider.errorMessage != null &&
                    movieProvider.results.isEmpty) {
                  return Center(child: Text(movieProvider.errorMessage!));
                }

                if (movieProvider.results.isEmpty) {
                  return const Center(
                    child: Text('Aucun résultat trouvé.'),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: pageItems.length,
                        itemBuilder: (context, index) {
                          final movie = pageItems[index];
                          return ListTile(
                            leading: movie.poster.isNotEmpty
                                ? Image.network(
                                    movie.poster,
                                    width: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return const Icon(Icons.movie);
                                    },
                                  )
                                : const Icon(Icons.movie),
                            title: Text(movie.title),
                            subtitle:
                                Text('${movie.year} • ${movie.type}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MovieDetailsPage(movie: movie),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (totalPages > 1)
                      PaginationBar(
                        currentPage: _currentPage,
                        totalPages: totalPages,
                        groupStart: _groupStart,
                        isDark: isDarkMode,
                        onPrevGroup: () => _onPrevGroup(totalPages),
                        onNextGroup: () => _onNextGroup(totalPages),
                        onPageSelected: _onPageSelected,
                      ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
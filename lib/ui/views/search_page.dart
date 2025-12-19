import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:cineflow/providers/movie_provider.dart';
import 'movie_details_page.dart';
import '../widgets/history_section.dart';
import '../widgets/recommendation_section.dart';

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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final query = value.trim();
    setState(() {});


    if (query.isEmpty) {
      context.read<MovieProvider>().clearSearch();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<MovieProvider>().search(query);
    });
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
          _controller.text = text;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
          _onSearchChanged(text);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          setState(() {});
        },
      ),
    IconButton(
      icon: Icon(
        _isListening ? Icons.mic : Icons.mic_none,
        color: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
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
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Builder(
              builder: (context) {
                if (movieProvider.isLoading && movieProvider.results.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (movieProvider.errorMessage != null &&
                    movieProvider.results.isEmpty) {
                  return Center(child: Text(movieProvider.errorMessage!));
                }

                if (movieProvider.results.isEmpty) {
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

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: movieProvider.results.length,
                        itemBuilder: (context, index) {
                          final movie = movieProvider.results[index];
                          return ListTile(
                            leading: movie.poster.isNotEmpty
                                ? Image.network(
                                    movie.poster,
                                    width: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.movie);
                                    },
                                  )
                                : const Icon(Icons.movie),
                            title: Text(movie.title),
                            subtitle: Text('${movie.year} • ${movie.type}'),
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
                    if (movieProvider.hasMore)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<MovieProvider>().loadMore();
                          },
                          child: movieProvider.isLoading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Voir plus'),
                        ),
                      ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/movie_provider.dart';
import '../widgets/pagination_bar.dart';
import 'movie_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadDefaultOnSearchOpen();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _resetToDefault() async {
    _controller.clear();
    await context.read<MovieProvider>().loadDefaultOnSearchOpen();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Rechercher un film...',
              prefixIcon: const Icon(Icons.search, color: Colors.red),
              suffixIcon: IconButton(
                tooltip: "Afficher tous (retour au début)",
                icon: const Icon(Icons.restart_alt, color: Colors.red),
                onPressed: _resetToDefault,
              ),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              context.read<MovieProvider>().searchMovies(value, page: 1);
            },
          ),

          const SizedBox(height: 20),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.movies.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Aucun résultat"),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.restart_alt),
                            label: const Text("Afficher tous"),
                            onPressed: _resetToDefault,
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: provider.movies.length,
                        itemBuilder: (context, index) {
                          final movie = provider.movies[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                movie.poster,
                                width: 50,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.movie),
                              ),
                            ),
                            title: Text(movie.title),
                            subtitle: Text('${movie.year} • ${movie.type}'),
                            onTap: () async {
                              await context
                                  .read<MovieProvider>()
                                  .addToHistory(movie);
                              if (!context.mounted) return;
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

          const SizedBox(height: 10),

          PaginationBar(
            currentPage: provider.currentPage,
            totalPages: provider.totalPages,
            windowSize: 10,
            onPageSelected: (p) => context.read<MovieProvider>().goToPage(p),
          ),
        ],
      ),
    );
  }
}

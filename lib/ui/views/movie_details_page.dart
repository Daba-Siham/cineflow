import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/providers/favorites_provider.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/models/movie_detail.dart';
import 'package:cineflow/data/models/cast_member.dart';
import 'package:cineflow/data/services/api_service.dart';

import 'package:cineflow/ui/widgets/movie_page_buttons.dart';
import 'package:cineflow/ui/widgets/recommendation_section.dart';
import '../widgets/cast_section.dart';
import 'package:cineflow/providers/auth_provider.dart';

class MovieDetailsPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailsPage({super.key, required this.movie});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final ApiService _apiService = ApiService();
  MovieDetail? _details;
  bool _isLoading = true;
  String? _errorMessage;

  bool isFavorite = false;

  // nouvelle liste pour le cast avec images
  List<CastMember> _cast = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFavoriteState();
    });
  }

  void _refreshFavoriteState() {
    final favProvider = context.read<FavoritesProvider>();
    setState(() {
      isFavorite = favProvider.isFavorite(widget.movie.imdbID);
    });
  }

  Future<void> _loadDetails() async {
    MovieDetail? data;
    List<CastMember> cast = [];

    try {
      final bool isSeries = widget.movie.type.toLowerCase() == 'series';

      // détails film ou série
      if (isSeries) {
        data = await _apiService.getTvDetail(widget.movie.imdbID);
      } else {
        data = await _apiService.getMovieDetail(widget.movie.imdbID);
      }

      // cast TMDb avec images
      if (data != null) {
        cast = await _apiService.getCast(
          widget.movie.imdbID,
          isTv: isSeries,
        );
      }

      if (!mounted) return;

      setState(() {
        _details = data;
        _cast = cast;
        if (data == null) {
          _errorMessage = 'Détails introuvables.';
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur lors du chargement des détails.';
        _isLoading = false;
      });
      return;
    }

    if (!mounted || data == null) return;

    final movieForHistory = Movie(
      imdbID: widget.movie.imdbID,
      title: widget.movie.title,
      year: widget.movie.year,
      poster: widget.movie.poster,
      type: widget.movie.type,
      genre: data.genre,
    );

    final auth = context.read<AuthProvider>();

    await context.read<MovieProvider>().addToHistory(
      movieForHistory,
      auth: auth,
    );
  }

  Future<void> _toggleFavorite() async {
    final auth = context.read<AuthProvider>();
    final favProvider = context.read<FavoritesProvider>();

    if (!auth.isLoggedIn) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Connexion requise"),
          content: const Text(
            "Tu dois te connecter ou créer un compte pour ajouter des favoris.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }


    if (isFavorite) {
    await favProvider.removeFavorite(
      widget.movie.imdbID,
      auth: auth,
    );

    if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Retiré des favoris")),
      );
    } else {
      await favProvider.addFavorite(
        {
          'id': widget.movie.imdbID,
          'title': widget.movie.title,
          'poster': widget.movie.poster,
          'year': widget.movie.year,
          'type': widget.movie.type,
        },
        auth: auth,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ajouté aux favoris")),
      );
    }

    if (!mounted) return;
    setState(() {
      isFavorite = !isFavorite;
    });
  }


  // affiche le poster en grand au centre
  void _showPosterFullScreen(String url) {
    if (url.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              child: AspectRatio(
                aspectRatio: 1 / 2,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_details == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Aucune donnée.')),
      );
    }

    final details = _details!;

    return Scaffold(
      body: Stack(
        children: [
          // image de fond
          Opacity(
            opacity: 0.4,
            child: details.poster.isNotEmpty
                ? Image.network(
                    details.poster,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 280,
                    width: double.infinity,
                    color: Colors.black,
                  ),
          ),
          SafeArea(
            child: Column(
              children: [
                // barre haute avec bouton retour
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          color: isDark ? Colors.white : Colors.black,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // poster (cliquable pour l'agrandissement)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _showPosterFullScreen(details.poster),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  229,
                                  191,
                                  188,
                                ).withValues(alpha: 0.5),
                                spreadRadius: 1,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: details.poster.isNotEmpty
                                ? Image.network(
                                    details.poster,
                                    height: 250,
                                    width: 180,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 250,
                                    width: 180,
                                    color: Colors.grey[800],
                                    child: Icon(
                                      Icons.movie,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                      size: 60,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // boutons (favori, etc.)
                MoviePageButtons(
                  isFavorite: isFavorite,
                  onToggleFavorite: _toggleFavorite,
                ),

                const SizedBox(height: 10),

                // zone scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // titre + année
                          Text(
                            '${details.title} (${details.year})',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // genre • runtime • rated
                          Text(
                            '${details.genre} • ${details.runtime} • ${details.rated}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[800],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // rating
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                details.imdbRating,
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // cast avec images TMDb
                          CastSection(cast: _cast),
                          const SizedBox(height: 10),

                          // description / synopsis
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Description',
                              style: TextStyle(
                                color:
                                    isDark ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            details.plot,
                            style: TextStyle(
                              color:
                                  isDark ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 20),

                          // recommandations
                          const RecommendationSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

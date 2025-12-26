import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/providers/favorites_provider.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/ui/views/movie_details_page.dart';
import 'button_carousel.dart';

class CarouselSliderHome extends StatefulWidget {
  const CarouselSliderHome({super.key});

  @override
  State<CarouselSliderHome> createState() => _CarouselSliderHomeState();
}

class _CarouselSliderHomeState extends State<CarouselSliderHome> {
  int _currentIndex = 0;
  late Future<List<Movie>> _futureTop;

  @override
  void initState() {
    super.initState();
    _futureTop =
        context.read<MovieProvider>().getTopRatedFromCatalog(limit: 5);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Movie>>(
      future: _futureTop,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 420,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) return const SizedBox.shrink();

        // film actuellement affiché
        final currentMovie = items[_currentIndex];

        return ClipRRect(
          child: SizedBox(
            width: double.infinity,
            height: 420,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // -------- CAROUSEL IMAGE --------
                CarouselSlider(
                  options: CarouselOptions(
                    height: 470,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged: (index, reason) {
                      setState(() => _currentIndex = index);
                    },
                  ),
                  items: items.map((movie) {
                    final hasPoster =
                        movie.poster.isNotEmpty && movie.poster != 'N/A';
                    return hasPoster
                        ? Image.network(
                            movie.poster,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.movie, size: 80),
                          )
                        : Container(
                            color: Colors.black,
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          );
                  }).toList(),
                ),

                // -------- GRADIENT EN BAS --------
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 160,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? const [
                                  Colors.transparent,
                                  Colors.black87,
                                  Colors.black,
                                ]
                              : const [
                                  Colors.transparent,
                                  Colors.white70,
                                  Colors.white,
                                ],
                        ),
                      ),
                    ),
                  ),
                ),

                // -------- BOUTONS + DOTS --------
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // BOUTON FAVORITE
                          ActionButton(
                            label: 'Favorite',
                            color: Colors.red,
                            icon: Icons.favorite,
                            onTap: () async {
                              final favProvider =
                                  context.read<FavoritesProvider>();

                              final alreadyFav = favProvider
                                  .isFavorite(currentMovie.imdbID);

                              if (alreadyFav) {
                                await favProvider
                                    .removeFavorite(currentMovie.imdbID);
                              } else {
                                await favProvider.addFavorite({
                                  'id': currentMovie.imdbID,
                                  'title': currentMovie.title,
                                  'poster': currentMovie.poster,
                                  'year': currentMovie.year,
                                  'type': currentMovie.type,
                                });
                              }

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    alreadyFav
                                        ? 'Retiré des favoris'
                                        : 'Ajouté aux favoris',
                                  ),
                                ),
                              );
                            },
                            isLeft: true,
                          ),
                          const SizedBox(width: 12),

                          // BOUTON DETAILS
                          ActionButton(
                            label: 'Details',
                            color: Colors.white,
                            textColor: Colors.black,
                            icon: Icons.info_outline_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MovieDetailsPage(movie: currentMovie),
                                ),
                              );
                            },
                            isLeft: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(items.length, (index) {
                          final isActive = index == _currentIndex;

                          if (isActive) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: 4,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            );
                          } else {
                            final Color dotColor = isDark
                                ? Colors.white
                                : Colors.black.withOpacity(0.7);

                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            );
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

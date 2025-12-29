import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/providers/favorites_provider.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/ui/views/movie_details_page.dart';

import 'button_carousel.dart';
import 'package:cineflow/providers/auth_provider.dart';

class CarouselSliderHome extends StatefulWidget {
  const CarouselSliderHome({super.key});

  @override
  State<CarouselSliderHome> createState() => CarouselSliderHomeState();
}

class CarouselSliderHomeState extends State<CarouselSliderHome> {
  int currentIndex = 0;
  late Future<List<Movie>> futureTop;

  @override
  void initState() {
    super.initState();
    futureTop =
        context.read<MovieProvider>().getTopRatedFromCatalog(limit: 5);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Movie>>(
      future: futureTop,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 420,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentMovie = items[currentIndex];

        return ClipRRect(
          child: SizedBox(
            width: double.infinity,
            height: 420,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 470,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged: (index, reason) {
                      setState(() => currentIndex = index);
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
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.movie, size: 80);
                            },
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
                          ActionButton(
                            label: 'Favorite',
                            color: Colors.red,
                            icon: Icons.favorite,
                            onTap: () async {
                              final auth = context.read<AuthProvider>();
                              final favProvider =
                                  context.read<FavoritesProvider>();
                              if (!auth.isLoggedIn) {
                                if (!mounted) return;
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Connexion requise"),
                                    content: const Text(
                                      "Connecte-toi ou crée un compte pour ajouter des favoris.",
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

                              final alreadyFav =
                                  favProvider.isFavorite(currentMovie.imdbID);

                              if (alreadyFav) {
                                await favProvider.removeFavorite(
                                  currentMovie.imdbID,
                                  auth: auth,
                                );
                              } else {
                                final movieMap = {
                                  'id': currentMovie.imdbID,
                                  'title': currentMovie.title,
                                  'poster': currentMovie.poster,
                                  'year': currentMovie.year,
                                  'type': currentMovie.type,
                                };
                                await favProvider.addFavorite(
                                  movieMap,
                                  auth: auth,
                                );
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
          
                          ActionButton(
                            label: 'Details',
                            color: Colors.white,
                            textColor: Colors.black,
                            icon: Icons.info_outlined,
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
                          final isActive = index == currentIndex;
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

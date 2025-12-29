import 'package:cineflow/ui/widgets/drawer_filtrage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/providers/filtrage_provider.dart';
import 'package:cineflow/ui/widgets/movie_card.dart';

import '../widgets/pagination_bar.dart';

class FiltragePage extends StatelessWidget {
  const FiltragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FiltrageProvider()..init(),
      child: const _FiltrageBody(),
    );
  }
}

class _FiltrageBody extends StatelessWidget {
  const _FiltrageBody();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FiltrageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6F6F6),
      drawer: const DrawerFiltrage(),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.tune, color: isDark ? Colors.white : Colors.black),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          Expanded(child: _buildResults(context)),

          if (p.totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PaginationBar(
                currentPage: p.currentPage,
                totalPages: p.totalPages,
                groupStart: p.groupStart,     
                isDark: isDark,
                onPrevGroup: () => context.read<FiltrageProvider>().prevGroup(),
                onNextGroup: () => context.read<FiltrageProvider>().nextGroup(),
                onPageSelected: (page) => context.read<FiltrageProvider>().goToPage(page),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final p = context.watch<FiltrageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (p.isLoading && p.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (p.errorMessage != null && p.results.isEmpty) {
      return Center(
        child: Text(
          p.errorMessage!,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
      );
    }

    if (p.results.isEmpty) {
      return Center(
        child: Text(
          "Aucun résultat.",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: p.results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemBuilder: (_, i) => MovieCard(movie: p.results[i]),
    );
  }
}
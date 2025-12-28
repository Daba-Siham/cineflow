import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/ui/widgets/movie_card.dart';
import 'package:cineflow/ui/widgets/empty_state.dart';
import 'package:cineflow/providers/auth_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final auth = context.read<AuthProvider>();
      await context.read<MovieProvider>().loadHistory(auth: auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<MovieProvider>().history;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
      ),
      body: history.isEmpty
          ? const Center(
              child: EmptyState(message: "Aucun film consulté pour le moment."),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: history.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  return MovieCard(movie: history[index]);
                },
              ),
            ),
    );
  }
}

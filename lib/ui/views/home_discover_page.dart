import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/movie_provider.dart';
import '../widgets/history_section.dart';
import '../widgets/recommendation_section.dart';
import '../widgets/home_filter_bar.dart';
import '../widgets/movie_list.dart';
import '../widgets/pagination_bar.dart';

class HomeDiscoverPage extends StatefulWidget {
  const HomeDiscoverPage({super.key});

  @override
  State<HomeDiscoverPage> createState() => _HomeDiscoverPageState();
}

class _HomeDiscoverPageState extends State<HomeDiscoverPage> {
  int _homePage = 1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<MovieProvider>().discoverOnHome(query: "star", page: _homePage);
     
      // ignore: use_build_context_synchronously
      await context.read<MovieProvider>().applyFilters(seedQuery: "star");
    });
  }

  Future<void> _goToHomePage(int p) async {
    setState(() => _homePage = p);
    await context.read<MovieProvider>().discoverOnHome(query: "star", page: _homePage);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeFilterBar(),
            const SizedBox(height: 18),

           
            const HistorySection(),
            const SizedBox(height: 20),

            
            const RecommendationSection(),
            const SizedBox(height: 20),

            
            SizedBox(
              height: 520,
              child: provider.isLoadingHome
                  ? const Center(child: CircularProgressIndicator())
                  : const MovieList(),
            ),

            const SizedBox(height: 10),

       
            PaginationBar(
              currentPage: _homePage,
              totalPages: 50,
              windowSize: 10,
              onPageSelected: _goToHomePage,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

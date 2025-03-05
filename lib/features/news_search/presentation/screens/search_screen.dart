// ignore_for_file: library_private_types_in_public_api

import 'package:animations/animations.dart';
import 'package:featuremind/features/news_search/presentation/providers/news_providers.dart';
import 'package:featuremind/features/news_search/presentation/screens/news_rersults_screen.dart';
import 'package:featuremind/features/news_search/presentation/widgets/search_history_widget.dart';
import 'package:featuremind/features/news_search/presentation/widgets/search_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch(String query) {
    // Clear previous search results
    ref.read(searchStateProvider.notifier).resetSearch();

    // Navigate to results screen with animation
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return NewsResultsScreen(initialQuery: query);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.scaled,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Explorer'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchInputWidget(
              controller: _searchController,
              onSearch: _performSearch,
            ),
            const SizedBox(height: 16),
            SearchHistoryWidget(
              onHistoryItemTap: (query) {
                _searchController.text = query;
                _performSearch(query);
              },
            ),
          ],
        ),
      ),
    );
  }
}

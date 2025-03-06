// ignore_for_file: library_private_types_in_public_api

import 'package:featuremind/core/error/failures.dart';
import 'package:featuremind/features/news_search/presentation/providers/news_providers.dart';
import 'package:featuremind/features/news_search/presentation/screens/news_rersults_screen.dart';
import 'package:featuremind/features/news_search/presentation/widgets/error_display_widget.dart';
import 'package:featuremind/features/news_search/presentation/widgets/search_history_widget.dart';
import 'package:featuremind/features/news_search/presentation/widgets/search_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _errorMessage;
  bool _isNetworkError = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search term')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    // Check for network connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'Please check your internet connection and try again';
        _isNetworkError = true;
      });
      return;
    }

    // Reset search state
    ref.read(searchStateProvider.notifier).resetSearch();

    // Perform search
    final searchNotifier = ref.read(searchStateProvider.notifier);
    final result = await searchNotifier.searchNews(query);

    setState(() {
      _isSearching = false;
    });

    // Check for success and navigate only if successful
    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
          _isNetworkError = failure is NetworkFailure;
        });
      },
      (articles) {
        if (articles.isNotEmpty) {
          // Only navigate on success
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
        } else {
          setState(() {
            _errorMessage = 'No results found for "$query"';
            _isNetworkError = false;
          });
        }
      },
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
              isLoading: _isSearching,
            ),
            const SizedBox(height: 16),

            // Error message if any
            if (_errorMessage != null)
              ErrorDisplayWidget(
                message: _errorMessage!,
                isNetworkError: _isNetworkError,
                onRetry: () => _performSearch(_searchController.text),
              ),

            // Show search history when not in error state
            if (_errorMessage == null)
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

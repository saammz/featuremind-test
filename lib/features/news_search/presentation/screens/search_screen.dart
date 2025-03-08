// ignore_for_file: library_private_types_in_public_api

import 'package:featuremind/core/error/failures.dart';
import 'package:featuremind/features/news_search/presentation/providers/news_providers.dart';
import 'package:featuremind/features/news_search/presentation/screens/news_results_screen.dart';
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

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _errorMessage;
  bool _isNetworkError = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a search term'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.onSurface,
        foregroundColor: colorScheme.onPrimary,
        title: Text(
          'News Explorer',
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Text(
                  'Discover the latest news',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter a topic to start exploring',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Search box with animation
                SearchInputWidget(
                  controller: _searchController,
                  onSearch: _performSearch,
                  isLoading: _isSearching,
                ),
                const SizedBox(height: 24),

                // Error message if any
                if (_errorMessage != null)
                  ErrorDisplayWidget(
                    message: _errorMessage!,
                    isNetworkError: _isNetworkError,
                    onRetry: () => _performSearch(_searchController.text),
                  ),

                // Search history section
                if (_errorMessage == null) ...[
                  const SizedBox(height: 12),

                  // History items
                  Expanded(
                    child: SearchHistoryWidget(
                      onHistoryItemTap: (query) {
                        _searchController.text = query;
                        _performSearch(query);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

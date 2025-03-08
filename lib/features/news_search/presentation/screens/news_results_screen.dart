// ignore_for_file: library_private_types_in_public_api

import 'package:featuremind/features/news_search/presentation/providers/news_providers.dart';
import 'package:featuremind/features/news_search/presentation/widgets/error_display_widget.dart';
import 'package:featuremind/features/news_search/presentation/widgets/loading_indicator_widget.dart';
import 'package:featuremind/features/news_search/presentation/widgets/news_article_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewsResultsScreen extends ConsumerStatefulWidget {
  final String initialQuery;

  const NewsResultsScreen({super.key, required this.initialQuery});

  @override
  _NewsResultsScreenState createState() => _NewsResultsScreenState();
}

class _NewsResultsScreenState extends ConsumerState<NewsResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    // Perform initial search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchStateProvider.notifier).searchNews(widget.initialQuery, isNewSearch: true);
    });

    // Setup scroll pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_isLoadingMore && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    setState(() {
      _isLoadingMore = true;
    });

    await ref.read(searchStateProvider.notifier).searchNews(widget.initialQuery);

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _retrySearch() async {
    await ref.read(searchStateProvider.notifier).searchNews(widget.initialQuery, isNewSearch: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchStateProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: colorScheme.onSurface,
        foregroundColor: colorScheme.onPrimary,
        title: Text(
          'Results for "${widget.initialQuery}"',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Builder(
        builder: (context) {
          // Handle initial loading state
          if (searchState.isLoading && searchState.articles.isEmpty) {
            return const Center(child: CustomLoadingIndicator());
          }

          // Handle error state
          if (searchState.error != null && searchState.articles.isEmpty) {
            return ErrorDisplayWidget(
              message: searchState.error!,
              isNetworkError: searchState.error!.toLowerCase().contains('network'),
              onRetry: _retrySearch,
            );
          }

          // Handle empty results state
          if (searchState.articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: colorScheme.tertiary.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "${widget.initialQuery}"',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Back to Search'),
                  ),
                ],
              ),
            );
          }

          // Display results with pagination
          return RefreshIndicator(
            color: colorScheme.primary,
            backgroundColor: colorScheme.surface,
            onRefresh: () async {
              await ref.read(searchStateProvider.notifier).searchNews(widget.initialQuery, isNewSearch: true);
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: searchState.articles.length + (searchState.isLoading || (!searchState.hasReachedEnd && searchState.articles.isNotEmpty) ? 1 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom when loading more
                if (index == searchState.articles.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CustomLoadingIndicator()),
                  );
                }

                final article = searchState.articles[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Hero(
                    tag: 'article_${article.url}',
                    child: NewsArticleCard(article: article),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

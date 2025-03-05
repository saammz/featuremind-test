// ignore_for_file: library_private_types_in_public_api

import 'package:featuremind/features/news_search/presentation/providers/news_providers.dart';
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

  @override
  void initState() {
    super.initState();

    // Perform initial search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchStateProvider.notifier).searchNews(widget.initialQuery);
    });

    // Setup scroll pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final searchState = ref.read(searchStateProvider);
      if (!searchState.isLoading) {
        ref.read(searchStateProvider.notifier).searchNews(widget.initialQuery);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.initialQuery}"'),
      ),
      body: searchState.isLoading && searchState.articles.isEmpty
          ? const Center(child: CustomLoadingIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: searchState.articles.length + (searchState.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == searchState.articles.length) {
                  return const CustomLoadingIndicator();
                }

                final article = searchState.articles[index];
                return NewsArticleCard(article: article);
              },
            ),
    );
  }
}

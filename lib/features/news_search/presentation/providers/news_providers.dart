import 'package:dartz/dartz.dart';
import 'package:featuremind/core/error/failures.dart';
import 'package:featuremind/features/news_search/data/datasources/news_local_datasource.dart';
import 'package:featuremind/features/news_search/data/datasources/news_remote_datasource.dart';
import 'package:featuremind/features/news_search/data/repositories/news_repository_impl.dart';
import 'package:featuremind/features/news_search/domain/entities/news_article.dart';
import 'package:featuremind/features/news_search/domain/repositories/news_repository.dart';
import 'package:featuremind/features/news_search/domain/usecases/get_search_history_usecase.dart';
import 'package:featuremind/features/news_search/domain/usecases/search_news_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Dependency Injection Providers
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://newsapi.org/v2',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized before use');
});

// Data Sources Providers
final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((ref) {
  return NewsRemoteDataSource(ref.read(dioProvider));
});

final newsLocalDataSourceProvider = Provider<NewsLocalDataSource>((ref) {
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  return NewsLocalDataSource(sharedPreferences);
});

// Repository Provider
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    remoteDataSource: ref.read(newsRemoteDataSourceProvider),
    localDataSource: ref.read(newsLocalDataSourceProvider),
  );
});

// Use Case Providers
final searchNewsUseCaseProvider = Provider<SearchNewsUseCase>((ref) {
  return SearchNewsUseCase(ref.read(newsRepositoryProvider));
});

final getSearchHistoryUseCaseProvider = Provider<GetSearchHistoryUseCase>((ref) {
  return GetSearchHistoryUseCase(ref.read(newsRepositoryProvider));
});

// State Providers for Search and Pagination
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchStateProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(
    searchNewsUseCase: ref.read(searchNewsUseCaseProvider),
  );
});

// Search State Management
class SearchState {
  final List<NewsArticle> articles;
  final bool isLoading;
  final String? error;
  final int currentPage;

  SearchState({
    this.articles = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
  });

  SearchState copyWith({
    List<NewsArticle>? articles,
    bool? isLoading,
    String? error,
    int? currentPage,
  }) {
    return SearchState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// In features/news_search/presentation/providers/news_providers.dart

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchNewsUseCase searchNewsUseCase;

  SearchNotifier({required this.searchNewsUseCase}) : super(SearchState());

  Future<Either<Failure, List<NewsArticle>>> searchNews(String query) async {
    // Prevent duplicate searches
    if (state.isLoading) return Right([]);

    state = state.copyWith(isLoading: true, error: null);

    final result = await searchNewsUseCase(SearchNewsParams(query: query, page: state.currentPage));

    result.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (articles) => state = state.copyWith(
            isLoading: false,
            articles: [
              ...state.articles,
              ...articles
            ],
            currentPage: state.currentPage + 1));

    // Return the result to allow the caller to handle navigation
    return result;
  }

  void resetSearch() {
    state = SearchState();
  }
}

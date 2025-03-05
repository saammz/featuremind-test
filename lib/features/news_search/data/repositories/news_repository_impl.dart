// features/news_search/data/repositories/news_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:featuremind/core/error/failures.dart';
import 'package:featuremind/features/news_search/data/datasources/news_local_datasource.dart';
import 'package:featuremind/features/news_search/data/datasources/news_remote_datasource.dart';
import 'package:featuremind/features/news_search/domain/entities/news_article.dart';
import 'package:featuremind/features/news_search/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<NewsArticle>>> searchNews({
    required String query,
    int page = 1,
  }) async {
    try {
      // Save search query to local history
      await localDataSource.saveSearchQuery(query);

      // Fetch news from remote source
      final articles = await remoteDataSource.searchNews(
        query: query,
        page: page,
      );

      return Right(articles);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSearchHistory() async {
    try {
      final history = await localDataSource.getSearchHistory();
      return Right(history);
    } catch (e) {
      return Left(CacheFailure('Could not retrieve search history'));
    }
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    await localDataSource.saveSearchQuery(query);
  }
}

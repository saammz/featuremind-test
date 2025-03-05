import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/news_article.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<NewsArticle>>> searchNews({
    required String query,
    int page = 1,
  });

  Future<Either<Failure, List<String>>> getSearchHistory();
  Future<void> saveSearchQuery(String query);
}

// features/news_search/domain/usecases/search_news_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:featuremind/core/error/failures.dart';
import 'package:featuremind/core/usecases/usecases.dart';
import 'package:featuremind/features/news_search/domain/entities/news_article.dart';
import 'package:featuremind/features/news_search/domain/repositories/news_repository.dart';

class SearchNewsUseCase implements UseCase<List<NewsArticle>, SearchNewsParams> {
  final NewsRepository repository;

  SearchNewsUseCase(this.repository);

  @override
  Future<Either<Failure, List<NewsArticle>>> call(SearchNewsParams params) async {
    return await repository.searchNews(
      query: params.query,
      page: params.page,
    );
  }
}

class SearchNewsParams extends Equatable {
  final String query;
  final int page;
  final int pageSize;

  const SearchNewsParams({
    required this.query,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object> get props => [
        query,
        page,
        pageSize
      ];
}

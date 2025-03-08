import 'package:dartz/dartz.dart';
import 'package:featuremind/core/error/failures.dart';
import 'package:featuremind/core/usecases/usecases.dart';
import 'package:featuremind/features/news_search/domain/repositories/news_repository.dart';

class GetSearchHistoryUseCase implements UseCase<List<String>, NoParams> {
  final NewsRepository repository;

  GetSearchHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getSearchHistory();
  }
}

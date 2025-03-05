import 'package:dio/dio.dart';
import '../models/news_article_model.dart';

// Custom exception class
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ServerException: $message (Status Code: $statusCode)';
  }
}

class NewsRemoteDataSource {
  final Dio dio;

  NewsRemoteDataSource(this.dio);

  Future<List<NewsArticleModel>> searchNews({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await dio.get('/everything', queryParameters: {
        'q': query,
        'page': page,
        'apiKey': 'cd2c4764345442dc8ddec6ebb161e803',
        'pageSize': 10
      });

      // Check if response is successful
      if (response.statusCode == 200) {
        final articles = (response.data['articles'] as List).map((article) => NewsArticleModel.fromJson(article)).toList();

        return articles;
      } else {
        throw ServerException(message: response.data['message'] ?? 'Unknown error occurred', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? 'Network error occurred', statusCode: e.response?.statusCode);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: null);
    }
  }
}

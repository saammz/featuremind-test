import 'package:featuremind/features/news_search/domain/entities/news_article.dart';

class NewsArticleModel extends NewsArticle {
  const NewsArticleModel({
    required super.title,
    required super.description,
    required super.url,
    super.urlToImage,
    required super.publishedAt,
  });

  // Factory constructor to create from JSON
  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      title: json['title'] ?? 'Untitled Article',
      description: json['description'] ?? 'No description available',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
    };
  }
}

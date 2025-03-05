import 'package:equatable/equatable.dart';

class NewsArticle extends Equatable {
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String publishedAt;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
  });

  @override
  List<Object?> get props => [
        title,
        url
      ];
}

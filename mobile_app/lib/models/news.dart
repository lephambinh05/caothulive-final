import 'package:flutter/material.dart';

class News {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String url;
  final String imageUrl;
  final String source;
  final String author;
  final DateTime publishedAt;
  final List<String> categories;
  final String language;
  final String country;
  final int sentiment;
  final double relevanceScore;

  News({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.author,
    required this.publishedAt,
    required this.categories,
    required this.language,
    required this.country,
    required this.sentiment,
    required this.relevanceScore,
  });

  // Tạo từ API response
  factory News.fromApiResponse(Map<String, dynamic> data) {
    return News(
      id: data['id']?.toString() ?? '',
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      content: data['text'] ?? '',
      url: data['url'] ?? '',
      imageUrl: data['image'] ?? '',
      source: data['source_country'] ?? 'VN',
      author: data['author'] ?? '',
      publishedAt: data['publish_date'] != null 
          ? DateTime.tryParse(data['publish_date']) ?? DateTime.now()
          : DateTime.now(),
      categories: data['categories'] != null 
          ? List<String>.from(data['categories'])
          : [],
      language: data['language'] ?? 'vi',
      country: data['source_country'] ?? 'VN',
      sentiment: (data['sentiment'] ?? 0).toInt(),
      relevanceScore: (data['relevance_score'] ?? 0.0).toDouble(),
    );
  }

  // Tạo từ Map
  factory News.fromMap(Map<String, dynamic> data) {
    return News(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      content: data['content'] ?? '',
      url: data['url'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      source: data['source'] ?? '',
      author: data['author'] ?? '',
      publishedAt: data['publishedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['publishedAt'])
          : DateTime.now(),
      categories: data['categories'] != null 
          ? List<String>.from(data['categories'])
          : [],
      language: data['language'] ?? 'vi',
      country: data['country'] ?? 'VN',
      sentiment: (data['sentiment'] ?? 0).toInt(),
      relevanceScore: (data['relevanceScore'] ?? 0.0).toDouble(),
    );
  }

  // Chuyển thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'source': source,
      'author': author,
      'publishedAt': publishedAt.millisecondsSinceEpoch,
      'categories': categories,
      'language': language,
      'country': country,
      'sentiment': sentiment,
      'relevanceScore': relevanceScore,
    };
  }

  // Lấy thời gian đăng bài (relative)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  // Lấy màu sắc cho sentiment
  Color get sentimentColor {
    switch (sentiment) {
      case 1:
        return Colors.green; // Positive
      case -1:
        return Colors.red; // Negative
      default:
        return Colors.grey; // Neutral
    }
  }

  // Lấy icon cho sentiment
  IconData get sentimentIcon {
    switch (sentiment) {
      case 1:
        return Icons.sentiment_very_satisfied;
      case -1:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  // Lấy màu sắc cho category
  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'politics':
        return Colors.blue;
      case 'business':
        return Colors.green;
      case 'technology':
        return Colors.purple;
      case 'sports':
        return Colors.orange;
      case 'entertainment':
        return Colors.pink;
      case 'health':
        return Colors.teal;
      case 'science':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  @override
  String toString() {
    return 'News(id: $id, title: $title, source: $source, publishedAt: $publishedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is News && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

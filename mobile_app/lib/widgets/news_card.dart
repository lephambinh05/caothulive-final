import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news.dart';
import '../services/news_service.dart';
import '../theme/caothulive_theme.dart';
import '../screens/news_detail_screen.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.news,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () => _openNewsDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 200,
                width: double.infinity,
                color: CaoThuLiveTheme.primaryRed.withOpacity(0.1),
                child: news.imageUrl.isNotEmpty
                    ? Image.network(
                        news.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: CaoThuLiveTheme.primaryRed,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: CaoThuLiveTheme.primaryRed.withOpacity(0.1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: CaoThuLiveTheme.primaryRed,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Không thể tải ảnh',
                                  style: TextStyle(
                                    color: CaoThuLiveTheme.primaryRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.article,
                            size: 48,
                            color: CaoThuLiveTheme.primaryRed,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tin tức',
                            style: TextStyle(
                              color: CaoThuLiveTheme.primaryRed,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source and time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CaoThuLiveTheme.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          news.source,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        news.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      // Sentiment icon
                      Icon(
                        news.sentimentIcon,
                        size: 16,
                        color: news.sentimentColor,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    news.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Summary
                  if (news.summary.isNotEmpty)
                    Text(
                      news.summary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Categories
                  if (news.categories.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: news.categories.take(3).map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: news.getCategoryColor(category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: news.getCategoryColor(category).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            NewsService.getCategoryName(category),
                            style: TextStyle(
                              color: news.getCategoryColor(category),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Footer
                  Row(
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Đọc thêm',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CaoThuLiveTheme.primaryRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      // Relevance score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: CaoThuLiveTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(news.relevanceScore * 100).toInt()}%',
                          style: const TextStyle(
                            color: CaoThuLiveTheme.primaryRed,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openNewsDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(news: news),
      ),
    );
  }

  Future<void> _openNewsUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening news URL: $e');
    }
  }
}

class NewsCardCompact extends StatelessWidget {
  final News news;
  final VoidCallback? onTap;

  const NewsCardCompact({
    super.key,
    required this.news,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap ?? () => _openNewsUrl(news.url),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              if (news.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    news.imageUrl,
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 60,
                        color: CaoThuLiveTheme.primaryRed.withOpacity(0.1),
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 24,
                          color: CaoThuLiveTheme.primaryRed,
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CaoThuLiveTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.article,
                    size: 24,
                    color: CaoThuLiveTheme.primaryRed,
                  ),
                ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source and time
                    Row(
                      children: [
                        Text(
                          news.source,
                          style: TextStyle(
                            color: CaoThuLiveTheme.primaryRed,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          news.timeAgo,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Icon(
                          news.sentimentIcon,
                          size: 14,
                          color: news.sentimentColor,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Title
                    Text(
                      news.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNewsUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening news URL: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news.dart';
import '../services/news_service.dart';
import '../theme/caothulive_theme.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;

  const NewsDetailScreen({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar với ảnh
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: CaoThuLiveTheme.primaryRed,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh nền
                  news.imageUrl.isNotEmpty
                      ? Image.network(
                          news.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: CaoThuLiveTheme.primaryRed.withOpacity(0.1),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                  color: CaoThuLiveTheme.primaryRed,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: CaoThuLiveTheme.headerGradient,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.article,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Nội dung overlay
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source và time
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
                              color: Colors.white.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              news.timeAgo,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              news.sentimentIcon,
                              size: 16,
                              color: news.sentimentColor,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Title
                        Text(
                          news.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () => _shareNews(),
                icon: const Icon(Icons.share, color: Colors.white),
              ),
              IconButton(
                onPressed: () => _openOriginalUrl(),
                icon: const Icon(Icons.open_in_new, color: Colors.white),
              ),
            ],
          ),
          
          // Nội dung bài viết
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  if (news.categories.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: news.categories.map((category) {
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
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Summary
                  if (news.summary.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CaoThuLiveTheme.primaryRed.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CaoThuLiveTheme.primaryRed.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.summarize,
                                size: 16,
                                color: CaoThuLiveTheme.primaryRed,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tóm tắt',
                                style: TextStyle(
                                  color: CaoThuLiveTheme.primaryRed,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            news.summary,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Content
                  if (news.content.isNotEmpty) ...[
                    Text(
                      'Nội dung',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: CaoThuLiveTheme.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Author info
                  if (news.author.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: CaoThuLiveTheme.primaryRed.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              color: CaoThuLiveTheme.primaryRed,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tác giả',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  news.author,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.trending_up,
                          'Độ liên quan',
                          '${(news.relevanceScore * 100).toInt()}%',
                          Colors.blue,
                        ),
                        _buildStatItem(
                          news.sentimentIcon,
                          'Cảm xúc',
                          news.sentiment == 1 ? 'Tích cực' : 
                          news.sentiment == -1 ? 'Tiêu cực' : 'Trung tính',
                          news.sentimentColor,
                        ),
                        _buildStatItem(
                          Icons.language,
                          'Ngôn ngữ',
                          news.language.toUpperCase(),
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openOriginalUrl(),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Đọc bài gốc'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CaoThuLiveTheme.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareNews(),
                          icon: const Icon(Icons.share),
                          label: const Text('Chia sẻ'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CaoThuLiveTheme.primaryRed,
                            side: const BorderSide(color: CaoThuLiveTheme.primaryRed),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _openOriginalUrl() async {
    try {
      final uri = Uri.parse(news.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening news URL: $e');
    }
  }

  void _shareNews() {
    // TODO: Implement share functionality
    debugPrint('Sharing news: ${news.title}');
  }
}

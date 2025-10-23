import 'package:flutter/material.dart';
import '../theme/caothulive_theme.dart';
import '../models/news.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<News> newsList = [];
  bool isLoading = true;
  String searchQuery = '';
  Map<String, dynamic> quotaInfo = {};

  @override
  void initState() {
    super.initState();
    _loadQuotaInfo();
    _loadNews();
  }

  Future<void> _loadQuotaInfo() async {
    final info = await NewsService.getQuotaInfo();
    setState(() {
      quotaInfo = info;
    });
  }

  Future<void> _loadNews() async {
    setState(() {
      isLoading = true;
    });

    try {
      final news = await NewsService.getTodayBreakingNews();

      setState(() {
        newsList = news;
        isLoading = false;
      });
      
      // Cập nhật quota info sau khi load news
      _loadQuotaInfo();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading news: $e');
    }
  }

  Future<void> _searchNews(String query) async {
    if (query.isEmpty) {
      _loadNews();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final news = await NewsService.searchNews(query: query);
      setState(() {
        newsList = news;
        isLoading = false;
      });
      
      // Cập nhật quota info sau khi search
      _loadQuotaInfo();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error searching news: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: CaoThuLiveTheme.primaryRed,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Tin tức',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: CaoThuLiveTheme.headerGradient,
                ),
              ),
            ),
            actions: [
              // Quota info
              GestureDetector(
                onTap: () => _showQuotaDialog(),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'RQ: ${quotaInfo['used'] ?? 0}/${quotaInfo['total'] ?? 50}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Còn: ${quotaInfo['remaining'] ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _showSearchDialog();
                },
                icon: const Icon(Icons.search, color: Colors.white),
              ),
            ],
          ),
          
          
          // News List
          if (isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    color: CaoThuLiveTheme.primaryRed,
                  ),
                ),
              ),
            )
          else if (newsList.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyState(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return NewsCard(news: newsList[index]);
                },
                childCount: newsList.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có tin tức nào',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thử chọn danh mục khác hoặc tìm kiếm',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CaoThuLiveTheme.primaryRed,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuotaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin API Quota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuotaInfoRow('Đã sử dụng:', '${quotaInfo['used'] ?? 0} requests'),
            _buildQuotaInfoRow('Còn lại:', '${quotaInfo['remaining'] ?? 0} requests'),
            _buildQuotaInfoRow('Tổng quota:', '${quotaInfo['total'] ?? 50} requests/ngày'),
            _buildQuotaInfoRow('Ngày:', '${quotaInfo['date'] ?? 'N/A'}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 Mỗi lần tải tin tức, tìm kiếm hoặc chọn danh mục sẽ sử dụng 1 request. Quota sẽ tự động reset vào ngày mới.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: CaoThuLiveTheme.primaryRed,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tìm kiếm tin tức'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Nhập từ khóa tìm kiếm...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            _searchNews(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final textField = context.findAncestorWidgetOfExactType<TextField>();
              if (textField != null) {
                _searchNews(textField.controller?.text ?? '');
              }
              Navigator.pop(context);
            },
            child: const Text('Tìm kiếm'),
          ),
        ],
      ),
    );
  }
}

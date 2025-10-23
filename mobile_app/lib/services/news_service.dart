import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news.dart';
import '../config.dart';
import 'news_cache_service.dart';

class NewsService {
  static const String _baseUrl = 'https://api.worldnewsapi.com';
  static const String _apiKey = '16a5ce8db21c490fa99d95a63d3cbb74'; // Cần thay bằng API key thật
  static const int _dailyQuota = 50; // 50 requests per day
  static const String _quotaKey = 'news_api_quota';
  static const String _quotaDateKey = 'news_api_quota_date';
  
  // Kiểm tra và quản lý API quota
  static Future<bool> _checkQuota() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
      final lastDate = prefs.getString(_quotaDateKey) ?? '';
      final usedQuota = prefs.getInt(_quotaKey) ?? 0;
      
      // Reset quota nếu là ngày mới
      if (lastDate != today) {
        await prefs.setString(_quotaDateKey, today);
        await prefs.setInt(_quotaKey, 0);
        return true;
      }
      
      // Kiểm tra quota còn lại
      return usedQuota < _dailyQuota;
    } catch (e) {
      debugPrint('Error checking quota: $e');
      return false; // An toàn: không cho phép request nếu không kiểm tra được quota
    }
  }
  
  // Tăng quota đã sử dụng
  static Future<void> _incrementQuota() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentQuota = prefs.getInt(_quotaKey) ?? 0;
      await prefs.setInt(_quotaKey, currentQuota + 1);
    } catch (e) {
      debugPrint('Error incrementing quota: $e');
    }
  }
  
  // Lấy thông tin quota hiện tại
  static Future<Map<String, dynamic>> getQuotaInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString(_quotaDateKey) ?? '';
      final usedQuota = prefs.getInt(_quotaKey) ?? 0;
      
      return {
        'used': lastDate == today ? usedQuota : 0,
        'total': _dailyQuota,
        'remaining': lastDate == today ? (_dailyQuota - usedQuota) : _dailyQuota,
        'date': today,
        'isNewDay': lastDate != today,
      };
    } catch (e) {
      debugPrint('Error getting quota info: $e');
      return {
        'used': 0,
        'total': _dailyQuota,
        'remaining': _dailyQuota,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'isNewDay': false,
      };
    }
  }
  
  // Lấy tin tức nổi bật hôm nay từ Vietnam
  static Future<List<News>> getTodayBreakingNews() async {
    // Kiểm tra quota trước khi gọi API
    if (!await _checkQuota()) {
      print('API quota exceeded. Using mock data.');
      return _getMockNews();
    }
    
    try {
      final url = Uri.parse('$_baseUrl/top-news?api-key=$_apiKey&source-country=vn&language=vi');
      final response = await http.get(url);
      
      // Tăng quota sau khi gọi API thành công
      await _incrementQuota();
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data'); // Debug log
        
        // Kiểm tra xem có field 'news' không
        if (data['news'] != null && data['news'] is List) {
          final newsList = data['news'] as List<dynamic>;
          final news = newsList.map((item) => News.fromApiResponse(item)).toList();
          
          // Cache tin tức vào Firebase
          await NewsCacheService.cacheNews(news);
          
          print('Fetched ${news.length} real news articles from API');
          return news;
        } else {
          print('No news data in API response, using mock data');
          return _getMockNews();
        }
      } else {
        print('Error fetching breaking news: ${response.statusCode}');
        // Thử lấy từ cache khi API lỗi
        final cachedNews = await NewsCacheService.getCachedNews();
        return cachedNews.isNotEmpty ? cachedNews : _getMockNews();
      }
    } catch (e) {
      print('Exception fetching breaking news: $e');
      // Thử lấy từ cache khi có lỗi
      final cachedNews = await NewsCacheService.getCachedNews();
      return cachedNews.isNotEmpty ? cachedNews : _getMockNews();
    }
  }

  // Tìm kiếm tin tức từ Vietnam
  static Future<List<News>> searchNews({
    String? query,
    List<String>? categories,
    int? days = 7,
  }) async {
    // Kiểm tra quota trước khi gọi API
    if (!await _checkQuota()) {
      print('API quota exceeded. Using mock data.');
      return _getMockNews();
    }
    
    try {
      String url = '$_baseUrl/search-news?api-key=$_apiKey&source-country=vn&language=vi';
      
      if (query != null && query.isNotEmpty) {
        url += '&text=$query';
      }
      
      if (categories != null && categories.isNotEmpty) {
        url += '&categories=${categories.join(',')}';
      }
      
      if (days != null) {
        final date = DateTime.now().subtract(Duration(days: days));
        url += '&earliest-publish-date=${date.toIso8601String().split('T')[0]}';
      }
      
      final response = await http.get(Uri.parse(url));
      
      // Tăng quota sau khi gọi API thành công
      await _incrementQuota();
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newsList = data['news'] as List<dynamic>;
        final news = newsList.map((item) => News.fromApiResponse(item)).toList();
        
        // Cache tin tức vào Firebase
        await NewsCacheService.cacheNews(news);
        
        print('Fetched ${news.length} real news articles from search API');
        return news;
      } else {
        print('Error searching news: ${response.statusCode}');
        // Thử lấy từ cache khi API lỗi
        final cachedNews = await NewsCacheService.getCachedNews();
        return cachedNews.isNotEmpty ? cachedNews : _getMockNews();
      }
    } catch (e) {
      print('Exception searching news: $e');
      // Thử lấy từ cache khi có lỗi
      final cachedNews = await NewsCacheService.getCachedNews();
      return cachedNews.isNotEmpty ? cachedNews : _getMockNews();
    }
  }

  // Lấy tin tức theo category
  static Future<List<News>> getNewsByCategory(String category) async {
    return searchNews(categories: [category]);
  }

  // Lấy tin tức chính trị
  static Future<List<News>> getPoliticsNews() async {
    return getNewsByCategory('politics');
  }

  // Lấy tin tức kinh tế
  static Future<List<News>> getBusinessNews() async {
    return getNewsByCategory('business');
  }

  // Lấy tin tức công nghệ
  static Future<List<News>> getTechnologyNews() async {
    return getNewsByCategory('technology');
  }

  // Lấy tin tức thể thao
  static Future<List<News>> getSportsNews() async {
    return getNewsByCategory('sports');
  }

  // Lấy tin tức giải trí
  static Future<List<News>> getEntertainmentNews() async {
    return getNewsByCategory('entertainment');
  }

  // Lấy tin tức sức khỏe
  static Future<List<News>> getHealthNews() async {
    return getNewsByCategory('health');
  }

  // Lấy tin tức khoa học
  static Future<List<News>> getScienceNews() async {
    return getNewsByCategory('science');
  }

  // Mock data khi API không hoạt động
  static List<News> _getMockNews() {
    return [
      News(
        id: '1',
        title: 'Việt Nam đạt thành tựu lớn trong phát triển kinh tế số',
        summary: 'Nền kinh tế số Việt Nam đang phát triển mạnh mẽ với nhiều thành tựu đáng kể trong năm 2024.',
        content: 'Việt Nam đã đạt được những thành tựu đáng kể trong việc phát triển nền kinh tế số. Với sự đầu tư mạnh mẽ vào công nghệ và đổi mới sáng tạo, đất nước đang trên đà trở thành một trong những quốc gia dẫn đầu về chuyển đổi số trong khu vực Đông Nam Á.',
        url: 'https://example.com/news/1',
        imageUrl: 'https://picsum.photos/400/200?random=1',
        source: 'VnExpress',
        author: 'Phóng viên VnExpress',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        categories: ['business', 'technology'],
        language: 'vi',
        country: 'VN',
        sentiment: 1,
        relevanceScore: 0.95,
      ),
      News(
        id: '2',
        title: 'Thành phố Hồ Chí Minh triển khai hệ thống giao thông thông minh',
        summary: 'TP.HCM đang triển khai hệ thống giao thông thông minh để giảm ùn tắc và nâng cao hiệu quả vận tải.',
        content: 'Thành phố Hồ Chí Minh đã bắt đầu triển khai hệ thống giao thông thông minh với các công nghệ tiên tiến như AI, IoT và big data. Hệ thống này sẽ giúp giảm thiểu tình trạng ùn tắc giao thông và nâng cao hiệu quả vận tải công cộng.',
        url: 'https://example.com/news/2',
        imageUrl: 'https://picsum.photos/400/200?random=2',
        source: 'Tuổi Trẻ',
        author: 'Phóng viên Tuổi Trẻ',
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
        categories: ['technology', 'politics'],
        language: 'vi',
        country: 'VN',
        sentiment: 1,
        relevanceScore: 0.88,
      ),
      News(
        id: '3',
        title: 'Việt Nam tham gia cuộc thi Olympic Toán học quốc tế',
        summary: 'Đoàn học sinh Việt Nam tham gia cuộc thi Olympic Toán học quốc tế với hy vọng đạt được thành tích cao.',
        content: 'Đoàn học sinh Việt Nam đã lên đường tham gia cuộc thi Olympic Toán học quốc tế năm 2024. Với sự chuẩn bị kỹ lưỡng và tinh thần quyết tâm cao, các em học sinh hy vọng sẽ đạt được những thành tích xuất sắc và mang vinh quang về cho đất nước.',
        url: 'https://example.com/news/3',
        imageUrl: 'https://picsum.photos/400/200?random=3',
        source: 'Dân Trí',
        author: 'Phóng viên Dân Trí',
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        categories: ['education', 'sports'],
        language: 'vi',
        country: 'VN',
        sentiment: 1,
        relevanceScore: 0.82,
      ),
      News(
        id: '4',
        title: 'Khởi công dự án nhà máy điện mặt trời lớn nhất miền Nam',
        summary: 'Dự án nhà máy điện mặt trời với công suất 500MW đã được khởi công tại tỉnh Ninh Thuận.',
        content: 'Dự án nhà máy điện mặt trời lớn nhất miền Nam với công suất 500MW đã chính thức được khởi công tại tỉnh Ninh Thuận. Dự án này sẽ góp phần quan trọng vào việc phát triển năng lượng tái tạo và giảm phát thải khí nhà kính của Việt Nam.',
        url: 'https://example.com/news/4',
        imageUrl: 'https://picsum.photos/400/200?random=4',
        source: 'Thanh Niên',
        author: 'Phóng viên Thanh Niên',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        categories: ['business', 'environment'],
        language: 'vi',
        country: 'VN',
        sentiment: 1,
        relevanceScore: 0.90,
      ),
      News(
        id: '5',
        title: 'Việt Nam đăng cai tổ chức hội nghị ASEAN về chuyển đổi số',
        summary: 'Việt Nam sẽ đăng cai tổ chức hội nghị ASEAN về chuyển đổi số vào tháng tới.',
        content: 'Việt Nam đã được chọn làm nước chủ nhà đăng cai tổ chức hội nghị ASEAN về chuyển đổi số. Sự kiện này sẽ quy tụ các chuyên gia, nhà lãnh đạo và doanh nghiệp hàng đầu trong khu vực để thảo luận về các xu hướng và thách thức trong chuyển đổi số.',
        url: 'https://example.com/news/5',
        imageUrl: 'https://picsum.photos/400/200?random=5',
        source: 'VnExpress',
        author: 'Phóng viên VnExpress',
        publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
        categories: ['politics', 'technology'],
        language: 'vi',
        country: 'VN',
        sentiment: 1,
        relevanceScore: 0.85,
      ),
    ];
  }

  // Lấy danh sách categories
  static List<String> getCategories() {
    return [
      'politics',
      'business',
      'technology',
      'sports',
      'entertainment',
      'health',
      'science',
      'environment',
      'education',
    ];
  }

  // Lấy tên category bằng tiếng Việt
  static String getCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'politics':
        return 'Chính trị';
      case 'business':
        return 'Kinh tế';
      case 'technology':
        return 'Công nghệ';
      case 'sports':
        return 'Thể thao';
      case 'entertainment':
        return 'Giải trí';
      case 'health':
        return 'Sức khỏe';
      case 'science':
        return 'Khoa học';
      case 'environment':
        return 'Môi trường';
      case 'education':
        return 'Giáo dục';
      default:
        return category;
    }
  }

  // Lấy tin tức từ cache (offline mode)
  static Future<List<News>> getCachedNews({
    String? category,
    int? limit,
  }) async {
    return await NewsCacheService.getCachedNews(
      category: category,
      limit: limit,
    );
  }

  // Lấy thống kê cache
  static Future<Map<String, dynamic>> getCacheStats() async {
    return await NewsCacheService.getCacheStats();
  }

  // Xóa cache cũ
  static Future<void> cleanOldCache() async {
    return await NewsCacheService.cleanOldCache();
  }

  // Xóa toàn bộ cache
  static Future<void> clearAllCache() async {
    return await NewsCacheService.clearAllCache();
  }
}

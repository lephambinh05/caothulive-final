import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/news.dart';

class NewsCacheService {
  static const String _collectionName = 'cached_news';
  static const int _maxCacheSize = 20;
  
  // Lưu tin tức vào cache với FIFO
  static Future<void> cacheNews(List<News> newsList) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(_collectionName);
      
      // Lấy danh sách tin tức hiện tại
      final currentDocs = await collection
          .orderBy('cached_at', descending: false)
          .get();
      
      // Tính toán số lượng tin tức mới cần thêm
      final currentCount = currentDocs.docs.length;
      final newCount = newsList.length;
      final totalAfterAdd = currentCount + newCount;
      
      // Nếu vượt quá giới hạn, xóa tin tức cũ nhất (FIFO)
      if (totalAfterAdd > _maxCacheSize) {
        final toDelete = totalAfterAdd - _maxCacheSize;
        final oldestDocs = currentDocs.docs.take(toDelete);
        
        // Xóa tin tức cũ nhất
        for (final doc in oldestDocs) {
          await doc.reference.delete();
        }
        
        debugPrint('Deleted $toDelete oldest news articles to maintain cache size');
      }
      
      // Thêm tin tức mới
      final batch = firestore.batch();
      final now = Timestamp.now();
      
      for (final news in newsList) {
        final docRef = collection.doc();
        batch.set(docRef, {
          'id': news.id,
          'title': news.title,
          'summary': news.summary,
          'content': news.content,
          'url': news.url,
          'imageUrl': news.imageUrl,
          'source': news.source,
          'author': news.author,
          'publishedAt': Timestamp.fromDate(news.publishedAt),
          'categories': news.categories,
          'language': news.language,
          'country': news.country,
          'sentiment': news.sentiment,
          'relevanceScore': news.relevanceScore,
          'cached_at': now, // Thời gian cache để quản lý FIFO
        });
      }
      
      await batch.commit();
      debugPrint('Cached ${newsList.length} news articles to Firebase');
      
    } catch (e) {
      debugPrint('Error caching news: $e');
    }
  }
  
  // Lấy tin tức từ cache
  static Future<List<News>> getCachedNews({
    String? category,
    int? limit,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      Query query = firestore.collection(_collectionName);
      
      // Lọc theo category nếu có
      if (category != null && category.isNotEmpty) {
        query = query.where('categories', arrayContains: category);
      }
      
      // Sắp xếp theo thời gian cache (mới nhất trước)
      query = query.orderBy('cached_at', descending: true);
      
      // Giới hạn số lượng nếu có
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return News(
          id: data['id'] ?? '',
          title: data['title'] ?? '',
          summary: data['summary'] ?? '',
          content: data['content'] ?? '',
          url: data['url'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          source: data['source'] ?? '',
          author: data['author'] ?? '',
          publishedAt: (data['publishedAt'] as Timestamp).toDate(),
          categories: List<String>.from(data['categories'] ?? []),
          language: data['language'] ?? 'vi',
          country: data['country'] ?? 'VN',
          sentiment: data['sentiment'] ?? 0,
          relevanceScore: (data['relevanceScore'] ?? 0.0).toDouble(),
        );
      }).toList();
      
    } catch (e) {
      debugPrint('Error getting cached news: $e');
      return [];
    }
  }
  
  // Xóa cache cũ (tin tức cũ hơn 7 ngày)
  static Future<void> cleanOldCache() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final sevenDaysAgo = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 7))
      );
      
      final oldDocs = await firestore
          .collection(_collectionName)
          .where('cached_at', isLessThan: sevenDaysAgo)
          .get();
      
      if (oldDocs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (final doc in oldDocs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        
        debugPrint('Cleaned ${oldDocs.docs.length} old cached news articles');
      }
      
    } catch (e) {
      debugPrint('Error cleaning old cache: $e');
    }
  }
  
  // Lấy thống kê cache
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection(_collectionName).get();
      
      final totalCached = snapshot.docs.length;
      final now = DateTime.now();
      
      // Đếm tin tức theo ngày
      final todayCount = snapshot.docs.where((doc) {
        final cachedAt = (doc.data()['cached_at'] as Timestamp).toDate();
        return cachedAt.day == now.day && 
               cachedAt.month == now.month && 
               cachedAt.year == now.year;
      }).length;
      
      // Đếm tin tức theo category
      final categoryCount = <String, int>{};
      for (final doc in snapshot.docs) {
        final categories = List<String>.from(doc.data()['categories'] ?? []);
        for (final category in categories) {
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
      }
      
      return {
        'totalCached': totalCached,
        'maxCacheSize': _maxCacheSize,
        'todayCached': todayCount,
        'categoryCount': categoryCount,
        'cacheUtilization': (totalCached / _maxCacheSize * 100).round(),
      };
      
    } catch (e) {
      debugPrint('Error getting cache stats: $e');
      return {
        'totalCached': 0,
        'maxCacheSize': _maxCacheSize,
        'todayCached': 0,
        'categoryCount': <String, int>{},
        'cacheUtilization': 0,
      };
    }
  }
  
  // Xóa toàn bộ cache
  static Future<void> clearAllCache() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection(_collectionName).get();
      
      if (snapshot.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        
        debugPrint('Cleared all cached news (${snapshot.docs.length} articles)');
      }
      
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
  
  // Kiểm tra xem tin tức đã được cache chưa
  static Future<bool> isNewsCached(String newsId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection(_collectionName)
          .where('id', isEqualTo: newsId)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if news is cached: $e');
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/youtube_link.dart';
import '../models/youtube_channel.dart';
import 'content_categorization_service.dart';

class SearchService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;

  // Search filters
  static const List<String> _priorityFilters = ['Tất cả', 'Mức 1', 'Mức 2', 'Mức 3', 'Mức 4', 'Mức 5'];
  static const List<String> _categoryFilters = [
    'Tất cả',
    'Gaming',
    'Music',
    'Education',
    'Entertainment',
    'Technology',
    'Sports',
    'News',
    'Lifestyle',
    'Comedy',
    'Cooking',
    'Travel',
    'Fitness',
    'Business',
    'Science',
    'Art',
    'Other',
  ];

  static const List<String> _sortOptions = [
    'Mới nhất',
    'Cũ nhất',
    'Theo độ ưu tiên',
    'Theo tên A-Z',
    'Theo tên Z-A',
  ];

  // Search history
  static Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_searchHistoryKey) ?? [];
      return history;
    } catch (e) {
      debugPrint('Error getting search history: $e');
      return [];
    }
  }

  static Future<void> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getSearchHistory();
      
      // Remove if already exists
      history.remove(query.trim());
      
      // Add to beginning
      history.insert(0, query.trim());
      
      // Limit history size
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }
      
      await prefs.setStringList(_searchHistoryKey, history);
    } catch (e) {
      debugPrint('Error adding to search history: $e');
    }
  }

  static Future<void> clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchHistoryKey);
    } catch (e) {
      debugPrint('Error clearing search history: $e');
    }
  }

  // Search videos with advanced filters
  static Future<List<YouTubeLink>> searchVideos({
    required String query,
    int priorityFilter = 0,
    String categoryFilter = 'Tất cả',
    String sortBy = 'Mới nhất',
    int limit = 50,
  }) async {
    try {
      Query queryRef = _firestore.collection('youtube_links');

      // Text search
      if (query.isNotEmpty) {
        queryRef = queryRef.where('videoTitle', isGreaterThanOrEqualTo: query)
            .where('videoTitle', isLessThan: query + '\uf8ff');
      }

      // Priority filter
      if (priorityFilter > 0) {
        queryRef = queryRef.where('priority', isEqualTo: priorityFilter);
      }

      // Category filter
      if (categoryFilter != 'Tất cả') {
        final category = categoryFilter.toLowerCase();
        queryRef = queryRef.where('category', isEqualTo: category);
      }

      // Apply sorting
      switch (sortBy) {
        case 'Mới nhất':
          queryRef = queryRef.orderBy('createdAt', descending: true);
          break;
        case 'Cũ nhất':
          queryRef = queryRef.orderBy('createdAt', descending: false);
          break;
        case 'Theo độ ưu tiên':
          queryRef = queryRef.orderBy('priority', descending: false);
          break;
        case 'Theo tên A-Z':
          queryRef = queryRef.orderBy('videoTitle', descending: false);
          break;
        case 'Theo tên Z-A':
          queryRef = queryRef.orderBy('videoTitle', descending: true);
          break;
      }

      // Limit results
      queryRef = queryRef.limit(limit);

      final snapshot = await queryRef.get();
      final videos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return YouTubeLink.fromMap(data);
      }).toList();

      // Add to search history
      if (query.isNotEmpty) {
        await addToSearchHistory(query);
      }

      return videos;
    } catch (e) {
      debugPrint('Error searching videos: $e');
      return [];
    }
  }

  // Search channels
  static Future<List<YouTubeChannel>> searchChannels({
    required String query,
    String sortBy = 'Mới nhất',
    int limit = 50,
  }) async {
    try {
      Query queryRef = _firestore.collection('youtube_channels');

      // Text search
      if (query.isNotEmpty) {
        queryRef = queryRef.where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThan: query + '\uf8ff');
      }

      // Apply sorting
      switch (sortBy) {
        case 'Mới nhất':
          queryRef = queryRef.orderBy('createdAt', descending: true);
          break;
        case 'Cũ nhất':
          queryRef = queryRef.orderBy('createdAt', descending: false);
          break;
        case 'Theo tên A-Z':
          queryRef = queryRef.orderBy('name', descending: false);
          break;
        case 'Theo tên Z-A':
          queryRef = queryRef.orderBy('name', descending: true);
          break;
        case 'Theo số subscriber':
          queryRef = queryRef.orderBy('subscriberCount', descending: true);
          break;
      }

      // Limit results
      queryRef = queryRef.limit(limit);

      final snapshot = await queryRef.get();
      final channels = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return YouTubeChannel.fromMap(data);
      }).toList();

      // Add to search history
      if (query.isNotEmpty) {
        await addToSearchHistory(query);
      }

      return channels;
    } catch (e) {
      debugPrint('Error searching channels: $e');
      return [];
    }
  }

  // Get search suggestions based on history and popular terms
  static Future<List<String>> getSearchSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final history = await getSearchHistory();
      final suggestions = <String>[];

      // Add matching history items
      for (final item in history) {
        if (item.toLowerCase().contains(query.toLowerCase()) && 
            !suggestions.contains(item)) {
          suggestions.add(item);
        }
      }

      // Add common search terms
      final commonTerms = [
        'gaming',
        'music',
        'tutorial',
        'review',
        'news',
        'comedy',
        'cooking',
        'fitness',
        'travel',
        'technology',
      ];

      for (final term in commonTerms) {
        if (term.toLowerCase().contains(query.toLowerCase()) && 
            !suggestions.contains(term)) {
          suggestions.add(term);
        }
      }

      return suggestions.take(5).toList();
    } catch (e) {
      debugPrint('Error getting search suggestions: $e');
      return [];
    }
  }

  // Get filter options
  static List<String> getPriorityFilters() => _priorityFilters;
  static List<String> getCategoryFilters() => _categoryFilters;
  static List<String> getSortOptions() => _sortOptions;

  // Get popular searches
  static Future<List<String>> getPopularSearches() async {
    try {
      // This would typically come from analytics data
      // For now, return some common terms
      return [
        'gaming',
        'music videos',
        'tutorial',
        'news',
        'comedy',
        'cooking',
        'fitness',
        'travel',
        'technology',
        'education',
      ];
    } catch (e) {
      debugPrint('Error getting popular searches: $e');
      return [];
    }
  }

  // Get trending categories
  static Future<List<Map<String, dynamic>>> getTrendingCategories() async {
    try {
      // This would typically come from analytics data
      // For now, return some sample data
      return [
        {'name': 'Gaming', 'count': 150, 'icon': Icons.games},
        {'name': 'Music', 'count': 120, 'icon': Icons.music_note},
        {'name': 'Education', 'count': 80, 'icon': Icons.school},
        {'name': 'Entertainment', 'count': 200, 'icon': Icons.movie},
        {'name': 'Technology', 'count': 90, 'icon': Icons.computer},
        {'name': 'Sports', 'count': 60, 'icon': Icons.sports},
      ];
    } catch (e) {
      debugPrint('Error getting trending categories: $e');
      return [];
    }
  }
}

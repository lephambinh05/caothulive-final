import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/youtube_link.dart';
import '../models/youtube_channel.dart';

class AIContentDiscoveryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // AI-powered content discovery features
  static const String _apiBaseUrl = 'https://api.caothulive.com/ai'; // Your custom API
  
  // Content trend analysis
  static Future<List<YouTubeLink>> getTrendingContent({
    int limit = 10,
    String? category,
    Duration? timeRange,
  }) async {
    try {
      // Get trending videos based on click analytics
      final query = _firestore
          .collection('youtube_links')
          .orderBy('click_count', descending: true)  // Sort by click count
          .orderBy('last_clicked_at', descending: true)  // Then by recent clicks
          .limit(limit);
      
      final snapshot = await query.get();
      final trendingVideos = snapshot.docs
          .map((doc) => YouTubeLink.fromFirestore(doc))
          .toList();
      
      // If no trending data, use engagement metrics
      if (trendingVideos.isEmpty) {
        return await _getEngagementBasedTrending(limit);
      }
      
      return trendingVideos;
    } catch (e) {
      debugPrint('Error getting trending content: $e');
      return await _getEngagementBasedTrending(limit);
    }
  }
  
  // Track video click for trending analytics
  static Future<void> trackVideoClick(String videoId) async {
    try {
      final videoRef = _firestore.collection('youtube_links').doc(videoId);
      
      // Increment click count and update last clicked time
      await videoRef.update({
        'click_count': FieldValue.increment(1),
        'last_clicked_at': FieldValue.serverTimestamp(),
        'trending_score': FieldValue.increment(1), // Boost trending score
      });
      
      // Also track in analytics collection
      await _firestore.collection('click_analytics').add({
        'video_id': videoId,
        'clicked_at': FieldValue.serverTimestamp(),
        'user_id': 'anonymous', // You can implement user tracking later
      });
      
      debugPrint('Video click tracked for video: $videoId');
    } catch (e) {
      debugPrint('Error tracking video click: $e');
    }
  }
  
  // Get engagement-based trending when AI data is not available
  static Future<List<YouTubeLink>> _getEngagementBasedTrending(int limit) async {
    final snapshot = await _firestore
        .collection('youtube_links')
        .orderBy('priority', descending: true)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => YouTubeLink.fromFirestore(doc))
        .toList();
  }
  
  // AI-powered content recommendation
  static Future<List<YouTubeLink>> getPersonalizedRecommendations({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // Get user's viewing history and preferences
      final userPrefs = await _getUserPreferences(userId);
      final viewingHistory = await _getUserViewingHistory(userId);
      
      // AI recommendation algorithm
      final recommendations = await _generateRecommendations(
        userPrefs: userPrefs,
        viewingHistory: viewingHistory,
        limit: limit,
      );
      
      return recommendations;
    } catch (e) {
      debugPrint('Error getting personalized recommendations: $e');
      return await getTrendingContent(limit: limit);
    }
  }
  
  // Get user preferences from Firestore
  static Future<Map<String, dynamic>> _getUserPreferences(String userId) async {
    final doc = await _firestore
        .collection('user_preferences')
        .doc(userId)
        .get();
    
    if (doc.exists) {
      return doc.data()!;
    }
    
    // Return default preferences
    return {
      'preferred_categories': ['gaming', 'entertainment', 'music'],
      'preferred_channels': [],
      'viewing_time_preference': 'evening',
      'content_language': 'vi',
    };
  }
  
  // Get user viewing history
  static Future<List<String>> _getUserViewingHistory(String userId) async {
    final snapshot = await _firestore
        .collection('user_activity')
        .doc(userId)
        .collection('viewed_videos')
        .orderBy('viewed_at', descending: true)
        .limit(50)
        .get();
    
    return snapshot.docs
        .map((doc) => doc.data()['video_id'] as String)
        .toList();
  }
  
  // Generate AI recommendations
  static Future<List<YouTubeLink>> _generateRecommendations({
    required Map<String, dynamic> userPrefs,
    required List<String> viewingHistory,
    required int limit,
  }) async {
    // Simple recommendation algorithm
    // In production, this would use ML models
    
    final preferredCategories = userPrefs['preferred_categories'] as List<String>;
    final preferredChannels = userPrefs['preferred_channels'] as List<String>;
    
    Query query = _firestore.collection('youtube_links');
    
    // Filter by preferred categories if available
    if (preferredCategories.isNotEmpty) {
      query = query.where('category', whereIn: preferredCategories);
    }
    
    final snapshot = await query
        .orderBy('created_at', descending: true)
        .limit(limit * 2) // Get more to filter
        .get();
    
    final allVideos = snapshot.docs
        .map((doc) => YouTubeLink.fromFirestore(doc))
        .toList();
    
    // Score and rank videos
    final scoredVideos = allVideos.map((video) {
      double score = 0.0;
      
      // Category preference score
      if (preferredCategories.contains(video.category)) {
        score += 2.0;
      }
      
      // Channel preference score
      if (preferredChannels.contains(video.title)) {
        score += 3.0;
      }
      
      // Recency score
      final daysSinceCreated = DateTime.now().difference(video.createdAt).inDays;
      if (daysSinceCreated <= 1) score += 1.0;
      else if (daysSinceCreated <= 7) score += 0.5;
      
      // Priority score
      score += video.priority * 0.5;
      
      return {'video': video, 'score': score};
    }).toList();
    
    // Sort by score and return top recommendations
    scoredVideos.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    
    return scoredVideos
        .take(limit)
        .map((item) => item['video'] as YouTubeLink)
        .toList();
  }
  
  // Live stream prediction
  static Future<List<YouTubeChannel>> getPredictedLiveStreams({
    int limit = 5,
  }) async {
    try {
      // Get channels that are likely to go live soon
      final snapshot = await _firestore
          .collection('youtube_channels')
          .where('predicted_live_time', isLessThan: DateTime.now().add(const Duration(hours: 2)))
          .orderBy('predicted_live_time')
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => YouTubeChannel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting predicted live streams: $e');
      return [];
    }
  }
  
  // Content sentiment analysis
  static Future<Map<String, dynamic>> analyzeContentSentiment(YouTubeLink video) async {
    try {
      // Analyze video title and description for sentiment
      final text = '${video.videoTitle} ${video.videoDescription}';
      
      // Simple sentiment analysis (in production, use ML API)
      final positiveWords = ['tuyệt vời', 'hay', 'thú vị', 'hấp dẫn', 'xuất sắc'];
      final negativeWords = ['tệ', 'chán', 'không hay', 'thất vọng', 'tồi tệ'];
      
      int positiveCount = 0;
      int negativeCount = 0;
      
      for (final word in positiveWords) {
        if (text.toLowerCase().contains(word)) positiveCount++;
      }
      
      for (final word in negativeWords) {
        if (text.toLowerCase().contains(word)) negativeCount++;
      }
      
      String sentiment = 'neutral';
      double confidence = 0.5;
      
      if (positiveCount > negativeCount) {
        sentiment = 'positive';
        confidence = positiveCount / (positiveCount + negativeCount);
      } else if (negativeCount > positiveCount) {
        sentiment = 'negative';
        confidence = negativeCount / (positiveCount + negativeCount);
      }
      
      return {
        'sentiment': sentiment,
        'confidence': confidence,
        'positive_words': positiveCount,
        'negative_words': negativeCount,
      };
    } catch (e) {
      debugPrint('Error analyzing content sentiment: $e');
      return {
        'sentiment': 'neutral',
        'confidence': 0.5,
        'positive_words': 0,
        'negative_words': 0,
      };
    }
  }
  
  // Content categorization with AI
  static Future<String> categorizeContentWithAI(YouTubeLink video) async {
    try {
      // Enhanced categorization using AI
      final text = '${video.videoTitle} ${video.videoDescription} ${video.title}';
      
      // AI-powered category detection
      final categories = {
        'gaming': ['game', 'gaming', 'play', 'stream', 'minecraft', 'fortnite', 'valorant'],
        'music': ['music', 'song', 'sing', 'vocal', 'instrument', 'concert'],
        'education': ['learn', 'tutorial', 'course', 'lesson', 'study', 'education'],
        'entertainment': ['funny', 'comedy', 'show', 'movie', 'drama', 'series'],
        'technology': ['tech', 'computer', 'software', 'programming', 'coding'],
        'sports': ['sport', 'football', 'basketball', 'tennis', 'olympics'],
        'lifestyle': ['fashion', 'beauty', 'makeup', 'style', 'vlog', 'daily'],
        'cooking': ['cooking', 'recipe', 'food', 'kitchen', 'chef', 'baking'],
        'travel': ['travel', 'trip', 'vacation', 'journey', 'destination'],
        'fitness': ['fitness', 'workout', 'exercise', 'gym', 'training'],
      };
      
      final scores = <String, int>{};
      
      for (final category in categories.keys) {
        int score = 0;
        for (final keyword in categories[category]!) {
          if (text.toLowerCase().contains(keyword)) {
            score++;
          }
        }
        scores[category] = score;
      }
      
      // Find category with highest score
      String bestCategory = 'other';
      int maxScore = 0;
      
      for (final entry in scores.entries) {
        if (entry.value > maxScore) {
          maxScore = entry.value;
          bestCategory = entry.key;
        }
      }
      
      // Update video category in Firestore
      await _firestore.collection('youtube_links').doc(video.id).update({
        'ai_category': bestCategory,
        'ai_confidence': maxScore / 10.0, // Normalize to 0-1
        'categorized_at': FieldValue.serverTimestamp(),
      });
      
      return bestCategory;
    } catch (e) {
      debugPrint('Error categorizing content with AI: $e');
      return 'other';
    }
  }
  
  // Get content insights
  static Future<Map<String, dynamic>> getContentInsights() async {
    try {
      final now = DateTime.now();
      final last24Hours = now.subtract(const Duration(hours: 24));
      final last7Days = now.subtract(const Duration(days: 7));
      
      // Get recent content statistics
      final recentVideos = await _firestore
          .collection('youtube_links')
          .where('created_at', isGreaterThan: Timestamp.fromDate(last24Hours))
          .get();
      
      final weeklyVideos = await _firestore
          .collection('youtube_links')
          .where('created_at', isGreaterThan: Timestamp.fromDate(last7Days))
          .get();
      
      // Calculate insights
      final totalVideos = recentVideos.docs.length;
      final weeklyTotal = weeklyVideos.docs.length;
      
      // Calculate total clicks
      final totalClicks = recentVideos.docs.fold<int>(0, (sum, doc) {
        return sum + ((doc.data()['click_count'] ?? 0) as int);
      });
      
      // Category distribution
      final categoryCounts = <String, int>{};
      for (final doc in recentVideos.docs) {
        final category = doc.data()['category'] as String? ?? 'other';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
      
      // Top performing categories
      final topCategories = categoryCounts.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      return {
        'total_videos_24h': totalVideos,
        'total_videos_7d': weeklyTotal,
        'total_clicks_24h': totalClicks,
        'top_categories': topCategories.take(5).map((e) => {
          'category': e.key,
          'count': e.value,
        }).toList(),
        'growth_rate': weeklyTotal > 0 ? (totalVideos / weeklyTotal * 7) : 0,
        'trending_score': totalVideos > 10 ? 'high' : totalVideos > 5 ? 'medium' : 'low',
      };
    } catch (e) {
      debugPrint('Error getting content insights: $e');
      return {
        'total_videos_24h': 0,
        'total_videos_7d': 0,
        'top_categories': [],
        'growth_rate': 0,
        'trending_score': 'low',
      };
    }
  }
  
  // Update user preferences
  static Future<void> updateUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    await _firestore
        .collection('user_preferences')
        .doc(userId)
        .set(preferences, SetOptions(merge: true));
  }
  
  // Track user interaction for better recommendations
  static Future<void> trackUserInteraction({
    required String userId,
    required String videoId,
    required String action, // 'view', 'like', 'share', 'favorite'
    Map<String, dynamic>? metadata,
  }) async {
    await _firestore
        .collection('user_activity')
        .doc(userId)
        .collection('interactions')
        .add({
      'video_id': videoId,
      'action': action,
      'metadata': metadata ?? {},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

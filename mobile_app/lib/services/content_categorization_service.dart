import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/youtube_link.dart';

enum ContentCategory {
  gaming,
  music,
  education,
  entertainment,
  technology,
  sports,
  news,
  lifestyle,
  comedy,
  cooking,
  travel,
  fitness,
  business,
  science,
  art,
  other,
}

class ContentCategorizationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Category keywords mapping
  static const Map<ContentCategory, List<String>> _categoryKeywords = {
    ContentCategory.gaming: [
      'game', 'gaming', 'play', 'stream', 'twitch', 'minecraft', 'fortnite',
      'valorant', 'csgo', 'dota', 'lol', 'league of legends', 'fps', 'rpg',
      'strategy', 'puzzle', 'action', 'adventure', 'racing', 'sports game'
    ],
    ContentCategory.music: [
      'music', 'song', 'sing', 'vocal', 'instrument', 'guitar', 'piano',
      'drum', 'band', 'concert', 'album', 'lyrics', 'cover', 'remix',
      'beat', 'melody', 'rhythm', 'pop', 'rock', 'hip hop', 'rap'
    ],
    ContentCategory.education: [
      'learn', 'tutorial', 'course', 'lesson', 'study', 'education',
      'school', 'university', 'college', 'teacher', 'professor', 'student',
      'knowledge', 'skill', 'training', 'workshop', 'seminar', 'lecture'
    ],
    ContentCategory.entertainment: [
      'funny', 'comedy', 'entertainment', 'show', 'movie', 'film',
      'drama', 'series', 'episode', 'season', 'actor', 'actress',
      'celebrity', 'famous', 'star', 'hollywood', 'cinema', 'theater'
    ],
    ContentCategory.technology: [
      'tech', 'technology', 'computer', 'software', 'hardware', 'programming',
      'coding', 'developer', 'app', 'mobile', 'phone', 'laptop', 'pc',
      'gadget', 'device', 'innovation', 'ai', 'artificial intelligence'
    ],
    ContentCategory.sports: [
      'sport', 'football', 'soccer', 'basketball', 'tennis', 'golf',
      'swimming', 'running', 'cycling', 'boxing', 'mma', 'olympics',
      'championship', 'tournament', 'match', 'game', 'player', 'team'
    ],
    ContentCategory.news: [
      'news', 'breaking', 'update', 'report', 'journalism', 'reporter',
      'interview', 'politics', 'government', 'economy', 'business news',
      'world news', 'local news', 'current events', 'headlines'
    ],
    ContentCategory.lifestyle: [
      'lifestyle', 'fashion', 'beauty', 'makeup', 'style', 'outfit',
      'home', 'decor', 'interior', 'design', 'vlog', 'daily', 'routine',
      'morning', 'evening', 'weekend', 'vacation', 'travel'
    ],
    ContentCategory.comedy: [
      'comedy', 'funny', 'joke', 'humor', 'laugh', 'meme', 'prank',
      'stand up', 'comedy show', 'sketch', 'parody', 'satire', 'wit'
    ],
    ContentCategory.cooking: [
      'cooking', 'recipe', 'food', 'kitchen', 'chef', 'baking', 'cook',
      'meal', 'dinner', 'lunch', 'breakfast', 'ingredient', 'taste',
      'delicious', 'restaurant', 'cuisine', 'dish', 'cookbook'
    ],
    ContentCategory.travel: [
      'travel', 'trip', 'vacation', 'journey', 'adventure', 'explore',
      'destination', 'country', 'city', 'hotel', 'flight', 'tourism',
      'backpack', 'sightseeing', 'culture', 'local', 'experience'
    ],
    ContentCategory.fitness: [
      'fitness', 'workout', 'exercise', 'gym', 'training', 'muscle',
      'strength', 'cardio', 'yoga', 'pilates', 'running', 'cycling',
      'weight', 'diet', 'nutrition', 'health', 'body', 'shape'
    ],
    ContentCategory.business: [
      'business', 'entrepreneur', 'startup', 'company', 'marketing',
      'finance', 'investment', 'money', 'economy', 'stock', 'trading',
      'success', 'leadership', 'management', 'strategy', 'growth'
    ],
    ContentCategory.science: [
      'science', 'research', 'experiment', 'discovery', 'theory',
      'physics', 'chemistry', 'biology', 'medicine', 'health',
      'nature', 'environment', 'space', 'universe', 'technology'
    ],
    ContentCategory.art: [
      'art', 'painting', 'drawing', 'design', 'creative', 'artist',
      'gallery', 'museum', 'sculpture', 'photography', 'digital art',
      'illustration', 'sketch', 'canvas', 'brush', 'color'
    ],
  };

  // Categorize video content
  static Future<ContentCategory> categorizeVideo(YouTubeLink video) async {
    // Combine title, description, and channel name for analysis
    final text = '${video.videoTitle} ${video.videoDescription} ${video.title}'.toLowerCase();
    
    // Score each category based on keyword matches
    final Map<ContentCategory, int> scores = {};
    
    for (final category in ContentCategory.values) {
      if (category == ContentCategory.other) continue;
      
      int score = 0;
      final keywords = _categoryKeywords[category] ?? [];
      
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          score++;
        }
      }
      
      scores[category] = score;
    }
    
    // Find category with highest score
    ContentCategory bestCategory = ContentCategory.other;
    int maxScore = 0;
    
    for (final entry in scores.entries) {
      if (entry.value > maxScore) {
        maxScore = entry.value;
        bestCategory = entry.key;
      }
    }
    
    // If no keywords matched, try to categorize by channel
    if (maxScore == 0) {
      bestCategory = await _categorizeByChannel(video.title);
    }
    
    // Save categorization to Firestore
    await _saveCategorization(video.id, bestCategory);
    
    return bestCategory;
  }

  // Categorize by channel name
  static Future<ContentCategory> _categorizeByChannel(String channelName) async {
    final channelDoc = await _firestore
        .collection('youtube_channels')
        .where('name', isEqualTo: channelName)
        .limit(1)
        .get();
    
    if (channelDoc.docs.isNotEmpty) {
      final data = channelDoc.docs.first.data();
      final category = data['category'] as String?;
      if (category != null) {
        return ContentCategory.values.firstWhere(
          (c) => c.name == category,
          orElse: () => ContentCategory.other,
        );
      }
    }
    
    return ContentCategory.other;
  }

  // Save categorization to Firestore
  static Future<void> _saveCategorization(String? videoId, ContentCategory category) async {
    if (videoId != null) {
      await _firestore.collection('youtube_links').doc(videoId).update({
        'category': category.name,
        'categorizedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get videos by category
  static Future<List<YouTubeLink>> getVideosByCategory(ContentCategory category) async {
    final querySnapshot = await _firestore
        .collection('youtube_links')
        .where('category', isEqualTo: category.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    
    return querySnapshot.docs
        .map((doc) => YouTubeLink.fromFirestore(doc))
        .toList();
  }

  // Get category statistics
  static Future<Map<ContentCategory, int>> getCategoryStats() async {
    final Map<ContentCategory, int> stats = {};
    
    for (final category in ContentCategory.values) {
      if (category == ContentCategory.other) continue;
      
      final querySnapshot = await _firestore
          .collection('youtube_links')
          .where('category', isEqualTo: category.name)
          .get();
      
      stats[category] = querySnapshot.docs.length;
    }
    
    return stats;
  }

  // Get category display name
  static String getCategoryDisplayName(ContentCategory category) {
    switch (category) {
      case ContentCategory.gaming:
        return '🎮 Gaming';
      case ContentCategory.music:
        return '🎵 Music';
      case ContentCategory.education:
        return '📚 Education';
      case ContentCategory.entertainment:
        return '🎬 Entertainment';
      case ContentCategory.technology:
        return '💻 Technology';
      case ContentCategory.sports:
        return '⚽ Sports';
      case ContentCategory.news:
        return '📰 News';
      case ContentCategory.lifestyle:
        return '✨ Lifestyle';
      case ContentCategory.comedy:
        return '😂 Comedy';
      case ContentCategory.cooking:
        return '🍳 Cooking';
      case ContentCategory.travel:
        return '✈️ Travel';
      case ContentCategory.fitness:
        return '💪 Fitness';
      case ContentCategory.business:
        return '💼 Business';
      case ContentCategory.science:
        return '🔬 Science';
      case ContentCategory.art:
        return '🎨 Art';
      case ContentCategory.other:
        return '📁 Other';
    }
  }

  // Get category color
  static int getCategoryColor(ContentCategory category) {
    switch (category) {
      case ContentCategory.gaming:
        return 0xFF9C27B0; // Purple
      case ContentCategory.music:
        return 0xFFE91E63; // Pink
      case ContentCategory.education:
        return 0xFF2196F3; // Blue
      case ContentCategory.entertainment:
        return 0xFFFF9800; // Orange
      case ContentCategory.technology:
        return 0xFF607D8B; // Blue Grey
      case ContentCategory.sports:
        return 0xFF4CAF50; // Green
      case ContentCategory.news:
        return 0xFFF44336; // Red
      case ContentCategory.lifestyle:
        return 0xFFE91E63; // Pink
      case ContentCategory.comedy:
        return 0xFFFFEB3B; // Yellow
      case ContentCategory.cooking:
        return 0xFFFF5722; // Deep Orange
      case ContentCategory.travel:
        return 0xFF00BCD4; // Cyan
      case ContentCategory.fitness:
        return 0xFF8BC34A; // Light Green
      case ContentCategory.business:
        return 0xFF795548; // Brown
      case ContentCategory.science:
        return 0xFF3F51B5; // Indigo
      case ContentCategory.art:
        return 0xFF9C27B0; // Purple
      case ContentCategory.other:
        return 0xFF9E9E9E; // Grey
    }
  }

  // Batch categorize videos
  static Future<void> batchCategorizeVideos(List<YouTubeLink> videos) async {
    for (final video in videos) {
      try {
        await categorizeVideo(video);
        // Add delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        debugPrint('Error categorizing video ${video.id}: $e');
      }
    }
  }

  // Update channel category
  static Future<void> updateChannelCategory(String channelId, ContentCategory category) async {
    await _firestore.collection('youtube_channels').doc(channelId).update({
      'category': category.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

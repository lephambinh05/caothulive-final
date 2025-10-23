import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService {
  static const String _collectionName = 'leaderboard';

  // Submit score to leaderboard
  static Future<void> submitScore({
    required String playerName,
    required int score,
    required int timeSpent,
    required String gameType,
    Map<String, dynamic> gameStats = const {},
  }) async {
    try {
      debugPrint('=== SUBMITTING SCORE ===');
      debugPrint('Player: $playerName');
      debugPrint('Score: $score');
      debugPrint('Time: $timeSpent');
      debugPrint('Game: $gameType');
      
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(_collectionName);
      
      debugPrint('Firestore instance: ${firestore.app.name}');
      debugPrint('Collection: $_collectionName');

      final entry = LeaderboardEntry(
        id: '', // Will be auto-generated
        playerName: playerName,
        score: score,
        timeSpent: timeSpent,
        playedAt: DateTime.now(),
        gameType: gameType,
        gameStats: gameStats,
      );

      final data = entry.toMap();
      debugPrint('Data to save: $data');
      
      final docRef = await collection.add(data);
      debugPrint('Document added with ID: ${docRef.id}');
      debugPrint('✅ Score submitted successfully for $gameType: $score');
    } catch (e) {
      debugPrint('❌ Error submitting score: $e');
      debugPrint('Error type: ${e.runtimeType}');
      
      // Check for specific Firebase errors
      if (e.toString().contains('PERMISSION_DENIED')) {
        debugPrint('❌ Permission denied - check Firebase rules');
      } else if (e.toString().contains('INVALID_ARGUMENT')) {
        debugPrint('❌ Invalid data format - check data validation');
      } else if (e.toString().contains('UNAVAILABLE')) {
        debugPrint('❌ Firebase service unavailable');
      }
      
      rethrow; // Re-throw để UI có thể handle
    }
  }

  // Get leaderboard for specific game type
  static Future<List<LeaderboardEntry>> getLeaderboard({
    required String gameType,
    int limit = 10,
  }) async {
    try {
      debugPrint('=== GETTING LEADERBOARD ===');
      debugPrint('Game type: $gameType');
      debugPrint('Limit: $limit');
      
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(_collectionName);
      
      debugPrint('Firestore instance: ${firestore.app.name}');
      debugPrint('Collection: $_collectionName');

      final snapshot = await collection
          .where('gameType', isEqualTo: gameType)
          .orderBy('score', descending: true)
          .orderBy('timeSpent', descending: false) // Lower time is better
          .limit(limit)
          .get();

      debugPrint('Raw docs count: ${snapshot.docs.length}');
      
      // Debug: Print all documents
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        debugPrint('Doc $i: ${doc.id} - ${doc.data()}');
      }
      
      final entries = snapshot.docs
          .map((doc) => LeaderboardEntry.fromFirestore(doc))
          .toList();

      debugPrint('✅ Retrieved ${entries.length} leaderboard entries for $gameType');
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        debugPrint('Entry $i: ${entry.playerName} - ${entry.score} - ${entry.gameType}');
      }
      
      return entries;
    } catch (e) {
      debugPrint('❌ Error getting leaderboard: $e');
      debugPrint('Error type: ${e.runtimeType}');
      return [];
    }
  }

  // Get player's best score for a game type
  static Future<LeaderboardEntry?> getPlayerBestScore({
    required String playerName,
    required String gameType,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(_collectionName);

      final snapshot = await collection
          .where('playerName', isEqualTo: playerName)
          .where('gameType', isEqualTo: gameType)
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return LeaderboardEntry.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting player best score: $e');
      return null;
    }
  }

  // Get player's rank for a specific score
  static Future<int> getPlayerRank({
    required String gameType,
    required int score,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(_collectionName);

      final snapshot = await collection
          .where('gameType', isEqualTo: gameType)
          .where('score', isGreaterThan: score)
          .get();

      return snapshot.docs.length + 1; // Rank is position + 1
    } catch (e) {
      debugPrint('Error getting player rank: $e');
      return 0;
    }
  }

  // Get global leaderboard (all games combined)
  static Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    int limit = 20,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(_collectionName);

      final snapshot = await collection
          .orderBy('score', descending: true)
          .orderBy('timeSpent', descending: false)
          .limit(limit)
          .get();

      final entries = snapshot.docs
          .map((doc) => LeaderboardEntry.fromFirestore(doc))
          .toList();

      debugPrint('Retrieved ${entries.length} global leaderboard entries');
      return entries;
    } catch (e) {
      debugPrint('Error getting global leaderboard: $e');
      return [];
    }
  }

  // Get game statistics
  static Future<Map<String, dynamic>> getGameStats(String gameType) async {
    try {
      debugPrint('=== GETTING GAME STATS ===');
      debugPrint('Game type: $gameType');
      
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(_collectionName);

      final snapshot = await collection
          .where('gameType', isEqualTo: gameType)
          .get();

      debugPrint('Raw docs count for $gameType: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        debugPrint('No data found for $gameType');
        return {
          'totalPlayers': 0,
          'totalGames': 0,
          'averageScore': 0.0,
          'highestScore': 0,
        };
      }

      final entries = snapshot.docs
          .map((doc) => LeaderboardEntry.fromFirestore(doc))
          .toList();

      final totalPlayers = entries.map((e) => e.playerName).toSet().length;
      final totalGames = entries.length;
      final averageScore = entries.map((e) => e.score).reduce((a, b) => a + b) / totalGames;
      final highestScore = entries.map((e) => e.score).reduce((a, b) => a > b ? a : b);

      return {
        'totalPlayers': totalPlayers,
        'totalGames': totalGames,
        'averageScore': averageScore,
        'highestScore': highestScore,
      };
    } catch (e) {
      debugPrint('Error getting game stats: $e');
      return {
        'totalPlayers': 0,
        'totalGames': 0,
        'averageScore': 0.0,
        'highestScore': 0,
      };
    }
  }
}

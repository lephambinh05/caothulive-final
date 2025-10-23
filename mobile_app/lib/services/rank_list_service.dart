import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RankListService {
  static const String _rankListKey = 'quiz_rank_list';
  static const String _userStatsKey = 'user_stats';
  
  // Player data structure
  static Map<String, dynamic> _userStats = {
    'totalScore': 0,
    'gamesPlayed': 0,
    'bestScore': 0,
    'averageScore': 0.0,
    'totalTime': 0,
    'streak': 0,
    'longestStreak': 0,
    'rank': 'Bronze',
    'level': 1,
    'achievements': [],
    'lastPlayed': DateTime.now().toIso8601String(),
  };
  
  // Rank system
  static const Map<String, Map<String, dynamic>> _rankSystem = {
    'Bronze': {
      'minScore': 0,
      'maxScore': 500,
      'color': 0xFFCD7F32,
      'icon': '🥉',
      'title': 'Đồng',
    },
    'Silver': {
      'minScore': 500,
      'maxScore': 1000,
      'color': 0xFFC0C0C0,
      'icon': '🥈',
      'title': 'Bạc',
    },
    'Gold': {
      'minScore': 1000,
      'maxScore': 2000,
      'color': 0xFFFFD700,
      'icon': '🥇',
      'title': 'Vàng',
    },
    'Platinum': {
      'minScore': 2000,
      'maxScore': 4000,
      'color': 0xFFE5E4E2,
      'icon': '💎',
      'title': 'Bạch Kim',
    },
    'Diamond': {
      'minScore': 4000,
      'maxScore': 8000,
      'color': 0xFFB9F2FF,
      'icon': '💠',
      'title': 'Kim Cương',
    },
    'Master': {
      'minScore': 8000,
      'maxScore': 15000,
      'color': 0xFF8A2BE2,
      'icon': '👑',
      'title': 'Bậc Thầy',
    },
    'Grandmaster': {
      'minScore': 15000,
      'maxScore': 999999,
      'color': 0xFFFF6B6B,
      'icon': '🏆',
      'title': 'Đại Sư',
    },
  };
  
  // Achievement system
  static const Map<String, Map<String, dynamic>> _achievements = {
    'first_game': {
      'title': 'Người chơi đầu tiên',
      'description': 'Hoàn thành game đầu tiên',
      'icon': '🎮',
      'points': 10,
    },
    'perfect_score': {
      'title': 'Điểm số hoàn hảo',
      'description': 'Đạt 100% trong một game',
      'icon': '💯',
      'points': 50,
    },
    'streak_5': {
      'title': 'Chuỗi 5 ngày',
      'description': 'Chơi liên tiếp 5 ngày',
      'icon': '🔥',
      'points': 30,
    },
    'streak_10': {
      'title': 'Chuỗi 10 ngày',
      'description': 'Chơi liên tiếp 10 ngày',
      'icon': '⚡',
      'points': 60,
    },
    'score_1000': {
      'title': '1000 điểm',
      'description': 'Tích lũy 1000 điểm',
      'icon': '🎯',
      'points': 25,
    },
    'score_5000': {
      'title': '5000 điểm',
      'description': 'Tích lũy 5000 điểm',
      'icon': '🚀',
      'points': 100,
    },
    'games_10': {
      'title': '10 game',
      'description': 'Chơi 10 game',
      'icon': '🎲',
      'points': 20,
    },
    'games_50': {
      'title': '50 game',
      'description': 'Chơi 50 game',
      'icon': '🎪',
      'points': 80,
    },
    'gold_rank': {
      'title': 'Hạng Vàng',
      'description': 'Đạt hạng Vàng',
      'icon': '🥇',
      'points': 75,
    },
    'diamond_rank': {
      'title': 'Hạng Kim Cương',
      'description': 'Đạt hạng Kim Cương',
      'icon': '💎',
      'points': 150,
    },
  };
  
  // Initialize user stats
  static Future<void> initializeUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_userStatsKey);
    
    if (statsJson != null) {
      _userStats = Map<String, dynamic>.from(json.decode(statsJson));
    }
  }
  
  // Save user stats
  static Future<void> saveUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStatsKey, json.encode(_userStats));
  }
  
  // Update stats after game
  static Future<Map<String, dynamic>> updateStats({
    required int score,
    required int timeSpent,
    required int questionsCorrect,
    required int totalQuestions,
  }) async {
    await initializeUserStats();
    
    // Update basic stats
    _userStats['totalScore'] = (_userStats['totalScore'] as int) + score;
    _userStats['gamesPlayed'] = (_userStats['gamesPlayed'] as int) + 1;
    _userStats['totalTime'] = (_userStats['totalTime'] as int) + timeSpent;
    _userStats['lastPlayed'] = DateTime.now().toIso8601String();
    
    // Update best score
    if (score > (_userStats['bestScore'] as int)) {
      _userStats['bestScore'] = score;
    }
    
    // Update average score
    int totalScore = _userStats['totalScore'] as int;
    int gamesPlayed = _userStats['gamesPlayed'] as int;
    _userStats['averageScore'] = totalScore / gamesPlayed;
    
    // Update streak
    DateTime lastPlayed = DateTime.parse(_userStats['lastPlayed']);
    DateTime now = DateTime.now();
    
    if (now.difference(lastPlayed).inDays <= 1) {
      _userStats['streak'] = (_userStats['streak'] as int) + 1;
    } else {
      _userStats['streak'] = 1;
    }
    
    if ((_userStats['streak'] as int) > (_userStats['longestStreak'] as int)) {
      _userStats['longestStreak'] = _userStats['streak'];
    }
    
    // Update rank
    _updateRank();
    
    // Check achievements
    List<String> newAchievements = _checkAchievements();
    _userStats['achievements'].addAll(newAchievements);
    
    await saveUserStats();
    
    return {
      'stats': _userStats,
      'newAchievements': newAchievements,
      'rankUp': _checkRankUp(),
    };
  }
  
  // Update rank based on total score
  static void _updateRank() {
    int totalScore = _userStats['totalScore'] as int;
    String currentRank = _userStats['rank'] as String;
    
    for (String rank in _rankSystem.keys) {
      int minScore = _rankSystem[rank]!['minScore'] as int;
      int maxScore = _rankSystem[rank]!['maxScore'] as int;
      
      if (totalScore >= minScore && totalScore < maxScore) {
        _userStats['rank'] = rank;
        _userStats['level'] = _calculateLevel(totalScore, rank);
        break;
      }
    }
  }
  
  // Calculate level within rank
  static int _calculateLevel(int score, String rank) {
    int minScore = _rankSystem[rank]!['minScore'] as int;
    int maxScore = _rankSystem[rank]!['maxScore'] as int;
    int rankRange = maxScore - minScore;
    int scoreInRank = score - minScore;
    
    return ((scoreInRank / rankRange) * 10).floor() + 1;
  }
  
  // Check for new achievements
  static List<String> _checkAchievements() {
    List<String> newAchievements = [];
    List<String> currentAchievements = List<String>.from(_userStats['achievements']);
    
    // Check each achievement
    _achievements.forEach((key, achievement) {
      if (!currentAchievements.contains(key)) {
        bool unlocked = false;
        
        switch (key) {
          case 'first_game':
            unlocked = (_userStats['gamesPlayed'] as int) >= 1;
            break;
          case 'perfect_score':
            unlocked = (_userStats['bestScore'] as int) >= 100;
            break;
          case 'streak_5':
            unlocked = (_userStats['streak'] as int) >= 5;
            break;
          case 'streak_10':
            unlocked = (_userStats['streak'] as int) >= 10;
            break;
          case 'score_1000':
            unlocked = (_userStats['totalScore'] as int) >= 1000;
            break;
          case 'score_5000':
            unlocked = (_userStats['totalScore'] as int) >= 5000;
            break;
          case 'games_10':
            unlocked = (_userStats['gamesPlayed'] as int) >= 10;
            break;
          case 'games_50':
            unlocked = (_userStats['gamesPlayed'] as int) >= 50;
            break;
          case 'gold_rank':
            unlocked = _userStats['rank'] == 'Gold';
            break;
          case 'diamond_rank':
            unlocked = _userStats['rank'] == 'Diamond';
            break;
        }
        
        if (unlocked) {
          newAchievements.add(key);
        }
      }
    });
    
    return newAchievements;
  }
  
  // Check if rank up
  static bool _checkRankUp() {
    // This would need to be implemented to track previous rank
    // For now, return false
    return false;
  }
  
  // Get user stats
  static Map<String, dynamic> getUserStats() {
    return _userStats;
  }
  
  // Get rank info
  static Map<String, dynamic> getRankInfo(String rank) {
    return _rankSystem[rank] ?? _rankSystem['Bronze']!;
  }
  
  // Get all achievements
  static Map<String, Map<String, dynamic>> getAllAchievements() {
    return _achievements;
  }
  
  // Get user achievements
  static List<Map<String, dynamic>> getUserAchievements() {
    List<String> userAchievements = List<String>.from(_userStats['achievements']);
    List<Map<String, dynamic>> result = [];
    
    userAchievements.forEach((key) {
      if (_achievements.containsKey(key)) {
        result.add({
          'key': key,
          ..._achievements[key]!,
        });
      }
    });
    
    return result;
  }
  
  // Get next rank info
  static Map<String, dynamic> getNextRankInfo() {
    String currentRank = _userStats['rank'] as String;
    List<String> ranks = _rankSystem.keys.toList();
    int currentIndex = ranks.indexOf(currentRank);
    
    if (currentIndex < ranks.length - 1) {
      String nextRank = ranks[currentIndex + 1];
      return {
        'rank': nextRank,
        ..._rankSystem[nextRank]!,
        'scoreNeeded': _rankSystem[nextRank]!['minScore'] - (_userStats['totalScore'] as int),
      };
    }
    
    return {
      'rank': 'Max',
      'title': 'Đã đạt hạng cao nhất',
      'icon': '🏆',
      'color': 0xFFFF6B6B,
    };
  }
  
  // Get progress to next rank
  static double getProgressToNextRank() {
    String currentRank = _userStats['rank'] as String;
    int currentScore = _userStats['totalScore'] as int;
    
    int minScore = _rankSystem[currentRank]!['minScore'] as int;
    int maxScore = _rankSystem[currentRank]!['maxScore'] as int;
    
    if (maxScore == 999999) return 1.0; // Max rank
    
    int scoreInRank = currentScore - minScore;
    int rankRange = maxScore - minScore;
    
    return (scoreInRank / rankRange).clamp(0.0, 1.0);
  }
}

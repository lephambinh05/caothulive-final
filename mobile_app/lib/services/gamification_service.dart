import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/achievement.dart';
import '../models/user_stats.dart';
import '../models/daily_challenge.dart';

// Achievement types
enum AchievementType {
    firstVideo,
    firstChannel,
    tenVideos,
    fiftyVideos,
    hundredVideos,
    firstFavorite,
    tenFavorites,
    fiftyFavorites,
    firstShare,
    tenShares,
    dailyStreak,
    weeklyStreak,
    monthlyStreak,
    categoryExplorer,
    nightOwl,
    earlyBird,
    socialButterfly,
    contentCreator,
    trendSetter,
    loyalFan,
  }

class GamificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _userId = 'current_user'; // In real app, get from auth

  // Points system
  static const Map<String, int> _pointsMap = {
    'watch_video': 1,
    'add_favorite': 5,
    'share_video': 10,
    'complete_challenge': 25,
    'unlock_achievement': 50,
    'daily_login': 2,
    'weekly_streak': 100,
    'monthly_streak': 500,
  };

  // Initialize gamification for user
  static Future<void> initializeUser() async {
    final userStats = await getUserStats();
    if (userStats == null) {
      await _createUserStats();
    }
  }

  // Create initial user stats
  static Future<void> _createUserStats() async {
    final userStats = UserStats(
      userId: _userId,
      totalPoints: 0,
      level: 1,
      videosWatched: 0,
      favoritesAdded: 0,
      videosShared: 0,
      achievementsUnlocked: 0,
      dailyStreak: 0,
      weeklyStreak: 0,
      monthlyStreak: 0,
      lastLoginDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('user_stats')
        .doc(_userId)
        .set(userStats.toMap());
  }

  // Get user stats
  static Future<UserStats?> getUserStats() async {
    final doc = await _firestore.collection('user_stats').doc(_userId).get();
    if (doc.exists) {
      return UserStats.fromMap(doc.data()!);
    }
    return null;
  }

  // Add points
  static Future<void> addPoints(String action, {int? customPoints}) async {
    final points = customPoints ?? _pointsMap[action] ?? 0;
    if (points <= 0) return;

    final userStats = await getUserStats();
    if (userStats == null) return;

    final newTotalPoints = userStats.totalPoints + points;
    final newLevel = _calculateLevel(newTotalPoints);

    await _firestore.collection('user_stats').doc(_userId).update({
      'totalPoints': newTotalPoints,
      'level': newLevel,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Check for level up
    if (newLevel > userStats.level) {
      await _handleLevelUp(newLevel);
    }

    // Check for achievements
    await _checkAchievements(action);
  }

  // Calculate level based on points
  static int _calculateLevel(int points) {
    // Level formula: level = sqrt(points / 100) + 1
    return sqrt(points / 100).floor() + 1;
  }

  // Handle level up
  static Future<void> _handleLevelUp(int newLevel) async {
    // Show level up notification
    // This would integrate with NotificationService
    debugPrint('Level up! New level: $newLevel');
    
    // Add bonus points for leveling up
    await addPoints('level_up', customPoints: newLevel * 10);
  }

  // Check achievements
  static Future<void> _checkAchievements(String action) async {
    final userStats = await getUserStats();
    if (userStats == null) return;

    final achievements = await getUnlockedAchievements();
    final unlockedIds = achievements.map((a) => a.id).toList();

    // Check each achievement type
    for (final achievementType in AchievementType.values) {
      if (unlockedIds.contains(achievementType.name)) continue;

      bool shouldUnlock = false;
      Achievement? achievement;

      switch (achievementType) {
        case AchievementType.firstVideo:
          shouldUnlock = userStats.videosWatched >= 1;
          achievement = Achievement(
            id: achievementType.name,
            title: '🎬 First Video',
            description: 'Watch your first video',
            points: 50,
            icon: '🎬',
            unlockedAt: DateTime.now(),
          );
          break;

        case AchievementType.firstChannel:
          shouldUnlock = userStats.favoritesAdded >= 1;
          achievement = Achievement(
            id: achievementType.name,
            title: '⭐ First Favorite',
            description: 'Add your first favorite channel',
            points: 50,
            icon: '⭐',
            unlockedAt: DateTime.now(),
          );
          break;

        case AchievementType.tenVideos:
          shouldUnlock = userStats.videosWatched >= 10;
          achievement = Achievement(
            id: achievementType.name,
            title: '🎥 Video Enthusiast',
            description: 'Watch 10 videos',
            points: 100,
            icon: '🎥',
            unlockedAt: DateTime.now(),
          );
          break;

        case AchievementType.fiftyVideos:
          shouldUnlock = userStats.videosWatched >= 50;
          achievement = Achievement(
            id: achievementType.name,
            title: '🎬 Video Lover',
            description: 'Watch 50 videos',
            points: 250,
            icon: '🎬',
            unlockedAt: DateTime.now(),
          );
          break;

        case AchievementType.hundredVideos:
          shouldUnlock = userStats.videosWatched >= 100;
          achievement = Achievement(
            id: achievementType.name,
            title: '🎭 Video Master',
            description: 'Watch 100 videos',
            points: 500,
            icon: '🎭',
            unlockedAt: DateTime.now(),
          );
          break;

        case AchievementType.dailyStreak:
          shouldUnlock = userStats.dailyStreak >= 7;
          achievement = Achievement(
            id: achievementType.name,
            title: '🔥 Streak Master',
            description: 'Maintain a 7-day streak',
            points: 200,
            icon: '🔥',
            unlockedAt: DateTime.now(),
          );
          break;

        case AchievementType.socialButterfly:
          shouldUnlock = userStats.videosShared >= 10;
          achievement = Achievement(
            id: achievementType.name,
            title: '🦋 Social Butterfly',
            description: 'Share 10 videos',
            points: 150,
            icon: '🦋',
            unlockedAt: DateTime.now(),
          );
          break;

        default:
          break;
      }

      if (shouldUnlock && achievement != null) {
        await _unlockAchievement(achievement);
      }
    }
  }

  // Unlock achievement
  static Future<void> _unlockAchievement(Achievement achievement) async {
    await _firestore
        .collection('achievements')
        .doc(_userId)
        .collection('user_achievements')
        .doc(achievement.id)
        .set(achievement.toMap());

    // Add points for unlocking achievement
    await addPoints('unlock_achievement', customPoints: achievement.points);

    // Update user stats
    await _firestore.collection('user_stats').doc(_userId).update({
      'achievementsUnlocked': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Show achievement notification
    // This would integrate with NotificationService
    debugPrint('Achievement unlocked: ${achievement.title}');
  }

  // Get unlocked achievements
  static Future<List<Achievement>> getUnlockedAchievements() async {
    final querySnapshot = await _firestore
        .collection('achievements')
        .doc(_userId)
        .collection('user_achievements')
        .orderBy('unlockedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Achievement.fromMap(doc.data()))
        .toList();
  }

  // Get leaderboard
  static Future<List<UserStats>> getLeaderboard({int limit = 10}) async {
    final querySnapshot = await _firestore
        .collection('user_stats')
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => UserStats.fromMap(doc.data()))
        .toList();
  }

  // Get daily challenge
  static Future<DailyChallenge?> getDailyChallenge() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final doc = await _firestore
        .collection('daily_challenges')
        .doc(today)
        .get();

    if (doc.exists) {
      return DailyChallenge.fromMap(doc.data()!);
    }

    // Create new daily challenge if none exists
    return await _createDailyChallenge();
  }

  // Create daily challenge
  static Future<DailyChallenge> _createDailyChallenge() async {
    final challenges = [
      {
        'title': '🎬 Watch 5 Videos',
        'description': 'Watch 5 videos today to earn bonus points',
        'target': 5,
        'action': 'watch_video',
        'points': 25,
      },
      {
        'title': '⭐ Add 3 Favorites',
        'description': 'Add 3 channels to your favorites',
        'target': 3,
        'action': 'add_favorite',
        'points': 30,
      },
      {
        'title': '🦋 Share 2 Videos',
        'description': 'Share 2 videos with friends',
        'target': 2,
        'action': 'share_video',
        'points': 40,
      },
      {
        'title': '🔍 Explore Categories',
        'description': 'Watch videos from 3 different categories',
        'target': 3,
        'action': 'explore_categories',
        'points': 35,
      },
    ];

    final randomChallenge = challenges[DateTime.now().day % challenges.length];
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final challenge = DailyChallenge(
      id: today,
      title: randomChallenge['title'] as String,
      description: randomChallenge['description'] as String,
      target: randomChallenge['target'] as int,
      action: randomChallenge['action'] as String,
      points: randomChallenge['points'] as int,
      date: DateTime.now(),
      isCompleted: false,
      progress: 0,
    );

    await _firestore
        .collection('daily_challenges')
        .doc(today)
        .set(challenge.toMap());

    return challenge;
  }

  // Update daily challenge progress
  static Future<void> updateChallengeProgress(String action) async {
    final challenge = await getDailyChallenge();
    if (challenge == null || challenge.isCompleted) return;

    if (challenge.action == action) {
      final newProgress = challenge.progress + 1;
      final isCompleted = newProgress >= challenge.target;

      await _firestore
          .collection('daily_challenges')
          .doc(challenge.id)
          .update({
        'progress': newProgress,
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
      });

      if (isCompleted) {
        await addPoints('complete_challenge', customPoints: challenge.points);
      }
    }
  }

  // Track user action
  static Future<void> trackAction(String action, {Map<String, dynamic>? data}) async {
    final userStats = await getUserStats();
    if (userStats == null) return;

    Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    switch (action) {
      case 'watch_video':
        updates['videosWatched'] = FieldValue.increment(1);
        break;
      case 'add_favorite':
        updates['favoritesAdded'] = FieldValue.increment(1);
        break;
      case 'share_video':
        updates['videosShared'] = FieldValue.increment(1);
        break;
      case 'daily_login':
        await _updateStreak();
        break;
    }

    await _firestore.collection('user_stats').doc(_userId).update(updates);
    await addPoints(action);
    await updateChallengeProgress(action);
  }

  // Update streak
  static Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getString('last_login_date');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastLogin != today) {
      final yesterday = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));

      if (lastLogin == yesterday) {
        // Continue streak
        await _firestore.collection('user_stats').doc(_userId).update({
          'dailyStreak': FieldValue.increment(1),
          'lastLoginDate': DateTime.now(),
        });
      } else {
        // Reset streak
        await _firestore.collection('user_stats').doc(_userId).update({
          'dailyStreak': 1,
          'lastLoginDate': DateTime.now(),
        });
      }

      await prefs.setString('last_login_date', today);
    }
  }

  // Get user rank
  static Future<int> getUserRank() async {
    final userStats = await getUserStats();
    if (userStats == null) return 0;

    final querySnapshot = await _firestore
        .collection('user_stats')
        .where('totalPoints', isGreaterThan: userStats.totalPoints)
        .get();

    return querySnapshot.docs.length + 1;
  }

  // Get next level requirements
  static Map<String, int> getNextLevelRequirements(int currentLevel) {
    final currentLevelPoints = (currentLevel - 1) * (currentLevel - 1) * 100;
    final nextLevelPoints = currentLevel * currentLevel * 100;
    final pointsNeeded = nextLevelPoints - currentLevelPoints;

    return {
      'currentLevel': currentLevel,
      'nextLevel': currentLevel + 1,
      'currentPoints': currentLevelPoints,
      'nextLevelPoints': nextLevelPoints,
      'pointsNeeded': pointsNeeded,
    };
  }
}

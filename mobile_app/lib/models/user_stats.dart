import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  final String userId;
  final int totalPoints;
  final int level;
  final int videosWatched;
  final int favoritesAdded;
  final int videosShared;
  final int achievementsUnlocked;
  final int dailyStreak;
  final int weeklyStreak;
  final int monthlyStreak;
  final DateTime lastLoginDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserStats({
    required this.userId,
    required this.totalPoints,
    required this.level,
    required this.videosWatched,
    required this.favoritesAdded,
    required this.videosShared,
    required this.achievementsUnlocked,
    required this.dailyStreak,
    required this.weeklyStreak,
    required this.monthlyStreak,
    required this.lastLoginDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      userId: map['userId'] ?? '',
      totalPoints: map['totalPoints'] ?? 0,
      level: map['level'] ?? 1,
      videosWatched: map['videosWatched'] ?? 0,
      favoritesAdded: map['favoritesAdded'] ?? 0,
      videosShared: map['videosShared'] ?? 0,
      achievementsUnlocked: map['achievementsUnlocked'] ?? 0,
      dailyStreak: map['dailyStreak'] ?? 0,
      weeklyStreak: map['weeklyStreak'] ?? 0,
      monthlyStreak: map['monthlyStreak'] ?? 0,
      lastLoginDate: (map['lastLoginDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'level': level,
      'videosWatched': videosWatched,
      'favoritesAdded': favoritesAdded,
      'videosShared': videosShared,
      'achievementsUnlocked': achievementsUnlocked,
      'dailyStreak': dailyStreak,
      'weeklyStreak': weeklyStreak,
      'monthlyStreak': monthlyStreak,
      'lastLoginDate': Timestamp.fromDate(lastLoginDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserStats copyWith({
    String? userId,
    int? totalPoints,
    int? level,
    int? videosWatched,
    int? favoritesAdded,
    int? videosShared,
    int? achievementsUnlocked,
    int? dailyStreak,
    int? weeklyStreak,
    int? monthlyStreak,
    DateTime? lastLoginDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      videosWatched: videosWatched ?? this.videosWatched,
      favoritesAdded: favoritesAdded ?? this.favoritesAdded,
      videosShared: videosShared ?? this.videosShared,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      weeklyStreak: weeklyStreak ?? this.weeklyStreak,
      monthlyStreak: monthlyStreak ?? this.monthlyStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate experience points needed for next level
  int get experienceToNextLevel {
    final nextLevelPoints = level * level * 100;
    return nextLevelPoints - totalPoints;
  }

  // Calculate experience points for current level
  int get experienceForCurrentLevel {
    final currentLevelPoints = (level - 1) * (level - 1) * 100;
    return totalPoints - currentLevelPoints;
  }

  // Calculate total experience points needed for current level
  int get totalExperienceForCurrentLevel {
    final currentLevelPoints = (level - 1) * (level - 1) * 100;
    final nextLevelPoints = level * level * 100;
    return nextLevelPoints - currentLevelPoints;
  }

  // Calculate progress percentage to next level
  double get progressToNextLevel {
    if (totalExperienceForCurrentLevel == 0) return 1.0;
    return experienceForCurrentLevel / totalExperienceForCurrentLevel;
  }

  // Get level title
  String get levelTitle {
    if (level >= 50) return 'Legend';
    if (level >= 40) return 'Master';
    if (level >= 30) return 'Expert';
    if (level >= 20) return 'Advanced';
    if (level >= 10) return 'Intermediate';
    return 'Beginner';
  }

  // Get level color
  int get levelColor {
    if (level >= 50) return 0xFFFFD700; // Gold
    if (level >= 40) return 0xFFC0C0C0; // Silver
    if (level >= 30) return 0xFFCD7F32; // Bronze
    if (level >= 20) return 0xFF9C27B0; // Purple
    if (level >= 10) return 0xFF2196F3; // Blue
    return 0xFF4CAF50; // Green
  }

  // Get total activity score
  int get totalActivityScore {
    return videosWatched + (favoritesAdded * 2) + (videosShared * 3) + (achievementsUnlocked * 5);
  }

  // Get engagement rate
  double get engagementRate {
    if (videosWatched == 0) return 0.0;
    return (favoritesAdded + videosShared) / videosWatched;
  }

  @override
  String toString() {
    return 'UserStats(userId: $userId, totalPoints: $totalPoints, level: $level, videosWatched: $videosWatched, favoritesAdded: $favoritesAdded, videosShared: $videosShared, achievementsUnlocked: $achievementsUnlocked, dailyStreak: $dailyStreak, weeklyStreak: $weeklyStreak, monthlyStreak: $monthlyStreak, lastLoginDate: $lastLoginDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStats &&
        other.userId == userId &&
        other.totalPoints == totalPoints &&
        other.level == level &&
        other.videosWatched == videosWatched &&
        other.favoritesAdded == favoritesAdded &&
        other.videosShared == videosShared &&
        other.achievementsUnlocked == achievementsUnlocked &&
        other.dailyStreak == dailyStreak &&
        other.weeklyStreak == weeklyStreak &&
        other.monthlyStreak == monthlyStreak &&
        other.lastLoginDate == lastLoginDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        totalPoints.hashCode ^
        level.hashCode ^
        videosWatched.hashCode ^
        favoritesAdded.hashCode ^
        videosShared.hashCode ^
        achievementsUnlocked.hashCode ^
        dailyStreak.hashCode ^
        weeklyStreak.hashCode ^
        monthlyStreak.hashCode ^
        lastLoginDate.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int target;
  final String action;
  final int points;
  final DateTime date;
  final bool isCompleted;
  final int progress;
  final DateTime? completedAt;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.action,
    required this.points,
    required this.date,
    required this.isCompleted,
    required this.progress,
    this.completedAt,
  });

  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      target: map['target'] ?? 0,
      action: map['action'] ?? '',
      points: map['points'] ?? 0,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
      progress: map['progress'] ?? 0,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'target': target,
      'action': action,
      'points': points,
      'date': Timestamp.fromDate(date),
      'isCompleted': isCompleted,
      'progress': progress,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  DailyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    int? target,
    String? action,
    int? points,
    DateTime? date,
    bool? isCompleted,
    int? progress,
    DateTime? completedAt,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      target: target ?? this.target,
      action: action ?? this.action,
      points: points ?? this.points,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Get progress percentage
  double get progressPercentage {
    if (target == 0) return 0.0;
    return (progress / target).clamp(0.0, 1.0);
  }

  // Get remaining progress
  int get remainingProgress {
    return (target - progress).clamp(0, target);
  }

  // Check if challenge is expired
  bool get isExpired {
    final now = DateTime.now();
    final challengeDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    return challengeDate.isBefore(today);
  }

  // Get challenge difficulty
  String get difficulty {
    if (target <= 2) return 'Easy';
    if (target <= 5) return 'Medium';
    if (target <= 10) return 'Hard';
    return 'Expert';
  }

  // Get difficulty color
  int get difficultyColor {
    switch (difficulty) {
      case 'Easy':
        return 0xFF4CAF50; // Green
      case 'Medium':
        return 0xFFFF9800; // Orange
      case 'Hard':
        return 0xFFF44336; // Red
      case 'Expert':
        return 0xFF9C27B0; // Purple
      default:
        return 0xFF2196F3; // Blue
    }
  }

  // Get action icon
  String get actionIcon {
    switch (action) {
      case 'watch_video':
        return '🎬';
      case 'add_favorite':
        return '⭐';
      case 'share_video':
        return '🦋';
      case 'explore_categories':
        return '🔍';
      case 'daily_login':
        return '📱';
      case 'complete_challenge':
        return '🎯';
      default:
        return '📋';
    }
  }

  // Get action display name
  String get actionDisplayName {
    switch (action) {
      case 'watch_video':
        return 'Watch Videos';
      case 'add_favorite':
        return 'Add Favorites';
      case 'share_video':
        return 'Share Videos';
      case 'explore_categories':
        return 'Explore Categories';
      case 'daily_login':
        return 'Daily Login';
      case 'complete_challenge':
        return 'Complete Challenge';
      default:
        return 'Unknown Action';
    }
  }

  // Get time remaining
  String get timeRemaining {
    if (isCompleted || isExpired) return 'Completed';
    
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final difference = endOfDay.difference(now);
    
    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Less than 1m left';
    }
  }

  // Get progress text
  String get progressText {
    if (isCompleted) {
      return 'Completed!';
    }
    return '$progress/$target';
  }

  // Get reward text
  String get rewardText {
    return '+$points points';
  }

  @override
  String toString() {
    return 'DailyChallenge(id: $id, title: $title, description: $description, target: $target, action: $action, points: $points, date: $date, isCompleted: $isCompleted, progress: $progress, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyChallenge &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.target == target &&
        other.action == action &&
        other.points == points &&
        other.date == date &&
        other.isCompleted == isCompleted &&
        other.progress == progress &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        target.hashCode ^
        action.hashCode ^
        points.hashCode ^
        date.hashCode ^
        isCompleted.hashCode ^
        progress.hashCode ^
        completedAt.hashCode;
  }
}

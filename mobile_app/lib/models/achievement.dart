import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int points;
  final String icon;
  final DateTime unlockedAt;
  final bool isRare;
  final String category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
    required this.unlockedAt,
    this.isRare = false,
    this.category = 'general',
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      points: map['points'] ?? 0,
      icon: map['icon'] ?? '🏆',
      unlockedAt: (map['unlockedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRare: map['isRare'] ?? false,
      category: map['category'] ?? 'general',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'icon': icon,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      'isRare': isRare,
      'category': category,
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    int? points,
    String? icon,
    DateTime? unlockedAt,
    bool? isRare,
    String? category,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isRare: isRare ?? this.isRare,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, description: $description, points: $points, icon: $icon, unlockedAt: $unlockedAt, isRare: $isRare, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.points == points &&
        other.icon == icon &&
        other.unlockedAt == unlockedAt &&
        other.isRare == isRare &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        points.hashCode ^
        icon.hashCode ^
        unlockedAt.hashCode ^
        isRare.hashCode ^
        category.hashCode;
  }
}

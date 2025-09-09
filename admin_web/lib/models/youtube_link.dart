import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Added for Color

class YouTubeLink {
  final String? id;
  final String title;
  final String url;
  final DateTime createdAt;
  final int priority; // Mức độ ưu tiên: 1 (cao nhất) đến 5 (thấp nhất)

  YouTubeLink({
    this.id,
    required this.title,
    required this.url,
    required this.createdAt,
    this.priority = 3, // Mặc định là mức trung bình
  });

  // Tạo từ Firestore document
  factory YouTubeLink.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return YouTubeLink(
      id: doc.id,
      title: data['title'] ?? '',
      url: data['url'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      priority: data['priority'] ?? 3,
    );
  }

  // Chuyển thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'url': url,
      'created_at': Timestamp.fromDate(createdAt),
      'priority': priority,
    };
  }

  // Tạo bản sao với thay đổi
  YouTubeLink copyWith({
    String? id,
    String? title,
    String? url,
    DateTime? createdAt,
    int? priority,
  }) {
    return YouTubeLink(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
    );
  }

  // Lấy tên mức độ ưu tiên
  String get priorityName {
    switch (priority) {
      case 1:
        return 'Rất cao';
      case 2:
        return 'Cao';
      case 3:
        return 'Trung bình';
      case 4:
        return 'Thấp';
      case 5:
        return 'Rất thấp';
      default:
        return 'Trung bình';
    }
  }

  // Lấy màu sắc cho mức độ ưu tiên
  Color get priorityColor {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.grey;
      case 5:
        return Colors.grey.shade400;
      default:
        return Colors.blue;
    }
  }

  @override
  String toString() {
    return 'YouTubeLink(id: $id, title: $title, url: $url, createdAt: $createdAt, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YouTubeLink &&
        other.id == id &&
        other.title == title &&
        other.url == url &&
        other.createdAt == createdAt &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ url.hashCode ^ createdAt.hashCode ^ priority.hashCode;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class YouTubeLink {
  final String? id;
  final String title;
  final String url;
  final DateTime createdAt;
  final String? videoTitle;
  final String? videoDescription;
  final String? videoDuration;
  final int priority; // Mức độ ưu tiên: 1 (cao nhất) đến 5 (thấp nhất)
  final String? category;
  final String? status;
  final int clickCount; // Số lượt click
  final DateTime? lastClickedAt; // Thời gian click cuối cùng
  final double trendingScore; // Điểm trending

  YouTubeLink({
    this.id,
    required this.title,
    required this.url,
    required this.createdAt,
    this.videoTitle,
    this.videoDescription,
    this.videoDuration,
    this.priority = 3, // Mặc định là mức trung bình
    this.category,
    this.status = 'live',
    this.clickCount = 0,
    this.lastClickedAt,
    this.trendingScore = 0.0,
  });

  // Tạo từ Firestore document
  factory YouTubeLink.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return YouTubeLink(
      id: doc.id,
      title: data['title'] ?? '',
      url: data['url'] ?? '',
      createdAt: data['created_at'] != null 
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      videoTitle: data['video_title'],
      videoDescription: data['video_description'],
      videoDuration: data['video_duration'],
      priority: data['priority'] ?? 3,
      category: data['category'],
      status: data['status'] ?? 'live',
      clickCount: data['click_count'] ?? 0,
      lastClickedAt: data['last_clicked_at'] != null 
          ? (data['last_clicked_at'] as Timestamp).toDate() 
          : null,
      trendingScore: (data['trending_score'] ?? 0.0).toDouble(),
    );
  }

  // Tạo từ Map
  factory YouTubeLink.fromMap(Map<String, dynamic> data) {
    return YouTubeLink(
      id: data['id'],
      title: data['title'] ?? '',
      url: data['url'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      videoTitle: data['video_title'],
      videoDescription: data['video_description'],
      videoDuration: data['video_duration'],
      priority: data['priority'] ?? 3,
      category: data['category'],
      status: data['status'] ?? 'live',
    );
  }

  // Lấy video ID từ URL YouTube
  String? get videoId {
    RegExp regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    
    if (regExp.hasMatch(url)) {
      return regExp.firstMatch(url)!.group(2);
    }
    return null;
  }

  // URL thumbnail YouTube
  String get thumbnailUrl {
    final videoId = this.videoId;
    if (videoId != null) {
      return getYouTubeThumbnail(videoId, quality: 'mqdefault');
    }
    return placeholderVideoUrl;
  }

  // URL thumbnail chất lượng cao
  String get highQualityThumbnailUrl {
    final videoId = this.videoId;
    if (videoId != null) {
      return getYouTubeThumbnail(videoId, quality: 'hqdefault');
    }
    return placeholderVideoUrl;
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
    return getPriorityColor(priority);
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

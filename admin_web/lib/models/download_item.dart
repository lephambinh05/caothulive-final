import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DownloadItem {
  final String id;
  final String platform; // 'ios' or 'android'
  final String version;
  final String size;
  final String downloadUrl;
  final String description;
  final DateTime releaseDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DownloadItem({
    required this.id,
    required this.platform,
    required this.version,
    required this.size,
    required this.downloadUrl,
    required this.description,
    required this.releaseDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DownloadItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DownloadItem(
      id: doc.id,
      platform: data['platform'] ?? '',
      version: data['version'] ?? '',
      size: data['size'] ?? '',
      downloadUrl: data['download_url'] ?? '',
      description: data['description'] ?? '',
      releaseDate: (data['release_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['is_active'] ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'platform': platform,
      'version': version,
      'size': size,
      'download_url': downloadUrl,
      'description': description,
      'release_date': Timestamp.fromDate(releaseDate),
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  DownloadItem copyWith({
    String? id,
    String? platform,
    String? version,
    String? size,
    String? downloadUrl,
    String? description,
    DateTime? releaseDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      version: version ?? this.version,
      size: size ?? this.size,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      description: description ?? this.description,
      releaseDate: releaseDate ?? this.releaseDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get platformName {
    switch (platform.toLowerCase()) {
      case 'ios':
        return 'iOS';
      case 'android':
        return 'Android';
      default:
        return platform;
    }
  }

  Color get platformColor {
    switch (platform.toLowerCase()) {
      case 'ios':
        return const Color(0xFF007AFF);
      case 'android':
        return const Color(0xFF3DDC84);
      default:
        return Colors.grey;
    }
  }
}

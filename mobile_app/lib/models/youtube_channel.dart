import 'package:cloud_firestore/cloud_firestore.dart';

class YouTubeChannel {
  final String id;
  final String channelId;
  final String channelName;
  final String channelUrl;
  final String? avatarUrl;
  final String? description;
  final int? subscriberCount;
  final int? videoCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  YouTubeChannel({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.channelUrl,
    this.avatarUrl,
    this.description,
    this.subscriberCount,
    this.videoCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory YouTubeChannel.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return YouTubeChannel(
      id: doc.id,
      channelId: data['channel_id'] ?? '',
      channelName: data['channel_name'] ?? '',
      channelUrl: data['channel_url'] ?? '',
      avatarUrl: data['avatar_url'],
      description: data['description'],
      subscriberCount: data['subscriber_count'],
      videoCount: data['video_count'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channel_id': channelId,
      'channel_name': channelName,
      'channel_url': channelUrl,
      'avatar_url': avatarUrl,
      'description': description,
      'subscriber_count': subscriberCount,
      'video_count': videoCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get formattedSubscriberCount {
    if (subscriberCount == null) return 'N/A';
    
    if (subscriberCount! >= 1000000) {
      return '${(subscriberCount! / 1000000).toStringAsFixed(1)}M';
    } else if (subscriberCount! >= 1000) {
      return '${(subscriberCount! / 1000).toStringAsFixed(1)}K';
    } else {
      return subscriberCount.toString();
    }
  }

  String get formattedVideoCount {
    if (videoCount == null) return 'N/A';
    
    if (videoCount! >= 1000000) {
      return '${(videoCount! / 1000000).toStringAsFixed(1)}M';
    } else if (videoCount! >= 1000) {
      return '${(videoCount! / 1000).toStringAsFixed(1)}K';
    } else {
      return videoCount.toString();
    }
  }
}

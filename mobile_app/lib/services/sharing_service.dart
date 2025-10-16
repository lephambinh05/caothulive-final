import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/youtube_link.dart';
import '../models/youtube_channel.dart';
import 'gamification_service.dart';

class SharingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Share video
  static Future<void> shareVideo(YouTubeLink video) async {
    final shareText = _buildVideoShareText(video);
    final shareUrl = video.url;

    try {
      await Share.share(
        '$shareText\n\n$shareUrl',
        subject: 'Check out this video: ${video.videoTitle ?? video.title}',
      );

      // Track sharing action
      await GamificationService.trackAction('share_video');
      
      // Log sharing event
      await _logSharingEvent('video', video.id, shareUrl);
      
    } catch (e) {
      debugPrint('Error sharing video: $e');
    }
  }

  // Share channel
  static Future<void> shareChannel(YouTubeChannel channel) async {
    final shareText = _buildChannelShareText(channel);
    final shareUrl = channel.channelUrl;

    try {
      await Share.share(
        '$shareText\n\n$shareUrl',
        subject: 'Check out this channel: ${channel.channelName}',
      );

      // Track sharing action
      await GamificationService.trackAction('share_channel');
      
      // Log sharing event
      await _logSharingEvent('channel', channel.id, shareUrl);
      
    } catch (e) {
      debugPrint('Error sharing channel: $e');
    }
  }

  // Share app
  static Future<void> shareApp() async {
    const shareText = '''
🎥 VideoHub Pro - Smart YouTube Manager

Discover and manage your favorite YouTube content with our intelligent app!

✨ Features:
• Smart video recommendations
• Advanced search and filters
• Favorites management
• Live stream notifications
• Achievement system
• Daily challenges

Download now and join the community!
''';

    const shareUrl = 'https://play.google.com/store/apps/details?id=com.quanlylink20m.app';

    try {
      await Share.share(
        '$shareText\n\n$shareUrl',
        subject: 'VideoHub Pro - Smart YouTube Manager',
      );

      // Track sharing action
      await GamificationService.trackAction('share_app');
      
    } catch (e) {
      debugPrint('Error sharing app: $e');
    }
  }

  // Share achievement
  static Future<void> shareAchievement(String title, String description) async {
    final shareText = '''
🏆 Achievement Unlocked!

$title
$description

I just unlocked this achievement in VideoHub Pro! 

Download the app and start your journey:
https://play.google.com/store/apps/details?id=com.quanlylink20m.app
''';

    try {
      await Share.share(
        shareText,
        subject: 'Achievement Unlocked: $title',
      );

      // Track sharing action
      await GamificationService.trackAction('share_achievement');
      
    } catch (e) {
      debugPrint('Error sharing achievement: $e');
    }
  }

  // Share daily challenge
  static Future<void> shareDailyChallenge(String title, String description) async {
    final shareText = '''
🎯 Daily Challenge

$title
$description

Join me in this daily challenge in VideoHub Pro!

Download the app:
https://play.google.com/store/apps/details?id=com.quanlylink20m.app
''';

    try {
      await Share.share(
        shareText,
        subject: 'Daily Challenge: $title',
      );

      // Track sharing action
      await GamificationService.trackAction('share_challenge');
      
    } catch (e) {
      debugPrint('Error sharing challenge: $e');
    }
  }

  // Share playlist
  static Future<void> sharePlaylist(String playlistName, List<YouTubeLink> videos) async {
    final shareText = '''
📋 Playlist: $playlistName

${videos.length} videos in this playlist:

${videos.take(5).map((v) => '• ${v.videoTitle}').join('\n')}
${videos.length > 5 ? '... and ${videos.length - 5} more videos' : ''}

Created with VideoHub Pro - Smart YouTube Manager
''';

    try {
      await Share.share(
        shareText,
        subject: 'Playlist: $playlistName',
      );

      // Track sharing action
      await GamificationService.trackAction('share_playlist');
      
    } catch (e) {
      debugPrint('Error sharing playlist: $e');
    }
  }

  // Share to specific platform
  static Future<void> shareToPlatform(
    String platform,
    String content,
    String url,
  ) async {
    String shareUrl = '';

    switch (platform.toLowerCase()) {
      case 'facebook':
        shareUrl = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}';
        break;
      case 'twitter':
        shareUrl = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(content)}&url=${Uri.encodeComponent(url)}';
        break;
      case 'whatsapp':
        shareUrl = 'https://wa.me/?text=${Uri.encodeComponent('$content $url')}';
        break;
      case 'telegram':
        shareUrl = 'https://t.me/share/url?url=${Uri.encodeComponent(url)}&text=${Uri.encodeComponent(content)}';
        break;
      case 'instagram':
        // Instagram doesn't support direct sharing via URL
        await Share.share('$content\n\n$url');
        return;
      default:
        await Share.share('$content\n\n$url');
        return;
    }

    try {
      if (await canLaunchUrl(Uri.parse(shareUrl))) {
        await launchUrl(Uri.parse(shareUrl), mode: LaunchMode.externalApplication);
      } else {
        // Fallback to general sharing
        await Share.share('$content\n\n$url');
      }
    } catch (e) {
      debugPrint('Error sharing to $platform: $e');
      // Fallback to general sharing
      await Share.share('$content\n\n$url');
    }
  }

  // Build video share text
  static String _buildVideoShareText(YouTubeLink video) {
    return '''
🎥 ${video.videoTitle ?? video.title}

📺 Channel: ${video.title}
⭐ Priority: ${_getPriorityText(video.priority)}
📅 ${_formatDate(video.createdAt)}

${video.videoDescription?.isNotEmpty == true ? '${video.videoDescription!.substring(0, video.videoDescription!.length > 100 ? 100 : video.videoDescription!.length)}...' : ''}

Shared from VideoHub Pro - Smart YouTube Manager
''';
  }

  // Build channel share text
  static String _buildChannelShareText(YouTubeChannel channel) {
    return '''
📺 ${channel.channelName}

${channel.description?.isNotEmpty == true ? '${channel.description!.substring(0, channel.description!.length > 150 ? 150 : channel.description!.length)}...' : ''}

👥 Subscribers: ${_formatNumber(channel.subscriberCount)}
📹 Videos: ${_formatNumber(channel.videoCount)}

Shared from VideoHub Pro - Smart YouTube Manager
''';
  }

  // Get priority text
  static String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '🔴 Critical';
      case 2:
        return '🟠 High';
      case 3:
        return '🟡 Medium';
      case 4:
        return '🔵 Low';
      case 5:
        return '⚪ Very Low';
      default:
        return '🔵 Normal';
    }
  }

  // Format date
  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Format number
  static String _formatNumber(int? number) {
    if (number == null) return 'N/A';
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  // Log sharing event
  static Future<void> _logSharingEvent(String type, String itemId, String url) async {
    try {
      await _firestore.collection('sharing_events').add({
        'type': type,
        'itemId': itemId,
        'url': url,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': 'current_user', // In real app, get from auth
      });
    } catch (e) {
      debugPrint('Error logging sharing event: $e');
    }
  }

  // Get sharing statistics
  static Future<Map<String, int>> getSharingStats() async {
    try {
      final querySnapshot = await _firestore
          .collection('sharing_events')
          .where('userId', isEqualTo: 'current_user')
          .get();

      final stats = <String, int>{
        'total_shares': 0,
        'video_shares': 0,
        'channel_shares': 0,
        'app_shares': 0,
        'achievement_shares': 0,
      };

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        stats['total_shares'] = (stats['total_shares'] ?? 0) + 1;
        
        final type = data['type'] as String;
        switch (type) {
          case 'video':
            stats['video_shares'] = (stats['video_shares'] ?? 0) + 1;
            break;
          case 'channel':
            stats['channel_shares'] = (stats['channel_shares'] ?? 0) + 1;
            break;
          case 'app':
            stats['app_shares'] = (stats['app_shares'] ?? 0) + 1;
            break;
          case 'achievement':
            stats['achievement_shares'] = (stats['achievement_shares'] ?? 0) + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      debugPrint('Error getting sharing stats: $e');
      return {};
    }
  }

  // Get popular shared content
  static Future<List<Map<String, dynamic>>> getPopularSharedContent({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('sharing_events')
          .limit(limit * 2) // Get more to filter
          .get();

      final Map<String, int> shareCounts = {};
      final Map<String, Map<String, dynamic>> contentData = {};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final itemId = data['itemId'] as String;
        final type = data['type'] as String;
        final url = data['url'] as String;

        shareCounts[itemId] = (shareCounts[itemId] ?? 0) + 1;
        
        if (!contentData.containsKey(itemId)) {
          contentData[itemId] = {
            'id': itemId,
            'type': type,
            'url': url,
            'shareCount': 0,
          };
        }
      }

      // Update share counts
      for (final entry in shareCounts.entries) {
        if (contentData.containsKey(entry.key)) {
          contentData[entry.key]!['shareCount'] = entry.value;
        }
      }

      // Sort by share count and return top items
      final sortedItems = contentData.values.toList()
        ..sort((a, b) => (b['shareCount'] as int).compareTo(a['shareCount'] as int));

      return sortedItems.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting popular shared content: $e');
      return [];
    }
  }
}

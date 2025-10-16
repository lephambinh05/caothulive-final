import 'package:flutter/material.dart';

// API Configuration
const String apiBaseUrl = 'https://api.caothulive.com/api'; // ĐƯỜNG DẪN API
const String websiteDomain = 'https://caothulive.com'; // ĐƯỜNG DẪN WEBSITE

// YouTube API Configuration
const String youtubeThumbnailBaseUrl = 'https://img.youtube.com/vi';
const String youtubeOembedUrl = 'https://www.youtube.com/oembed';

// Placeholder URLs
const String placeholderAvatarUrl = 'https://via.placeholder.com/150/FF0000/FFFFFF';
const String placeholderThumbnailUrl = 'https://via.placeholder.com/80x80/cccccc/666666';
const String placeholderVideoUrl = 'https://via.placeholder.com/1280x720?text=YouTube+Video';

// Social Media URLs
const String facebookBaseUrl = 'https://facebook.com';
const String youtubeBaseUrl = 'https://www.youtube.com';

// Default Settings
const Map<String, String> defaultSettings = {
  'webDomain': websiteDomain,
  'facebook': '$facebookBaseUrl/lephambinh.mmo',
};

// YouTube Thumbnail Helper Functions
String getYouTubeThumbnail(String videoId, {String quality = 'hqdefault'}) {
  return '$youtubeThumbnailBaseUrl/$videoId/$quality.jpg';
}

String getYouTubeMaxResThumbnail(String videoId) {
  return videoId.isNotEmpty 
      ? '$youtubeThumbnailBaseUrl/$videoId/maxresdefault.jpg' 
      : placeholderVideoUrl;
}

String getYouTubeOEmbedUrl(String url) {
  return '$youtubeOembedUrl?format=json&url=${Uri.encodeComponent(url)}';
}

// Avatar Helper Functions
String getChannelAvatar(String channelId) {
  final initials = channelId.length >= 2 
      ? channelId.substring(0, 2).toUpperCase() 
      : channelId.toUpperCase();
  return '$placeholderAvatarUrl?text=$initials';
}

// URL Helper Functions
String ensureHttps(String url) {
  return url.startsWith('http') ? url : 'https://$url';
}

// Priority Colors

Color getPriorityColor(int priority) {
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

// App Theme
ThemeData getAppTheme() {
  return ThemeData(
    primarySwatch: Colors.red,
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );
}

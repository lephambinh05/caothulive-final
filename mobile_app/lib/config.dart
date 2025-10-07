import 'package:flutter/material.dart';

// API Configuration
const String API_BASE_URL = 'https://api.caothulive.com/api'; // ĐƯỜNG DẪN API
const String WEBSITE_DOMAIN = 'https://caothulive.com'; // ĐƯỜNG DẪN WEBSITE

// YouTube API Configuration
const String YOUTUBE_THUMBNAIL_BASE_URL = 'https://img.youtube.com/vi';
const String YOUTUBE_OEMBED_URL = 'https://www.youtube.com/oembed';

// Placeholder URLs
const String PLACEHOLDER_AVATAR_URL = 'https://via.placeholder.com/150/FF0000/FFFFFF';
const String PLACEHOLDER_THUMBNAIL_URL = 'https://via.placeholder.com/80x80/cccccc/666666';
const String PLACEHOLDER_VIDEO_URL = 'https://via.placeholder.com/1280x720?text=YouTube+Video';

// Social Media URLs
const String FACEBOOK_BASE_URL = 'https://facebook.com';
const String YOUTUBE_BASE_URL = 'https://www.youtube.com';

// Default Settings
const Map<String, String> DEFAULT_SETTINGS = {
  'webDomain': WEBSITE_DOMAIN,
  'facebook': '$FACEBOOK_BASE_URL/lephambinh.mmo',
};

// YouTube Thumbnail Helper Functions
String getYouTubeThumbnail(String videoId, {String quality = 'hqdefault'}) {
  return '$YOUTUBE_THUMBNAIL_BASE_URL/$videoId/$quality.jpg';
}

String getYouTubeMaxResThumbnail(String videoId) {
  return videoId.isNotEmpty 
      ? '$YOUTUBE_THUMBNAIL_BASE_URL/$videoId/maxresdefault.jpg' 
      : PLACEHOLDER_VIDEO_URL;
}

String getYouTubeOEmbedUrl(String url) {
  return '$YOUTUBE_OEMBED_URL?format=json&url=${Uri.encodeComponent(url)}';
}

// Avatar Helper Functions
String getChannelAvatar(String channelId) {
  final initials = channelId.length >= 2 
      ? channelId.substring(0, 2).toUpperCase() 
      : channelId.toUpperCase();
  return '$PLACEHOLDER_AVATAR_URL?text=$initials';
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
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
    
    // Initialize WorkManager for background tasks
    // await Workmanager().initialize(
    //   callbackDispatcher,
    //   isInDebugMode: false,
    // );

    _initialized = true;
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    final status = await Permission.notification.request();
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Handle different notification types
      _handleNotificationPayload(payload);
    }
  }

  // Handle notification payload
  static void _handleNotificationPayload(String payload) {
    final data = payload.split('|');
    final type = data[0];
    
    switch (type) {
      case 'live_stream':
        _openLiveStream(data[1]);
        break;
      case 'new_video':
        _openVideo(data[1]);
        break;
      case 'achievement':
        _openAchievements();
        break;
      case 'challenge':
        _openChallenges();
        break;
    }
  }

  // Open live stream
  static void _openLiveStream(String channelId) {
    // Implementation to open live stream
    debugPrint('Opening live stream for channel: $channelId');
  }

  // Open video
  static void _openVideo(String videoId) {
    // Implementation to open video
    debugPrint('Opening video: $videoId');
  }

  // Open achievements
  static void _openAchievements() {
    // Implementation to open achievements
    debugPrint('Opening achievements');
  }

  // Open challenges
  static void _openChallenges() {
    // Implementation to open challenges
    debugPrint('Opening challenges');
  }

  // Show live stream notification
  static Future<void> showLiveStreamNotification({
    required String channelName,
    required String channelId,
    required String title,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'live_streams',
      'Live Stream Notifications',
      channelDescription: 'Notifications for live streams from favorite channels',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      channelId.hashCode,
      '🔴 $channelName đang LIVE!',
      title,
      details,
      payload: 'live_stream|$channelId',
    );
  }

  // Show new video notification
  static Future<void> showNewVideoNotification({
    required String channelName,
    required String videoTitle,
    required String videoId,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'new_videos',
      'New Video Notifications',
      channelDescription: 'Notifications for new videos from favorite channels',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      videoId.hashCode,
      '📺 Video mới từ $channelName',
      videoTitle,
      details,
      payload: 'new_video|$videoId',
    );
  }

  // Show achievement notification
  static Future<void> showAchievementNotification({
    required String title,
    required String description,
    required String achievementId,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'achievements',
      'Achievement Notifications',
      channelDescription: 'Notifications for unlocked achievements',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      achievementId.hashCode,
      '🏆 Thành tích mới!',
      title,
      details,
      payload: 'achievement|$achievementId',
    );
  }

  // Show challenge notification
  static Future<void> showChallengeNotification({
    required String title,
    required String description,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'challenges',
      'Daily Challenge Notifications',
      channelDescription: 'Notifications for daily challenges',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      'daily_challenge'.hashCode,
      '🎯 Thử thách hàng ngày',
      title,
      details,
      payload: 'challenge|daily',
    );
  }

  // Schedule daily challenge notification
  static Future<void> scheduleDailyChallenge() async {
    // await Workmanager().registerPeriodicTask(
    //   'daily_challenge',
    //   'dailyChallengeTask',
    //   frequency: const Duration(hours: 24),
    //   initialDelay: const Duration(minutes: 1),
    // );
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}

// Background task callback
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     switch (task) {
//       case 'dailyChallengeTask':
//         await _handleDailyChallenge();
//         break;
//       case 'checkLiveStreams':
//         await _checkLiveStreams();
//         break;
//       case 'checkNewVideos':
//         await _checkNewVideos();
//         break;
//     }
//     return Future.value(true);
//   });
// }

// Handle daily challenge
// Future<void> _handleDailyChallenge() async {
//   // Implementation for daily challenge
//   debugPrint('Handling daily challenge');
// }

// Check live streams
// Future<void> _checkLiveStreams() async {
//   // Implementation to check for live streams
//   debugPrint('Checking live streams');
// }

// Check new videos
// Future<void> _checkNewVideos() async {
//   // Implementation to check for new videos
//   debugPrint('Checking new videos');
// }

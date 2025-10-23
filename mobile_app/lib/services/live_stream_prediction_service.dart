import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/youtube_channel.dart';

class LiveStreamPredictionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Predict when a channel is likely to go live
  static Future<Map<String, dynamic>> predictLiveStreamTime(String channelId) async {
    try {
      // Get channel's historical live stream data
      final channelDoc = await _firestore
          .collection('youtube_channels')
          .doc(channelId)
          .get();
      
      if (!channelDoc.exists) {
        return {'prediction': null, 'confidence': 0.0};
      }
      
      final channel = YouTubeChannel.fromFirestore(channelDoc);
      
      // Get historical live stream times
      final liveStreamHistory = await _getLiveStreamHistory(channelId);
      
      if (liveStreamHistory.isEmpty) {
        return {'prediction': null, 'confidence': 0.0};
      }
      
      // Analyze patterns in live stream times
      final prediction = _analyzeLiveStreamPatterns(liveStreamHistory);
      
      // Update channel with prediction
      await _updateChannelPrediction(channelId, prediction);
      
      return prediction;
    } catch (e) {
      debugPrint('Error predicting live stream time: $e');
      return {'prediction': null, 'confidence': 0.0};
    }
  }
  
  // Get historical live stream data
  static Future<List<Map<String, dynamic>>> _getLiveStreamHistory(String channelId) async {
    final snapshot = await _firestore
        .collection('live_stream_history')
        .doc(channelId)
        .collection('streams')
        .orderBy('started_at', descending: true)
        .limit(50)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
  
  // Analyze patterns in live stream times
  static Map<String, dynamic> _analyzeLiveStreamPatterns(List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return {'prediction': null, 'confidence': 0.0};
    }
    
    // Extract hours and days of week from historical data
    final hours = <int>[];
    final daysOfWeek = <int>[];
    
    for (final stream in history) {
      final startedAt = (stream['started_at'] as Timestamp).toDate();
      hours.add(startedAt.hour);
      daysOfWeek.add(startedAt.weekday);
    }
    
    // Calculate most common hour
    final hourCounts = <int, int>{};
    for (final hour in hours) {
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    final mostCommonHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    // Calculate most common day of week
    final dayCounts = <int, int>{};
    for (final day in daysOfWeek) {
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    
    final mostCommonDay = dayCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    // Calculate confidence based on consistency
    final totalStreams = history.length;
    final hourConsistency = hourCounts[mostCommonHour]! / totalStreams;
    final dayConsistency = dayCounts[mostCommonDay]! / totalStreams;
    final confidence = (hourConsistency + dayConsistency) / 2;
    
    // Predict next live stream time
    final now = DateTime.now();
    final nextLiveTime = _calculateNextLiveTime(now, mostCommonDay, mostCommonHour);
    
    return {
      'prediction': nextLiveTime,
      'confidence': confidence,
      'most_common_hour': mostCommonHour,
      'most_common_day': mostCommonDay,
      'total_streams_analyzed': totalStreams,
    };
  }
  
  // Calculate next predicted live stream time
  static DateTime _calculateNextLiveTime(DateTime now, int targetDay, int targetHour) {
    // Find next occurrence of target day and hour
    var nextLive = DateTime(now.year, now.month, now.day, targetHour);
    
    // If today is the target day but hour has passed, or if it's not the target day
    if (now.weekday != targetDay || (now.weekday == targetDay && now.hour >= targetHour)) {
      // Find next occurrence
      final daysUntilTarget = (targetDay - now.weekday) % 7;
      if (daysUntilTarget == 0) {
        daysUntilTarget = 7; // Next week
      }
      nextLive = nextLive.add(Duration(days: daysUntilTarget));
    }
    
    return nextLive;
  }
  
  // Update channel with prediction
  static Future<void> _updateChannelPrediction(String channelId, Map<String, dynamic> prediction) async {
    await _firestore.collection('youtube_channels').doc(channelId).update({
      'predicted_live_time': prediction['prediction'] != null 
          ? Timestamp.fromDate(prediction['prediction'] as DateTime)
          : null,
      'prediction_confidence': prediction['confidence'],
      'last_prediction_update': FieldValue.serverTimestamp(),
    });
  }
  
  // Get channels likely to go live soon
  static Future<List<YouTubeChannel>> getChannelsGoingLiveSoon({
    Duration? timeWindow,
  }) async {
    final window = timeWindow ?? const Duration(hours: 2);
    final cutoffTime = DateTime.now().add(window);
    
    final snapshot = await _firestore
        .collection('youtube_channels')
        .where('predicted_live_time', isLessThan: Timestamp.fromDate(cutoffTime))
        .where('predicted_live_time', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('predicted_live_time')
        .get();
    
    return snapshot.docs
        .map((doc) => YouTubeChannel.fromFirestore(doc))
        .toList();
  }
  
  // Record live stream start
  static Future<void> recordLiveStreamStart(String channelId, DateTime startTime) async {
    await _firestore
        .collection('live_stream_history')
        .doc(channelId)
        .collection('streams')
        .add({
      'started_at': Timestamp.fromDate(startTime),
      'recorded_at': FieldValue.serverTimestamp(),
    });
    
    // Update channel's last live time
    await _firestore.collection('youtube_channels').doc(channelId).update({
      'last_live_time': Timestamp.fromDate(startTime),
      'is_currently_live': true,
    });
  }
  
  // Record live stream end
  static Future<void> recordLiveStreamEnd(String channelId, DateTime endTime) async {
    await _firestore.collection('youtube_channels').doc(channelId).update({
      'is_currently_live': false,
      'last_stream_end': Timestamp.fromDate(endTime),
    });
  }
  
  // Get live stream statistics for a channel
  static Future<Map<String, dynamic>> getChannelLiveStats(String channelId) async {
    final history = await _getLiveStreamHistory(channelId);
    
    if (history.isEmpty) {
      return {
        'total_streams': 0,
        'average_duration': 0,
        'most_active_hour': null,
        'most_active_day': null,
        'stream_frequency': 0,
      };
    }
    
    // Calculate statistics
    final totalStreams = history.length;
    final durations = <int>[];
    final hours = <int>[];
    final days = <int>[];
    
    for (final stream in history) {
      final startTime = (stream['started_at'] as Timestamp).toDate();
      final endTime = stream['ended_at'] != null 
          ? (stream['ended_at'] as Timestamp).toDate()
          : startTime.add(const Duration(hours: 2)); // Default 2 hours if no end time
      
      durations.add(endTime.difference(startTime).inMinutes);
      hours.add(startTime.hour);
      days.add(startTime.weekday);
    }
    
    // Calculate averages and most common values
    final averageDuration = durations.reduce((a, b) => a + b) / durations.length;
    
    final hourCounts = <int, int>{};
    for (final hour in hours) {
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    final mostActiveHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    final dayCounts = <int, int>{};
    for (final day in days) {
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    final mostActiveDay = dayCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    // Calculate stream frequency (streams per week)
    final firstStream = history.last['started_at'] as Timestamp;
    final lastStream = history.first['started_at'] as Timestamp;
    final timeSpan = lastStream.toDate().difference(firstStream.toDate()).inDays;
    final streamFrequency = timeSpan > 0 ? (totalStreams / timeSpan * 7) : 0;
    
    return {
      'total_streams': totalStreams,
      'average_duration': averageDuration,
      'most_active_hour': mostActiveHour,
      'most_active_day': mostActiveDay,
      'stream_frequency': streamFrequency,
    };
  }
  
  // Batch predict for all channels
  static Future<void> batchPredictAllChannels() async {
    final channelsSnapshot = await _firestore
        .collection('youtube_channels')
        .get();
    
    for (final doc in channelsSnapshot.docs) {
      try {
        await predictLiveStreamTime(doc.id);
        // Add delay to avoid overwhelming Firestore
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        debugPrint('Error predicting for channel ${doc.id}: $e');
      }
    }
  }
  
  // Get prediction accuracy for a channel
  static Future<double> getPredictionAccuracy(String channelId) async {
    final predictions = await _firestore
        .collection('prediction_accuracy')
        .doc(channelId)
        .collection('predictions')
        .get();
    
    if (predictions.docs.isEmpty) {
      return 0.0;
    }
    
    int correctPredictions = 0;
    int totalPredictions = predictions.docs.length;
    
    for (final doc in predictions.docs) {
      final data = doc.data();
      final predictedTime = (data['predicted_time'] as Timestamp).toDate();
      final actualTime = data['actual_time'] != null 
          ? (data['actual_time'] as Timestamp).toDate()
          : null;
      
      if (actualTime != null) {
        final timeDifference = actualTime.difference(predictedTime).abs();
        // Consider prediction correct if within 2 hours
        if (timeDifference.inHours <= 2) {
          correctPredictions++;
        }
      }
    }
    
    return correctPredictions / totalPredictions;
  }
}

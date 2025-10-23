import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String id;
  final String playerName;
  final int score;
  final int timeSpent; // in seconds
  final DateTime playedAt;
  final String gameType;
  final Map<String, dynamic> gameStats; // Additional game-specific stats

  LeaderboardEntry({
    required this.id,
    required this.playerName,
    required this.score,
    required this.timeSpent,
    required this.playedAt,
    required this.gameType,
    this.gameStats = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'score': score,
      'timeSpent': timeSpent,
      'playedAt': Timestamp.fromDate(playedAt),
      'gameType': gameType,
      'gameStats': gameStats,
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, String id) {
    return LeaderboardEntry(
      id: id,
      playerName: map['playerName'] ?? '',
      score: map['score'] ?? 0,
      timeSpent: map['timeSpent'] ?? 0,
      playedAt: (map['playedAt'] as Timestamp).toDate(),
      gameType: map['gameType'] ?? '',
      gameStats: Map<String, dynamic>.from(map['gameStats'] ?? {}),
    );
  }

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry.fromMap(data, doc.id);
  }
}

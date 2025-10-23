import 'package:flutter/material.dart';
import '../theme/caothulive_theme.dart';
import '../services/leaderboard_service.dart';
import '../models/leaderboard_entry.dart';

class GameLeaderboardScreen extends StatefulWidget {
  const GameLeaderboardScreen({super.key});

  @override
  State<GameLeaderboardScreen> createState() => _GameLeaderboardScreenState();
}

class _GameLeaderboardScreenState extends State<GameLeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<LeaderboardEntry>> _allLeaderboards = {};
  Map<String, Map<String, dynamic>> _gameStats = {};
  bool _isLoading = true;

  final List<String> _gameTypes = [
    'quiz_game',
    'memory_game', 
    'puzzle_game',
    'speed_finger',
  ];

  final Map<String, String> _gameTitles = {
    'quiz_game': 'Quiz CaoThuLive',
    'memory_game': 'Memory Game',
    'puzzle_game': 'Puzzle Game', 
    'speed_finger': 'Speed Finger',
  };

  final Map<String, IconData> _gameIcons = {
    'quiz_game': Icons.quiz,
    'memory_game': Icons.memory,
    'puzzle_game': Icons.extension,
    'speed_finger': Icons.touch_app,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _gameTypes.length, vsync: this);
    _loadAllLeaderboards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllLeaderboards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      for (String gameType in _gameTypes) {
        debugPrint('Loading leaderboard for: $gameType');
        final leaderboard = await LeaderboardService.getLeaderboard(gameType: gameType);
        final stats = await LeaderboardService.getGameStats(gameType);
        
        debugPrint('$gameType - Leaderboard entries: ${leaderboard.length}');
        debugPrint('$gameType - Stats: $stats');
        
        setState(() {
          _allLeaderboards[gameType] = leaderboard;
          _gameStats[gameType] = stats;
        });
      }
    } catch (e) {
      debugPrint('Error loading leaderboards: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CaoThuLiveTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // Header với gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: CaoThuLiveTheme.headerGradient,
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Bảng Xếp Hạng Game',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: _loadAllLeaderboards,
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),

          // Tab Bar
          SliverToBoxAdapter(
            child: Container(
              color: CaoThuLiveTheme.backgroundDark,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: CaoThuLiveTheme.primaryRed,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: _gameTypes.map((gameType) => Tab(
                  icon: Icon(_gameIcons[gameType]),
                  text: _gameTitles[gameType],
                )).toList(),
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: CaoThuLiveTheme.primaryRed,
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: _gameTypes.map((gameType) => 
                      _buildGameLeaderboard(gameType)
                    ).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameLeaderboard(String gameType) {
    final leaderboard = _allLeaderboards[gameType] ?? [];
    final stats = _gameStats[gameType] ?? {};
    final gameTitle = _gameTitles[gameType] ?? 'Unknown Game';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Stats Cards
          _buildStatsCards(stats, gameTitle),
          
          const SizedBox(height: 24),
          
          // Leaderboard Title
          Row(
            children: [
              Icon(
                _gameIcons[gameType],
                color: CaoThuLiveTheme.primaryRed,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Top Players - $gameTitle',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Leaderboard List
          if (leaderboard.isEmpty)
            _buildEmptyState(gameTitle)
          else
            _buildLeaderboardList(leaderboard),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats, String gameTitle) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tổng Người Chơi',
            '${stats['totalPlayers'] ?? 0}',
            Icons.people,
            CaoThuLiveTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Lượt Chơi',
            '${stats['totalGames'] ?? 0}',
            Icons.play_arrow,
            CaoThuLiveTheme.primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CaoThuLiveTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String gameTitle) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CaoThuLiveTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            color: Colors.white54,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có điểm số nào cho $gameTitle',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy là người đầu tiên chơi và lập kỷ lục!',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> leaderboard) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        return _buildLeaderboardItem(entry, index + 1);
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int rank) {
    Color rankColor = Colors.white70;
    IconData rankIcon = Icons.emoji_events_outlined;
    
    if (rank == 1) {
      rankColor = Colors.amber;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey[400]!;
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = Colors.orange[300]!;
      rankIcon = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CaoThuLiveTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3 ? rankColor.withOpacity(0.3) : Colors.white24,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rank <= 3 ? rankColor.withOpacity(0.2) : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(rankIcon, color: rankColor, size: 20)
                  : Text(
                      '#$rank',
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName,
                  style: TextStyle(
                    color: rank <= 3 ? rankColor : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.score} điểm',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.timer,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(entry.timeSpent),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Date
          Text(
            _formatDate(entry.playedAt),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes}m ${remainingSeconds}s';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}

import 'package:flutter/material.dart';
import '../theme/caothulive_theme.dart';
import 'games/quiz_game_screen.dart';
import 'games/memory_game_screen.dart';
import 'games/puzzle_game_screen.dart';
import 'games/speed_finger_screen.dart';
import 'games/word_search_screen.dart';
import 'games/sudoku_screen.dart';
import 'games/snake_game_screen.dart';
import 'games/flappy_bird_screen.dart';
import 'games/math_quiz_screen.dart';

class MiniGamesScreen extends StatefulWidget {
  const MiniGamesScreen({super.key});

  @override
  State<MiniGamesScreen> createState() => _MiniGamesScreenState();
}

class _MiniGamesScreenState extends State<MiniGamesScreen> {
  int totalScore = 0;
  int gamesPlayed = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: CaoThuLiveTheme.primaryRed,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Game Mini',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: CaoThuLiveTheme.headerGradient,
                ),
              ),
            ),
          ),
          
          // Stats Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [CaoThuLiveTheme.primaryRed, CaoThuLiveTheme.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: CaoThuLiveTheme.primaryRed.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalScore',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Điểm tổng',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.games,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$gamesPlayed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Game đã chơi',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Games Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildGameCard(index);
                },
                childCount: 9, // 9 games total
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(int index) {
    final games = [
      {
        'title': 'Quiz CaoThuLive',
        'description': 'Kiểm tra kiến thức về live stream',
        'icon': Icons.quiz,
        'color': CaoThuLiveTheme.primaryRed,
        'route': '/quiz-game',
      },
      {
        'title': 'Memory Game',
        'description': 'Luyện trí nhớ với hình ảnh',
        'icon': Icons.psychology,
        'color': CaoThuLiveTheme.primaryBlue,
        'route': '/memory-game',
      },
      {
        'title': 'Puzzle Game',
        'description': 'Ghép hình thử thách',
        'icon': Icons.extension,
        'color': CaoThuLiveTheme.primaryGreen,
        'route': '/puzzle-game',
      },
      {
        'title': 'Speed Click',
        'description': 'Phản xạ nhanh tay',
        'icon': Icons.touch_app,
        'color': CaoThuLiveTheme.primaryOrange,
        'route': '/speed-click',
      },
      {
        'title': 'Word Search',
        'description': 'Tìm từ trong lưới',
        'icon': Icons.text_fields,
        'color': CaoThuLiveTheme.primaryBlue,
        'route': '/word-search',
      },
      {
        'title': 'Sudoku',
        'description': 'Trò chơi số logic',
        'icon': Icons.grid_3x3,
        'color': CaoThuLiveTheme.primaryGreen,
        'route': '/sudoku',
      },
      {
        'title': 'Snake Game',
        'description': 'Rắn săn mồi',
        'icon': Icons.pets,
        'color': CaoThuLiveTheme.primaryRed,
        'route': '/snake-game',
      },
      {
        'title': 'Flappy Bird',
        'description': 'Chim bay qua ống',
        'icon': Icons.flight,
        'color': CaoThuLiveTheme.primaryGreen,
        'route': '/flappy-bird',
      },
      {
        'title': 'Math Quiz',
        'description': 'Toán học nhanh',
        'icon': Icons.calculate,
        'color': CaoThuLiveTheme.primaryOrange,
        'route': '/math-quiz',
      },
    ];
    
    final game = games[index];
    
    return GestureDetector(
      onTap: () => _navigateToGame(game['route']! as String),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: (game['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                game['icon'] as IconData,
                color: game['color'] as Color,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              game['title']! as String,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              game['description']! as String,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(String route) {
    switch (route) {
      case '/quiz-game':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuizGameScreen()),
        );
        break;
      case '/memory-game':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MemoryGameScreen()),
        );
        break;
      case '/puzzle-game':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PuzzleGameScreen()),
        );
        break;
      case '/speed-click':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SpeedFingerScreen()),
        );
        break;
      case '/word-search':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WordSearchScreen()),
        );
        break;
      case '/sudoku':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SudokuScreen()),
        );
        break;
      case '/snake-game':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SnakeGameScreen()),
        );
        break;
      case '/flappy-bird':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FlappyBirdScreen()),
        );
        break;
      case '/math-quiz':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MathQuizScreen()),
        );
        break;
      default:
        _showComingSoonDialog();
    }
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sắp ra mắt!'),
        content: const Text('Game này đang được phát triển và sẽ sớm có mặt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

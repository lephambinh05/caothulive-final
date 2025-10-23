import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/caothulive_theme.dart';
import '../../widgets/name_input_dialog.dart';
import '../leaderboard_screen.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  // Game state
  bool gameStarted = false;
  bool gameOver = false;
  bool gamePaused = false;
  int score = 0;
  int highScore = 0;
  
  // Game grid
  static const int gridSize = 20;
  static const int cellSize = 20;
  
  // Snake
  List<Point<int>> snake = [];
  Point<int> food = const Point(10, 10);
  String direction = 'right';
  String nextDirection = 'right';
  
  // Game timer
  late Timer gameTimer;
  
  // Game speed
  int gameSpeed = 200; // milliseconds

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    if (gameStarted) {
      gameTimer.cancel();
    }
    super.dispose();
  }

  void _initializeGame() {
    setState(() {
      gameStarted = false;
      gameOver = false;
      gamePaused = false;
      score = 0;
      snake = [
        const Point(5, 5),
        const Point(4, 5),
        const Point(3, 5),
      ];
      direction = 'right';
      nextDirection = 'right';
      _generateFood();
    });
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
    });
    
    gameTimer = Timer.periodic(Duration(milliseconds: gameSpeed), (timer) {
      _updateGame();
    });
  }

  void _updateGame() {
    if (gameOver || gamePaused) return;
    
    setState(() {
      direction = nextDirection;
      _moveSnake();
    });
  }

  void _moveSnake() {
    final head = snake.first;
    Point<int> newHead;
    
    switch (direction) {
      case 'up':
        newHead = Point(head.x, head.y - 1);
        break;
      case 'down':
        newHead = Point(head.x, head.y + 1);
        break;
      case 'left':
        newHead = Point(head.x - 1, head.y);
        break;
      case 'right':
        newHead = Point(head.x + 1, head.y);
        break;
      default:
        return;
    }
    
    // Check wall collision
    if (newHead.x < 0 || newHead.x >= gridSize || newHead.y < 0 || newHead.y >= gridSize) {
      _gameOver();
      return;
    }
    
    // Check self collision
    if (snake.contains(newHead)) {
      _gameOver();
      return;
    }
    
    snake.insert(0, newHead);
    
    // Check food collision
    if (newHead == food) {
      score += 10;
      _generateFood();
      _increaseSpeed();
    } else {
      snake.removeLast();
    }
  }

  void _generateFood() {
    final random = Random();
    Point<int> newFood;
    
    do {
      newFood = Point(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (snake.contains(newFood));
    
    food = newFood;
  }

  void _increaseSpeed() {
    if (gameSpeed > 100) {
      gameSpeed -= 5;
      gameTimer.cancel();
      gameTimer = Timer.periodic(Duration(milliseconds: gameSpeed), (timer) {
        _updateGame();
      });
    }
  }

  void _changeDirection(String newDirection) {
    // Prevent reverse direction
    if ((direction == 'up' && newDirection == 'down') ||
        (direction == 'down' && newDirection == 'up') ||
        (direction == 'left' && newDirection == 'right') ||
        (direction == 'right' && newDirection == 'left')) {
      return;
    }
    
    nextDirection = newDirection;
  }

  void _gameOver() {
    setState(() {
      gameOver = true;
      gameStarted = false;
      if (score > highScore) {
        highScore = score;
      }
    });
    
    gameTimer.cancel();
    _showNameInputDialog();
  }

  void _togglePause() {
    setState(() {
      gamePaused = !gamePaused;
    });
  }

  void _showNameInputDialog() async {
    final result = await showNameInputDialog(
      context: context,
      score: score,
      timeSpent: 0, // Snake doesn't track time
      gameType: 'snake',
      gameTitle: 'Snake Game',
    );
    
    if (result == true) {
      print('Snake score submitted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Snake Game'),
        backgroundColor: CaoThuLiveTheme.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(
                    gameType: 'snake',
                    gameTitle: 'Snake Game',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: gameOver ? _buildGameOver() : _buildGame(),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        // Game stats
        Container(
          padding: const EdgeInsets.all(16),
          color: CaoThuLiveTheme.backgroundCard,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Điểm', score.toString(), Icons.star),
              _buildStatItem('Tốc độ', '${(200 - gameSpeed) ~/ 5}', Icons.speed),
              _buildStatItem('Kỷ lục', highScore.toString(), Icons.emoji_events),
            ],
          ),
        ),
        
        // Game area
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: gameStarted ? _buildGameGrid() : _buildStartScreen(),
          ),
        ),
        
        // Controls
        if (gameStarted)
          Container(
            padding: const EdgeInsets.all(16),
            color: CaoThuLiveTheme.backgroundCard,
            child: _buildControls(),
          ),
      ],
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pets,
            size: 100,
            color: CaoThuLiveTheme.primaryRed,
          ),
          const SizedBox(height: 24),
          const Text(
            'Snake Game',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CaoThuLiveTheme.primaryRed,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Điều khiển rắn ăn thức ăn!\nTránh va chạm với tường và thân mình.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: CaoThuLiveTheme.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Bắt đầu chơi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CaoThuLiveTheme.primaryRed, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          childAspectRatio: 1,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          final x = index % gridSize;
          final y = index ~/ gridSize;
          final point = Point(x, y);
          
          bool isSnake = snake.contains(point);
          bool isFood = point == food;
          bool isHead = snake.isNotEmpty && snake.first == point;
          
          return Container(
            decoration: BoxDecoration(
              color: isHead 
                  ? CaoThuLiveTheme.primaryRed
                  : isSnake 
                      ? CaoThuLiveTheme.primaryRed.withOpacity(0.7)
                      : isFood 
                          ? Colors.green
                          : Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!, width: 0.5),
            ),
            child: isFood 
                ? const Icon(Icons.circle, color: Colors.white, size: 12)
                : isHead 
                    ? const Icon(Icons.face, color: Colors.white, size: 12)
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Pause button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _togglePause,
              style: ElevatedButton.styleFrom(
                backgroundColor: gamePaused ? Colors.green : Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(gamePaused ? 'Tiếp tục' : 'Tạm dừng'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Direction controls
        Column(
          children: [
            // Up button
            GestureDetector(
              onTap: () => _changeDirection('up'),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: CaoThuLiveTheme.primaryRed,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 30),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Left and Right buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _changeDirection('left'),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: CaoThuLiveTheme.primaryRed,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 30),
                  ),
                ),
                
                const SizedBox(width: 40),
                
                GestureDetector(
                  onTap: () => _changeDirection('right'),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: CaoThuLiveTheme.primaryRed,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Down button
            GestureDetector(
              onTap: () => _changeDirection('down'),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: CaoThuLiveTheme.primaryRed,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: CaoThuLiveTheme.primaryRed, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sentiment_very_dissatisfied,
            size: 100,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          const Text(
            'Game Over!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rắn đã va chạm!',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          Text(
            'Điểm số: $score',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (score > 0 && score == highScore)
            const Text(
              'Kỷ lục mới!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _initializeGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CaoThuLiveTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Chơi lại'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Về menu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/caothulive_theme.dart';
import '../../widgets/name_input_dialog.dart';
import '../leaderboard_screen.dart';

class FlappyBirdScreen extends StatefulWidget {
  const FlappyBirdScreen({super.key});

  @override
  State<FlappyBirdScreen> createState() => _FlappyBirdScreenState();
}

class _FlappyBirdScreenState extends State<FlappyBirdScreen> {
  // Game state
  bool gameStarted = false;
  bool gameOver = false;
  bool gamePaused = false;
  int score = 0;
  int highScore = 0;
  
  // Bird
  double birdY = 0.5; // 0.0 to 1.0 (top to bottom)
  double birdVelocity = 0.0;
  static const double gravity = 0.0005;
  static const double jumpForce = -0.008;
  
  // Pipes
  List<Pipe> pipes = [];
  static const double pipeWidth = 0.15;
  static const double pipeGap = 0.3;
  static const double pipeSpeed = 0.003;
  
  // Game timer
  late Timer gameTimer;
  
  // Game speed
  int gameSpeed = 16; // milliseconds

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
      birdY = 0.5;
      birdVelocity = 0.0;
      pipes.clear();
    });
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      gamePaused = true; // Start paused
    });
    
    gameTimer = Timer.periodic(Duration(milliseconds: gameSpeed), (timer) {
      _updateGame();
    });
  }
  
  void _resumeGame() {
    setState(() {
      gamePaused = false;
    });
  }

  void _updateGame() {
    if (gameOver || gamePaused) return;
    
    setState(() {
      // Update bird physics
      birdVelocity += gravity;
      birdY += birdVelocity;
      
      // Check ground collision
      if (birdY >= 1.0) {
        _gameOver();
        return;
      }
      
      // Check ceiling collision
      if (birdY <= 0.0) {
        birdY = 0.0;
        birdVelocity = 0.0;
      }
      
      // Update pipes
      for (int i = pipes.length - 1; i >= 0; i--) {
        pipes[i].x -= pipeSpeed;
        
        // Remove pipes that are off screen
        if (pipes[i].x + pipeWidth < 0) {
          pipes.removeAt(i);
          score++;
        }
      }
      
      // Add new pipes
      if (pipes.isEmpty || pipes.last.x < 0.4) {
        _addPipe();
      }
      
      // Check pipe collisions
      for (final pipe in pipes) {
        if (_checkCollision(pipe)) {
          _gameOver();
          return;
        }
      }
    });
  }

  void _addPipe() {
    final random = Random();
    final gapY = 0.2 + random.nextDouble() * 0.6; // Gap position
    
    pipes.add(Pipe(
      x: 1.0,
      topHeight: gapY - pipeGap / 2,
      bottomY: gapY + pipeGap / 2,
    ));
  }

  bool _checkCollision(Pipe pipe) {
    const double birdSize = 0.05;
    const double birdX = 0.2;
    
    // Check if bird is within pipe's x range
    if (birdX + birdSize > pipe.x && birdX < pipe.x + pipeWidth) {
      // Check if bird hits top or bottom pipe
      if (birdY < pipe.topHeight || birdY + birdSize > pipe.bottomY) {
        return true;
      }
    }
    
    return false;
  }

  void _jump() {
    if (!gameStarted || gameOver) return;
    
    // If game is paused, resume it
    if (gamePaused) {
      _resumeGame();
      return;
    }
    
    setState(() {
      birdVelocity = jumpForce;
    });
  }

  void _togglePause() {
    setState(() {
      gamePaused = !gamePaused;
    });
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

  void _showNameInputDialog() async {
    final result = await showNameInputDialog(
      context: context,
      score: score,
      timeSpent: 0, // Flappy Bird doesn't track time
      gameType: 'flappy_bird',
      gameTitle: 'Flappy Bird',
    );
    
    if (result == true) {
      print('Flappy Bird score submitted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Flappy Bird'),
        backgroundColor: CaoThuLiveTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(
                    gameType: 'flappy_bird',
                    gameTitle: 'Flappy Bird',
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
              _buildStatItem('Kỷ lục', highScore.toString(), Icons.emoji_events),
              _buildStatItem('Ống', pipes.length.toString(), Icons.vertical_align_center),
            ],
          ),
        ),
        
        // Game area
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: gameStarted ? _buildGameArea() : _buildStartScreen(),
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
            Icons.flight,
            size: 100,
            color: CaoThuLiveTheme.primaryGreen,
          ),
          const SizedBox(height: 24),
          const Text(
            'Flappy Bird',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CaoThuLiveTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Điều khiển chim bay qua ống!\nChạm màn hình để nhảy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Chạm màn hình để nhảy',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: CaoThuLiveTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Bắt đầu bay',
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

  Widget _buildGameArea() {
    return GestureDetector(
      onTap: _jump,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFF98FB98), // Light green
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CaoThuLiveTheme.primaryGreen, width: 2),
        ),
        child: Stack(
          children: [
            // Pipes
            ...pipes.map((pipe) => _buildPipe(pipe)).toList(),
            
            // Bird
            _buildBird(),
            
            // Pause overlay
            if (gamePaused)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.touch_app,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chạm màn hình để bắt đầu!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chim sẽ bắt đầu bay khi bạn chạm',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBird() {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.2,
      top: MediaQuery.of(context).size.height * birdY * 0.6,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.yellow,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.orange, width: 2),
        ),
        child: const Icon(
          Icons.pets,
          color: Colors.orange,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPipe(Pipe pipe) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.6;
    
    return Stack(
      children: [
        // Top pipe
        Positioned(
          left: pipe.x * screenWidth,
          top: 0,
          width: pipeWidth * screenWidth,
          height: pipe.topHeight * screenHeight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              border: Border.all(color: Colors.green[800]!, width: 2),
            ),
          ),
        ),
        
        // Bottom pipe
        Positioned(
          left: pipe.x * screenWidth,
          top: pipe.bottomY * screenHeight,
          width: pipeWidth * screenWidth,
          height: (1.0 - pipe.bottomY) * screenHeight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              border: Border.all(color: Colors.green[800]!, width: 2),
            ),
          ),
        ),
      ],
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
        
        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.touch_app,
                color: Colors.blue,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                gamePaused ? 'Chạm màn hình để bắt đầu!' : 'Chạm màn hình để nhảy',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: CaoThuLiveTheme.primaryGreen, size: 20),
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
            'Chim đã va chạm!',
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
                  backgroundColor: CaoThuLiveTheme.primaryGreen,
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

class Pipe {
  double x;
  double topHeight;
  double bottomY;
  
  Pipe({
    required this.x,
    required this.topHeight,
    required this.bottomY,
  });
}


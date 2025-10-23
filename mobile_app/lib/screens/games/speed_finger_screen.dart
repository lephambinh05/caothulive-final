import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/caothulive_theme.dart';
import '../../widgets/name_input_dialog.dart';
import '../leaderboard_screen.dart';

class SpeedFingerScreen extends StatefulWidget {
  const SpeedFingerScreen({super.key});

  @override
  State<SpeedFingerScreen> createState() => _SpeedFingerScreenState();
}

class _SpeedFingerScreenState extends State<SpeedFingerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  int score = 0;
  int timeLeft = 30;
  bool gameActive = false;
  bool gameFinished = false;
  String currentTarget = '';
  List<String> targets = ['TAP', 'HOLD', 'DOUBLE', 'SWIPE'];
  String currentAction = '';
  int combo = 0;
  int bestScore = 0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      gameActive = true;
      gameFinished = false;
      score = 0;
      timeLeft = 30;
      combo = 0;
    });
    
    _generateNewTarget();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (gameActive && timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
        _startTimer();
      } else if (timeLeft == 0) {
        _endGame();
      }
    });
  }

  void _generateNewTarget() {
    if (!gameActive) return;
    
    setState(() {
      currentTarget = targets[DateTime.now().millisecondsSinceEpoch % targets.length];
      currentAction = _getActionForTarget(currentTarget);
    });
  }

  String _getActionForTarget(String target) {
    switch (target) {
      case 'TAP':
        return 'Nhấn nhanh!';
      case 'HOLD':
        return 'Giữ lâu!';
      case 'DOUBLE':
        return 'Nhấn đôi!';
      case 'SWIPE':
        return 'Vuốt!';
      default:
        return 'Nhấn!';
    }
  }

  void _onTap() {
    if (!gameActive) return;
    
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    if (currentTarget == 'TAP') {
      _correctAction();
    } else {
      _wrongAction();
    }
  }

  void _onLongPressStart() {
    if (!gameActive) return;
    
    if (currentTarget == 'HOLD') {
      _correctAction();
    } else {
      _wrongAction();
    }
  }

  void _onDoubleTap() {
    if (!gameActive) return;
    
    if (currentTarget == 'DOUBLE') {
      _correctAction();
    } else {
      _wrongAction();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!gameActive) return;
    
    if (currentTarget == 'SWIPE') {
      _correctAction();
    } else {
      _wrongAction();
    }
  }

  void _correctAction() {
    setState(() {
      combo++;
      score += 10 + (combo * 2);
      if (score > bestScore) {
        bestScore = score;
      }
    });
    
    HapticFeedback.lightImpact();
    _generateNewTarget();
  }

  void _wrongAction() {
    setState(() {
      combo = 0;
      score = (score - 5).clamp(0, double.infinity).toInt();
    });
    
    HapticFeedback.heavyImpact();
  }

  void _endGame() {
    setState(() {
      gameActive = false;
      gameFinished = true;
    });
    
    HapticFeedback.mediumImpact();
    
    // Show name input dialog after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showNameInputDialog();
      }
    });
  }

  void _showNameInputDialog() async {
    final result = await showNameInputDialog(
      context: context,
      score: score,
      timeSpent: 30 - timeLeft,
      gameType: 'speed_finger',
      gameTitle: 'Speed Finger',
    );
    
    if (result == true) {
      // Score was submitted successfully
      print('Score submitted successfully');
    }
  }

  void _resetGame() {
    setState(() {
      gameActive = false;
      gameFinished = false;
      score = 0;
      timeLeft = 30;
      combo = 0;
      currentTarget = '';
      currentAction = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: CaoThuLiveTheme.headerGradient,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Speed Finger',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardScreen(
                            gameType: 'speed_finger',
                            gameTitle: 'Speed Finger',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.emoji_events, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Game Stats
            Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Điểm', score.toString(), Icons.star),
                  _buildStatItem('Thời gian', '${timeLeft}s', Icons.timer),
                  _buildStatItem('Combo', combo.toString(), Icons.flash_on),
                  _buildStatItem('Kỷ lục', bestScore.toString(), Icons.emoji_events),
                ],
              ),
            ),
            
            // Game Area
            Expanded(
              child: gameFinished
                  ? _buildGameFinished()
                  : gameActive
                      ? _buildGameArea()
                      : _buildGameStart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGameStart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.touch_app,
            size: 100,
            color: CaoThuLiveTheme.primaryRed,
          ),
          const SizedBox(height: 24),
          const Text(
            'Speed Finger',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CaoThuLiveTheme.primaryRed,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Luyện phản xạ nhanh tay!\nNhấn đúng theo yêu cầu để ghi điểm.',
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
              'Bắt đầu',
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Target Display
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: CaoThuLiveTheme.primaryRed,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CaoThuLiveTheme.primaryRed.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTap: _onTap,
                onLongPressStart: (_) => _onLongPressStart(),
                onDoubleTap: _onDoubleTap,
                onPanUpdate: _onPanUpdate,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentTarget,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentAction,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'TAP: Nhấn một lần\nHOLD: Giữ lâu\nDOUBLE: Nhấn đôi\nSWIPE: Vuốt',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameFinished() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            size: 100,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          const Text(
            'Hoàn thành!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CaoThuLiveTheme.primaryRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Điểm số: $score',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CaoThuLiveTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Combo cao nhất: $combo',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _resetGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Chơi lại',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CaoThuLiveTheme.primaryRed,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

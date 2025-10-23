import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/caothulive_theme.dart';
import '../../widgets/name_input_dialog.dart';
import '../leaderboard_screen.dart';

class MathQuizScreen extends StatefulWidget {
  const MathQuizScreen({super.key});

  @override
  State<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  // Game state
  bool gameStarted = false;
  bool gameOver = false;
  bool gameWon = false;
  int score = 0;
  int timeLeft = 30;
  int currentQuestion = 0;
  int correctAnswers = 0;
  int totalQuestions = 10;
  
  // Current question
  String question = '';
  int correctAnswer = 0;
  List<int> options = [];
  int? selectedAnswer;
  
  // Game timer
  late Timer gameTimer;
  
  // Question types
  final List<String> operations = ['+', '-', '×', '÷'];
  String currentOperation = '+';

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
      gameWon = false;
      score = 0;
      timeLeft = 30;
      currentQuestion = 0;
      correctAnswers = 0;
      selectedAnswer = null;
    });
  }

  void _startGame() {
    _generateQuestion();
    setState(() {
      gameStarted = true;
    });
    
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
      });
      
      if (timeLeft <= 0) {
        _gameOver();
      }
    });
  }

  void _generateQuestion() {
    final random = Random();
    currentOperation = operations[random.nextInt(operations.length)];
    
    int num1, num2;
    String questionText;
    
    switch (currentOperation) {
      case '+':
        num1 = random.nextInt(50) + 1;
        num2 = random.nextInt(50) + 1;
        correctAnswer = num1 + num2;
        questionText = '$num1 + $num2 = ?';
        break;
      case '-':
        num1 = random.nextInt(50) + 20;
        num2 = random.nextInt(num1) + 1;
        correctAnswer = num1 - num2;
        questionText = '$num1 - $num2 = ?';
        break;
      case '×':
        num1 = random.nextInt(12) + 1;
        num2 = random.nextInt(12) + 1;
        correctAnswer = num1 * num2;
        questionText = '$num1 × $num2 = ?';
        break;
      case '÷':
        num2 = random.nextInt(12) + 1;
        correctAnswer = random.nextInt(12) + 1;
        num1 = correctAnswer * num2;
        questionText = '$num1 ÷ $num2 = ?';
        break;
      default:
        num1 = 1;
        num2 = 1;
        correctAnswer = 2;
        questionText = '1 + 1 = ?';
    }
    
    setState(() {
      question = questionText;
      options = _generateOptions(correctAnswer);
      selectedAnswer = null;
    });
  }

  List<int> _generateOptions(int correct) {
    final random = Random();
    final options = <int>[correct];
    
    while (options.length < 4) {
      int option;
      if (correct < 10) {
        option = random.nextInt(20);
      } else if (correct < 100) {
        option = correct + random.nextInt(20) - 10;
      } else {
        option = correct + random.nextInt(50) - 25;
      }
      
      if (option >= 0 && !options.contains(option)) {
        options.add(option);
      }
    }
    
    options.shuffle();
    return options;
  }

  void _selectAnswer(int answer) {
    if (selectedAnswer != null) return;
    
    setState(() {
      selectedAnswer = answer;
    });
    
    Timer(const Duration(milliseconds: 1000), () {
      if (answer == correctAnswer) {
        setState(() {
          correctAnswers++;
          score += 10 + (timeLeft ~/ 3);
        });
      }
      
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    setState(() {
      currentQuestion++;
    });
    
    if (currentQuestion >= totalQuestions) {
      _gameWon();
    } else {
      _generateQuestion();
    }
  }

  void _gameOver() {
    setState(() {
      gameOver = true;
      gameStarted = false;
    });
    
    gameTimer.cancel();
    _showNameInputDialog();
  }

  void _gameWon() {
    setState(() {
      gameWon = true;
      gameStarted = false;
      score += timeLeft * 2; // Bonus points for remaining time
    });
    
    gameTimer.cancel();
    _showNameInputDialog();
  }

  void _showNameInputDialog() async {
    final result = await showNameInputDialog(
      context: context,
      score: score,
      timeSpent: 30 - timeLeft,
      gameType: 'math_quiz',
      gameTitle: 'Math Quiz',
    );
    
    if (result == true) {
      print('Math Quiz score submitted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Math Quiz'),
        backgroundColor: CaoThuLiveTheme.primaryOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(
                    gameType: 'math_quiz',
                    gameTitle: 'Math Quiz',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: gameOver || gameWon ? _buildGameOver() : _buildGame(),
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
              _buildStatItem('Thời gian', timeLeft.toString(), Icons.timer),
              _buildStatItem('Điểm', score.toString(), Icons.star),
              _buildStatItem('Câu hỏi', '$currentQuestion/$totalQuestions', Icons.quiz),
            ],
          ),
        ),
        
        // Game area
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: gameStarted ? _buildQuestion() : _buildStartScreen(),
          ),
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
            Icons.calculate,
            size: 100,
            color: CaoThuLiveTheme.primaryOrange,
          ),
          const SizedBox(height: 24),
          const Text(
            'Math Quiz',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CaoThuLiveTheme.primaryOrange,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Trả lời câu hỏi toán học!\nCàng nhanh càng được nhiều điểm.',
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
              backgroundColor: CaoThuLiveTheme.primaryOrange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Bắt đầu quiz',
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

  Widget _buildQuestion() {
    return Column(
      children: [
        // Progress bar
        Container(
          margin: const EdgeInsets.all(16),
          child: LinearProgressIndicator(
            value: currentQuestion / totalQuestions,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(CaoThuLiveTheme.primaryOrange),
          ),
        ),
        
        // Question
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange[200]!, width: 2),
          ),
          child: Column(
            children: [
              const Text(
                'Câu hỏi:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                question,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        
        // Answer options
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = selectedAnswer == option;
              final isCorrect = option == correctAnswer;
              final isWrong = selectedAnswer == option && option != correctAnswer;
              
              Color backgroundColor;
              Color textColor;
              
              if (isSelected) {
                if (isCorrect) {
                  backgroundColor = Colors.green;
                  textColor = Colors.white;
                } else if (isWrong) {
                  backgroundColor = Colors.red;
                  textColor = Colors.white;
                } else {
                  backgroundColor = CaoThuLiveTheme.primaryOrange;
                  textColor = Colors.white;
                }
              } else {
                backgroundColor = Colors.white;
                textColor = Colors.black;
              }
              
              return GestureDetector(
                onTap: () => _selectAnswer(option),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? (isCorrect ? Colors.green : isWrong ? Colors.red : CaoThuLiveTheme.primaryOrange)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      option.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: CaoThuLiveTheme.primaryOrange, size: 20),
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
          Icon(
            gameWon ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
            size: 100,
            color: gameWon ? Colors.amber : Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            gameWon ? 'Tuyệt vời!' : 'Hết thời gian!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: gameWon ? Colors.amber : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            gameWon 
                ? 'Bạn đã hoàn thành tất cả câu hỏi!'
                : 'Thời gian đã hết!',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          Text(
            'Điểm số: $score',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Đúng: $correctAnswers/$totalQuestions',
            style: const TextStyle(fontSize: 18),
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
                  backgroundColor: CaoThuLiveTheme.primaryOrange,
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


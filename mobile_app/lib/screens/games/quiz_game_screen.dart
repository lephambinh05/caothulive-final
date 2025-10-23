import 'package:flutter/material.dart';
import '../../theme/caothulive_theme.dart';
import '../../services/ai_quiz_generator_service.dart';
import '../../services/rank_list_service.dart';
import '../../widgets/name_input_dialog.dart';
import '../leaderboard_screen.dart';

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestion = 0;
  int score = 0;
  int selectedAnswer = -1;
  bool showResult = false;
  bool gameWon = false;
  late int startTime;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    setState(() {
      questions = AIQuizGeneratorService.generateQuizSession();
      currentQuestion = 0;
      score = 0;
      selectedAnswer = -1;
      showResult = false;
      gameWon = false;
      startTime = DateTime.now().millisecondsSinceEpoch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Quiz CaoThuLive'),
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
                    gameType: 'quiz_game',
                    gameTitle: 'Quiz CaoThuLive',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: gameWon ? _buildGameFinished() : _buildGameContent(),
    );
  }

  Widget _buildGameContent() {
    if (questions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final question = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(CaoThuLiveTheme.primaryRed),
          ),
          const SizedBox(height: 20),

          // Question Number
          Text(
            'Câu ${currentQuestion + 1}/${questions.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Question
          Text(
            question['question'],
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Answer Options
          ...List.generate(4, (index) {
            final isSelected = selectedAnswer == index;
            final isCorrect = showResult && index == question['correct'];
            final isWrong = showResult && isSelected && index != question['correct'];

            Color backgroundColor = Colors.white;
            Color borderColor = Colors.grey[300]!;
            Color textColor = Colors.black;

            if (showResult) {
              if (isCorrect) {
                backgroundColor = Colors.green.withOpacity(0.1);
                borderColor = Colors.green;
                textColor = Colors.green[700]!;
              } else if (isWrong) {
                backgroundColor = Colors.red.withOpacity(0.1);
                borderColor = Colors.red;
                textColor = Colors.red[700]!;
              }
            } else if (isSelected) {
              backgroundColor = CaoThuLiveTheme.primaryRed.withOpacity(0.1);
              borderColor = CaoThuLiveTheme.primaryRed;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: showResult ? null : () => _checkAnswer(index),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Text(
                    question['options'][index],
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Score Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: CaoThuLiveTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Điểm: $score',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CaoThuLiveTheme.primaryRed,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Explanation (if result is shown)
          if (showResult) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CaoThuLiveTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CaoThuLiveTheme.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: CaoThuLiveTheme.primaryBlue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Giải thích:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CaoThuLiveTheme.primaryBlue,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    questions[currentQuestion]['explanation'],
                    style: const TextStyle(
                      color: CaoThuLiveTheme.primaryBlue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedAnswer == -1 ? null : _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CaoThuLiveTheme.primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  showResult
                      ? (currentQuestion == questions.length - 1 ? 'Kết thúc' : 'Tiếp theo')
                      : 'Kiểm tra',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _checkAnswer(int answerIndex) {
    if (showResult) return; // Prevent multiple selections
    setState(() {
      selectedAnswer = answerIndex;
      showResult = true;
      if (selectedAnswer == questions[currentQuestion]['correct']) {
        score += (questions[currentQuestion]['points'] ?? 10) as int;
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = -1;
        showResult = false;
      });
    } else {
      _finishGame();
    }
  }

  void _finishGame() {
    setState(() {
      gameWon = true;
    });
    _showNameInputDialog();
  }

  void _showNameInputDialog() async {
    final result = await showNameInputDialog(
      context: context,
      score: score,
      timeSpent: (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000,
      gameType: 'quiz_game',
      gameTitle: 'Quiz CaoThuLive',
    );
    
    if (result == true) {
      // Score was submitted successfully
      print('Quiz score submitted successfully');
    }
  }

  Widget _buildGameFinished() {
    final percentage = (score / (questions.length * 10) * 100).round();
    
    String message = '';
    String emoji = '';
    
    if (percentage >= 80) {
      message = 'Xuất sắc!';
      emoji = '🎉';
    } else if (percentage >= 60) {
      message = 'Tốt lắm!';
      emoji = '👏';
    } else if (percentage >= 40) {
      message = 'Khá ổn!';
      emoji = '👍';
    } else {
      message = 'Cần cố gắng thêm!';
      emoji = '💪';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Kết quả Quiz'),
        backgroundColor: CaoThuLiveTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Result
            Text(
              emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: CaoThuLiveTheme.primaryRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Điểm số: $score/${questions.length * 10}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tỷ lệ đúng: $percentage%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Simple Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CaoThuLiveTheme.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CaoThuLiveTheme.primaryRed.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              currentQuestion = 0;
                              score = 0;
                              selectedAnswer = -1;
                              showResult = false;
                              gameWon = false;
                              startTime = DateTime.now().millisecondsSinceEpoch;
                            });
                            _initializeGame();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Chơi lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CaoThuLiveTheme.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.home),
                          label: const Text('Về trang chủ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
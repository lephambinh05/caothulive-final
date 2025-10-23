import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/caothulive_theme.dart';
import '../../widgets/name_input_dialog.dart';
import '../leaderboard_screen.dart';

class WordSearchScreen extends StatefulWidget {
  const WordSearchScreen({super.key});

  @override
  State<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  // Game state
  bool gameStarted = false;
  bool gameOver = false;
  bool gameWon = false;
  int score = 0;
  int elapsedTime = 0;
  int wordsFound = 0;
  
  // Grid
  static const int gridSize = 12;
  List<List<String>> grid = [];
  List<String> words = [];
  List<String> foundWords = [];
  List<List<bool>> selectedCells = [];
  
  // Game timer
  late Timer gameTimer;
  
  // Word lists
  final List<List<String>> wordLists = [
    ['CAOTHULIVE', 'YOUTUBE', 'STREAM', 'GAME', 'FUN'],
    ['FLUTTER', 'DART', 'MOBILE', 'APP', 'CODE'],
    ['VIETNAM', 'HANOI', 'HOCHIMINH', 'DANANG', 'HUE'],
    ['FOOD', 'PHO', 'BANHMI', 'COFFEE', 'TEA'],
    ['SPORT', 'FOOTBALL', 'TENNIS', 'SWIM', 'RUN'],
  ];

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
      elapsedTime = 0;
      wordsFound = 0;
      foundWords.clear();
      selectedCells = List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));
    });
  }

  void _startGame() {
    _generateGrid();
    setState(() {
      gameStarted = true;
      elapsedTime = 0;
    });
    
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime++;
      });
    });
  }

  void _generateGrid() {
    // Select random word list
    final random = Random();
    final selectedWordList = wordLists[random.nextInt(wordLists.length)];
    words = List.from(selectedWordList);
    
    // Initialize grid with empty spaces first
    grid = List.generate(gridSize, (i) => 
      List.generate(gridSize, (j) => ' ')
    );
    
    // Place words in grid first
    for (final word in words) {
      _placeWord(word);
    }
    
    // Fill remaining empty spaces with random letters
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == ' ') {
          grid[i][j] = String.fromCharCode(65 + random.nextInt(26));
        }
      }
    }
  }

  void _placeWord(String word) {
    final random = Random();
    bool placed = false;
    int attempts = 0;
    
    while (!placed && attempts < 100) {
      final direction = random.nextInt(3); // 0: horizontal, 1: vertical, 2: diagonal
      final startX = random.nextInt(gridSize);
      final startY = random.nextInt(gridSize);
      
      if (_canPlaceWord(word, startX, startY, direction)) {
        _placeWordInGrid(word, startX, startY, direction);
        placed = true;
      }
      attempts++;
    }
  }

  bool _canPlaceWord(String word, int x, int y, int direction) {
    final length = word.length;
    
    switch (direction) {
      case 0: // Horizontal
        if (x + length > gridSize) return false;
        for (int i = 0; i < length; i++) {
          if (grid[y][x + i] != ' ' && grid[y][x + i] != word[i]) return false;
        }
        break;
      case 1: // Vertical
        if (y + length > gridSize) return false;
        for (int i = 0; i < length; i++) {
          if (grid[y + i][x] != ' ' && grid[y + i][x] != word[i]) return false;
        }
        break;
      case 2: // Diagonal
        if (x + length > gridSize || y + length > gridSize) return false;
        for (int i = 0; i < length; i++) {
          if (grid[y + i][x + i] != ' ' && grid[y + i][x + i] != word[i]) return false;
        }
        break;
    }
    return true;
  }

  void _placeWordInGrid(String word, int x, int y, int direction) {
    for (int i = 0; i < word.length; i++) {
      switch (direction) {
        case 0: // Horizontal
          grid[y][x + i] = word[i];
          break;
        case 1: // Vertical
          grid[y + i][x] = word[i];
          break;
        case 2: // Diagonal
          grid[y + i][x + i] = word[i];
          break;
      }
    }
  }

  void _onCellTap(int row, int col) {
    if (!gameStarted || gameOver) return;
    
    setState(() {
      selectedCells[row][col] = !selectedCells[row][col];
    });
    
    _checkForWords();
  }
  
  void _clearSelection() {
    setState(() {
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          selectedCells[i][j] = false;
        }
      }
    });
  }

  void _checkForWords() {
    // Get all selected cells
    List<Point<int>> selectedPoints = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (selectedCells[i][j]) {
          selectedPoints.add(Point(j, i)); // x, y coordinates
        }
      }
    }
    
    if (selectedPoints.length < 3) return; // Need at least 3 letters
    
    // Check if selected cells form a valid word
    final selectedWord = _getSelectedWord(selectedPoints);
    if (selectedWord.isNotEmpty && words.contains(selectedWord) && !foundWords.contains(selectedWord)) {
      setState(() {
        foundWords.add(selectedWord);
        wordsFound++;
        score += selectedWord.length * 10;
        // Clear selection after finding word
        for (int i = 0; i < gridSize; i++) {
          for (int j = 0; j < gridSize; j++) {
            selectedCells[i][j] = false;
          }
        }
      });
      
      if (wordsFound == words.length) {
        _gameWon();
      }
    }
  }

  String _getSelectedWord(List<Point<int>> selectedPoints) {
    if (selectedPoints.length < 3) return '';
    
    // Sort points to get the order
    selectedPoints.sort((a, b) {
      if (a.y != b.y) return a.y.compareTo(b.y);
      return a.x.compareTo(b.x);
    });
    
    // Check if points are in a line (horizontal, vertical, or diagonal)
    if (_isValidLine(selectedPoints)) {
      String word = '';
      for (Point<int> point in selectedPoints) {
        word += grid[point.y][point.x];
      }
      return word;
    }
    
    return '';
  }
  
  bool _isValidLine(List<Point<int>> points) {
    if (points.length < 3) return false;
    
    // Check if all points are in a straight line
    bool isHorizontal = true;
    bool isVertical = true;
    bool isDiagonal = true;
    
    for (int i = 1; i < points.length; i++) {
      if (points[i].y != points[0].y) isHorizontal = false;
      if (points[i].x != points[0].x) isVertical = false;
      if (points[i].x - points[0].x != points[i].y - points[0].y) isDiagonal = false;
    }
    
    return isHorizontal || isVertical || isDiagonal;
  }

  void _gameOver() {
    setState(() {
      gameOver = true;
      gameStarted = false;
    });
    
    gameTimer.cancel();
    _showNameInputDialog();
  }
  
  void _endGameManually() {
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
    });
    
    gameTimer.cancel();
    _showNameInputDialog();
  }

  void _showNameInputDialog() async {
    final result = await showNameInputDialog(
      context: context,
      score: score,
      timeSpent: elapsedTime,
      gameType: 'word_search',
      gameTitle: 'Word Search',
    );
    
    if (result == true) {
      print('Word Search score submitted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Word Search'),
        backgroundColor: CaoThuLiveTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(
                    gameType: 'word_search',
                    gameTitle: 'Word Search',
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
              _buildStatItem('Thời gian', '${elapsedTime}s', Icons.timer),
              _buildStatItem('Điểm', score.toString(), Icons.star),
              _buildStatItem('Từ', '$wordsFound/${words.length}', Icons.text_fields),
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
      ],
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.text_fields,
            size: 100,
            color: CaoThuLiveTheme.primaryBlue,
          ),
          const SizedBox(height: 24),
          const Text(
            'Word Search',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CaoThuLiveTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tìm từ trong lưới chữ!\nKéo để chọn từ và tìm tất cả từ trong danh sách.',
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
              backgroundColor: CaoThuLiveTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Bắt đầu tìm từ',
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
    return Column(
      children: [
        // Word list
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tìm các từ sau:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                children: words.map((word) {
                  final isFound = foundWords.contains(word);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isFound ? Colors.green : Colors.blue[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isFound ? Colors.green : Colors.blue,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      word,
                      style: TextStyle(
                        color: isFound ? Colors.white : Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        decoration: isFound ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Control buttons
        if (gameStarted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _clearSelection,
                  icon: const Icon(Icons.clear),
                  label: const Text('Xóa lựa chọn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _endGameManually,
                  icon: const Icon(Icons.stop),
                  label: const Text('Kết thúc game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 8),
        
        // Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              childAspectRatio: 1,
            ),
            itemCount: gridSize * gridSize,
            itemBuilder: (context, index) {
              final row = index ~/ gridSize;
              final col = index % gridSize;
              final letter = grid[row][col];
              final isSelected = selectedCells[row][col];
              
              return GestureDetector(
                onTap: () => _onCellTap(row, col),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isSelected ? CaoThuLiveTheme.primaryBlue : Colors.white,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
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
        Icon(icon, color: CaoThuLiveTheme.primaryBlue, size: 20),
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
            gameWon ? 'Tuyệt vời!' : 'Game Over!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: gameWon ? Colors.amber : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            gameWon 
                ? 'Bạn đã tìm thấy tất cả từ!'
                : 'Game đã kết thúc!',
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
            'Từ đã tìm: $wordsFound/${words.length}',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'Thời gian chơi: ${elapsedTime}s',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                  backgroundColor: CaoThuLiveTheme.primaryBlue,
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


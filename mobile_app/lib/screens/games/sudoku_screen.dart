import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/caothulive_theme.dart';
import '../../widgets/name_input_dialog.dart';
import '../leaderboard_screen.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  // Game state
  bool gameStarted = false;
  bool gameOver = false;
  bool gameWon = false;
  int score = 0;
  int timeSpent = 0;
  int mistakes = 0;
  
  // Grid
  static const int gridSize = 9;
  List<List<int>> grid = [];
  List<List<int>> solution = [];
  List<List<bool>> isGiven = [];
  List<List<bool>> isSelected = [];
  List<List<bool>> hasError = [];
  int? selectedRow;
  int? selectedCol;
  
  // Game timer
  late Timer gameTimer;
  
  // Difficulty levels
  final Map<String, int> difficulties = {
    'Dễ': 40,
    'Trung bình': 30,
    'Khó': 20,
  };
  String selectedDifficulty = 'Dễ';

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
      timeSpent = 0;
      mistakes = 0;
      selectedRow = null;
      selectedCol = null;
      grid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => 0));
      solution = List.generate(gridSize, (i) => List.generate(gridSize, (j) => 0));
      isGiven = List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));
      isSelected = List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));
      hasError = List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));
    });
  }

  void _startGame() {
    _generateSudoku();
    setState(() {
      gameStarted = true;
    });
    
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeSpent++;
      });
    });
  }

  void _generateSudoku() {
    // Generate a complete solution
    _generateSolution();
    
    // Copy solution to grid
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        grid[i][j] = solution[i][j];
      }
    }
    
    // Remove numbers to create puzzle
    _removeNumbers();
  }

  void _generateSolution() {
    // Simplified Sudoku generation
    final random = Random();
    
    // Fill diagonal 3x3 boxes first
    for (int box = 0; box < 3; box++) {
      _fillBox(box * 3, box * 3);
    }
    
    // Fill remaining cells
    _solveSudoku();
  }

  void _fillBox(int row, int col) {
    final random = Random();
    final numbers = List.generate(9, (i) => i + 1);
    numbers.shuffle();
    
    int index = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        solution[row + i][col + j] = numbers[index++];
      }
    }
  }

  bool _solveSudoku() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (solution[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (_isValidMove(solution, row, col, num)) {
              solution[row][col] = num;
              if (_solveSudoku()) {
                return true;
              }
              solution[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValidMove(List<List<int>> board, int row, int col, int num) {
    // Check row
    for (int x = 0; x < gridSize; x++) {
      if (board[row][x] == num) return false;
    }
    
    // Check column
    for (int x = 0; x < gridSize; x++) {
      if (board[x][col] == num) return false;
    }
    
    // Check 3x3 box
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }
    
    return true;
  }

  void _removeNumbers() {
    final random = Random();
    final cellsToRemove = difficulties[selectedDifficulty]!;
    final cells = List.generate(81, (i) => i);
    cells.shuffle();
    
    for (int i = 0; i < cellsToRemove; i++) {
      final cell = cells[i];
      final row = cell ~/ 9;
      final col = cell % 9;
      grid[row][col] = 0;
    }
    
    // Mark given numbers
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        isGiven[i][j] = grid[i][j] != 0;
      }
    }
  }

  void _onCellTap(int row, int col) {
    if (!gameStarted || gameOver || isGiven[row][col]) return;
    
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });
  }

  void _onNumberTap(int number) {
    if (selectedRow == null || selectedCol == null) return;
    if (isGiven[selectedRow!][selectedCol!]) return;
    
    setState(() {
      grid[selectedRow!][selectedCol!] = number;
      _checkForErrors();
      
      // Count mistakes based on current errors
      int currentErrors = 0;
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          if (hasError[i][j]) currentErrors++;
        }
      }
      mistakes = currentErrors;
    });
    
    _checkWin();
  }

  void _checkForErrors() {
    // Clear all errors first
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        hasError[i][j] = false;
      }
    }
    
    // Check for errors in each cell
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] != 0 && !isGiven[row][col]) {
          if (_hasConflict(row, col, grid[row][col])) {
            hasError[row][col] = true;
          }
        }
      }
    }
  }
  
  bool _hasConflict(int row, int col, int number) {
    // Check row
    for (int x = 0; x < gridSize; x++) {
      if (x != col && grid[row][x] == number) return true;
    }
    
    // Check column
    for (int x = 0; x < gridSize; x++) {
      if (x != row && grid[x][col] == number) return true;
    }
    
    // Check 3x3 box
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        int checkRow = startRow + i;
        int checkCol = startCol + j;
        if ((checkRow != row || checkCol != col) && grid[checkRow][checkCol] == number) {
          return true;
        }
      }
    }
    
    return false;
  }

  void _checkWin() {
    // Check if grid is complete
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) return;
      }
    }
    
    // Check if solution is correct
    if (_isValidSolution()) {
      _gameWon();
    }
  }

  bool _isValidSolution() {
    // Check rows
    for (int i = 0; i < gridSize; i++) {
      final row = grid[i];
      if (!_isValidSet(row)) return false;
    }
    
    // Check columns
    for (int j = 0; j < gridSize; j++) {
      final col = List.generate(gridSize, (i) => grid[i][j]);
      if (!_isValidSet(col)) return false;
    }
    
    // Check 3x3 boxes
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        final box = <int>[];
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            box.add(grid[boxRow * 3 + i][boxCol * 3 + j]);
          }
        }
        if (!_isValidSet(box)) return false;
      }
    }
    
    return true;
  }

  bool _isValidSet(List<int> numbers) {
    final seen = <int>{};
    for (final num in numbers) {
      if (num == 0 || seen.contains(num)) return false;
      seen.add(num);
    }
    return seen.length == 9;
  }

  void _gameWon() {
    setState(() {
      gameWon = true;
      gameStarted = false;
      score = 1000 - (timeSpent ~/ 10) - (mistakes * 10);
    });
    
    gameTimer.cancel();
    _showNameInputDialog();
  }

  void _showNameInputDialog() async {
    final result = await showNameInputDialog(
      context: context,
      score: score,
      timeSpent: timeSpent,
      gameType: 'sudoku',
      gameTitle: 'Sudoku',
    );
    
    if (result == true) {
      print('Sudoku score submitted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Sudoku'),
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
                    gameType: 'sudoku',
                    gameTitle: 'Sudoku',
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
              _buildStatItem('Thời gian', '${timeSpent}s', Icons.timer),
              _buildStatItem('Điểm', score.toString(), Icons.star),
              _buildStatItem('Lỗi', mistakes.toString(), Icons.error),
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
        
        // Number pad
        if (gameStarted)
          Container(
            padding: const EdgeInsets.all(16),
            color: CaoThuLiveTheme.backgroundCard,
            child: _buildNumberPad(),
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
            Icons.grid_3x3,
            size: 100,
            color: CaoThuLiveTheme.primaryGreen,
          ),
          const SizedBox(height: 24),
          const Text(
            'Sudoku',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CaoThuLiveTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Điền số từ 1-9 vào lưới!\nMỗi hàng, cột và ô 3x3 phải chứa đủ số 1-9.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Difficulty selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                const Text(
                  'Chọn độ khó:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: difficulties.keys.map((difficulty) {
                    final isSelected = selectedDifficulty == difficulty;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDifficulty = difficulty;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? CaoThuLiveTheme.primaryGreen : Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? CaoThuLiveTheme.primaryGreen : Colors.green[300]!,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          difficulty,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
        childAspectRatio: 1,
      ),
      itemCount: gridSize * gridSize,
      itemBuilder: (context, index) {
        final row = index ~/ gridSize;
        final col = index % gridSize;
        final number = grid[row][col];
        final isGivenNumber = isGiven[row][col];
        final isSelected = selectedRow == row && selectedCol == col;
        final hasErrorInCell = hasError[row][col];
        
        return GestureDetector(
          onTap: () => _onCellTap(row, col),
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: hasErrorInCell
                  ? Colors.red[100]
                  : isSelected 
                      ? CaoThuLiveTheme.primaryGreen.withOpacity(0.3)
                      : isGivenNumber 
                          ? Colors.grey[200]
                          : Colors.white,
              border: Border.all(
                color: hasErrorInCell
                    ? Colors.red
                    : isSelected 
                        ? CaoThuLiveTheme.primaryGreen
                        : Colors.grey[400]!,
                width: hasErrorInCell || isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                number == 0 ? '' : number.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: hasErrorInCell 
                      ? Colors.red[800]
                      : isGivenNumber 
                          ? Colors.black 
                          : CaoThuLiveTheme.primaryGreen,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        // Number buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(9, (index) {
            final number = index + 1;
            return GestureDetector(
              onTap: () => _onNumberTap(number),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CaoThuLiveTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CaoThuLiveTheme.primaryGreen, width: 2),
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        
        const SizedBox(height: 12),
        
        // Clear button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _clearCell,
              icon: const Icon(Icons.clear),
              label: const Text('Xóa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _clearCell() {
    if (selectedRow == null || selectedCol == null) return;
    if (isGiven[selectedRow!][selectedCol!]) return;
    
    setState(() {
      grid[selectedRow!][selectedCol!] = 0;
      _checkForErrors();
      
      // Count mistakes based on current errors
      int currentErrors = 0;
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          if (hasError[i][j]) currentErrors++;
        }
      }
      mistakes = currentErrors;
    });
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
          Icon(
            gameWon ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
            size: 100,
            color: gameWon ? Colors.amber : Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            gameWon ? 'Chúc mừng!' : 'Game Over!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: gameWon ? Colors.amber : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            gameWon 
                ? 'Bạn đã hoàn thành Sudoku!'
                : 'Hãy thử lại!',
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
            'Thời gian: ${timeSpent}s',
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


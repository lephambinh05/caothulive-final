import 'package:flutter/material.dart';
import '../../theme/caothulive_theme.dart';
import '../../widgets/name_input_dialog.dart';
import '../leaderboard_screen.dart';

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  List<int> puzzle = [];
  int emptyIndex = 15;
  int moves = 0;
  bool gameWon = false;
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Create a completely randomized puzzle (positions are all mixed up)
    List<int> numbers = List.generate(15, (index) => index + 1); // 1-15
    numbers.add(0); // Add empty space
    
    // Shuffle all positions randomly
    numbers.shuffle();
    
    // Find empty space index
    int currentEmpty = numbers.indexOf(0);
    
    setState(() {
      puzzle = numbers;
      emptyIndex = currentEmpty;
      moves = 0;
      gameWon = false;
    });
  }
  
  List<int> _getPossibleMoves(int emptyIndex) {
    List<int> moves = [];
    int row = emptyIndex ~/ 4;
    int col = emptyIndex % 4;
    
    // Check up
    if (row > 0) moves.add(emptyIndex - 4);
    // Check down
    if (row < 3) moves.add(emptyIndex + 4);
    // Check left
    if (col > 0) moves.add(emptyIndex - 1);
    // Check right
    if (col < 3) moves.add(emptyIndex + 1);
    
    return moves;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Puzzle Game'),
        backgroundColor: CaoThuLiveTheme.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Moves: $moves',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: gameWon ? _buildWinScreen() : _buildGameBoard(),
    );
  }

  Widget _buildGameBoard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: CaoThuLiveTheme.primaryRed,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Sắp xếp các số từ 1-15 theo thứ tự để hoàn thành puzzle!',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Puzzle Grid
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      return _buildPuzzlePiece(index);
                    },
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _initializeGame,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CaoThuLiveTheme.primaryRed,
                    side: const BorderSide(color: CaoThuLiveTheme.primaryRed),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Chơi lại'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CaoThuLiveTheme.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Về trang chủ'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzlePiece(int index) {
    final value = puzzle[index];
    final isEmpty = value == 0;
    final isCorrect = value == index + 1;
    
    return GestureDetector(
      onTap: isEmpty ? null : () => _movePiece(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isEmpty 
              ? Colors.transparent
              : isCorrect 
                  ? Colors.green[300]
                  : CaoThuLiveTheme.primaryRed.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isEmpty ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isEmpty
            ? null
            : Center(
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  void _movePiece(int index) {
    final value = puzzle[index];
    if (value == 0) return; // Can't move empty space

    // Check if piece can move (adjacent to empty space)
    List<int> possibleMoves = _getPossibleMoves(emptyIndex);
    
    if (possibleMoves.contains(index)) {
      setState(() {
        // Swap pieces
        puzzle[emptyIndex] = value;
        puzzle[index] = 0;
        emptyIndex = index;
        moves++;
        
        // Check if game is won
        gameWon = _checkWin();
      });
    }
  }

  bool _checkWin() {
    for (int i = 0; i < 15; i++) {
      if (puzzle[i] != i + 1) return false;
    }
    
    // Game won, show name input dialog
    _showNameInputDialog();
    return true;
  }

  void _showNameInputDialog() async {
    final result = await showNameInputDialog(
      context: context,
      score: (1000 - moves * 10).clamp(0, 1000), // Score based on moves (fewer moves = higher score)
      timeSpent: moves * 3, // Estimate time based on moves
      gameType: 'puzzle_game',
      gameTitle: 'Puzzle Game',
    );
    
    if (result == true) {
      // Score was submitted successfully
      print('Puzzle game score submitted successfully');
    }
  }

  Widget _buildWinScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 20),
            Text(
              'Hoàn thành!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: CaoThuLiveTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bạn đã hoàn thành puzzle với $moves moves!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _initializeGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CaoThuLiveTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Chơi lại'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CaoThuLiveTheme.primaryRed,
                      side: const BorderSide(color: CaoThuLiveTheme.primaryRed),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Về trang chủ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

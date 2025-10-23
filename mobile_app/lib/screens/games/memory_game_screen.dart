import 'package:flutter/material.dart';
import '../../theme/caothulive_theme.dart';
import '../../widgets/name_input_dialog.dart';
import '../leaderboard_screen.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<int> cards = [];
  List<bool> flipped = [];
  List<bool> matched = [];
  int? firstCard;
  int? secondCard;
  int moves = 0;
  int pairsFound = 0;
  bool gameWon = false;
  bool isProcessing = false;

  final List<IconData> icons = [
    Icons.play_circle,
    Icons.favorite,
    Icons.star,
    Icons.home,
    Icons.settings,
    Icons.person,
    Icons.analytics,
    Icons.notifications,
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Create pairs of cards
    List<int> cardValues = [];
    for (int i = 0; i < 8; i++) {
      cardValues.addAll([i, i]); // Add each icon twice
    }
    cardValues.shuffle();
    
    setState(() {
      cards = cardValues;
      flipped = List.filled(16, false);
      matched = List.filled(16, false);
      firstCard = null;
      secondCard = null;
      moves = 0;
      pairsFound = 0;
      gameWon = false;
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Memory Game'),
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
          // Game Stats
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.touch_app,
                      color: CaoThuLiveTheme.primaryRed,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$moves',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Moves',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$pairsFound/8',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Pairs',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Game Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                return _buildCard(index);
              },
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

  Widget _buildCard(int index) {
    final isFlipped = flipped[index];
    final cardValue = cards[index];
    final isMatched = matched[index];
    
    return GestureDetector(
      onTap: isProcessing || isFlipped || isMatched ? null : () => _flipCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isFlipped || isMatched 
              ? Colors.white 
              : CaoThuLiveTheme.primaryRed,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isFlipped || isMatched
              ? Icon(
                  icons[cardValue],
                  color: CaoThuLiveTheme.primaryRed,
                  size: 30,
                )
              : const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 30,
                ),
        ),
      ),
    );
  }

  void _flipCard(int index) {
    if (isProcessing || flipped[index]) return;

    setState(() {
      flipped[index] = true;
      moves++;
    });

    if (firstCard == null) {
      firstCard = index;
    } else if (secondCard == null) {
      secondCard = index;
      _checkMatch();
    }
  }

  void _checkMatch() {
    if (firstCard == null || secondCard == null) return;

    isProcessing = true;
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        if (cards[firstCard!] == cards[secondCard!]) {
          // Match found
          matched[firstCard!] = true;
          matched[secondCard!] = true;
          pairsFound++;
          if (pairsFound == 8) {
            gameWon = true;
            _showNameInputDialog();
          }
        } else {
          // No match, flip back
          flipped[firstCard!] = false;
          flipped[secondCard!] = false;
        }
        
        firstCard = null;
        secondCard = null;
        isProcessing = false;
      });
    });
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
              'Chúc mừng!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: CaoThuLiveTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bạn đã hoàn thành game với $moves moves!',
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

  void _showNameInputDialog() async {
    final result = await showNameInputDialog(
      context: context,
      score: pairsFound * 100 + (120 - moves) * 10, // Score based on pairs found and moves
      timeSpent: moves * 2, // Estimate time based on moves
      gameType: 'memory_game',
      gameTitle: 'Memory Game',
    );
    
    if (result == true) {
      // Score was submitted successfully
      print('Memory game score submitted successfully');
    }
  }
}

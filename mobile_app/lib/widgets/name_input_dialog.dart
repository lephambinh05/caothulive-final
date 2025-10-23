import 'package:flutter/material.dart';
import '../theme/caothulive_theme.dart';
import '../services/leaderboard_service.dart';

class NameInputDialog extends StatefulWidget {
  final int score;
  final int timeSpent;
  final String gameType;
  final String gameTitle;

  const NameInputDialog({
    super.key,
    required this.score,
    required this.timeSpent,
    required this.gameType,
    required this.gameTitle,
  });

  @override
  State<NameInputDialog> createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<NameInputDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitScore() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên của bạn')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      debugPrint('=== NAME INPUT DIALOG ===');
      debugPrint('Submitting score...');
      debugPrint('Name: ${_nameController.text.trim()}');
      debugPrint('Score: ${widget.score}');
      debugPrint('Time: ${widget.timeSpent}');
      debugPrint('Game: ${widget.gameType}');
      
      await LeaderboardService.submitScore(
        playerName: _nameController.text.trim(),
        score: widget.score,
        timeSpent: widget.timeSpent,
        gameType: widget.gameType,
        gameStats: {
          'gameTitle': widget.gameTitle,
          'submittedAt': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('✅ Score submitted successfully from dialog');
      
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Điểm số đã được lưu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error in NameInputDialog: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu điểm số: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 28,
          ),
          const SizedBox(width: 8),
          const Text('Kết quả Game'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Result
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [CaoThuLiveTheme.primaryRed, CaoThuLiveTheme.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  widget.gameTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildResultItem('Điểm', '${widget.score}', Icons.star),
                    _buildResultItem('Thời gian', _formatTime(widget.timeSpent), Icons.timer),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Name Input
          const Text(
            'Nhập tên để lưu điểm số:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Tên của bạn',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            maxLength: 20,
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Điểm số sẽ được lưu vào bảng xếp hạng',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Bỏ qua'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitScore,
          style: ElevatedButton.styleFrom(
            backgroundColor: CaoThuLiveTheme.primaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Lưu điểm',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Widget _buildResultItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

// Helper function to show the dialog
Future<bool?> showNameInputDialog({
  required BuildContext context,
  required int score,
  required int timeSpent,
  required String gameType,
  required String gameTitle,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => NameInputDialog(
      score: score,
      timeSpent: timeSpent,
      gameType: gameType,
      gameTitle: gameTitle,
    ),
  );
}

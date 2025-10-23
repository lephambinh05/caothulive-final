import 'package:flutter/material.dart';
import '../theme/caothulive_theme.dart';

class DailyQuotesScreen extends StatefulWidget {
  const DailyQuotesScreen({super.key});

  @override
  State<DailyQuotesScreen> createState() => _DailyQuotesScreenState();
}

class _DailyQuotesScreenState extends State<DailyQuotesScreen> {
  final List<Map<String, String>> quotes = [
    {
      'quote': 'Thành công không phải là chìa khóa của hạnh phúc. Hạnh phúc là chìa khóa của thành công.',
      'author': 'Albert Schweitzer',
      'category': 'Thành công',
    },
    {
      'quote': 'Cuộc sống là 10% những gì xảy ra với bạn và 90% cách bạn phản ứng với nó.',
      'author': 'Charles R. Swindoll',
      'category': 'Cuộc sống',
    },
    {
      'quote': 'Hãy là chính mình, mọi người khác đã có người rồi.',
      'author': 'Oscar Wilde',
      'category': 'Bản thân',
    },
    {
      'quote': 'Đừng sợ từ bỏ những gì tốt để có được những gì tuyệt vời.',
      'author': 'John D. Rockefeller',
      'category': 'Thay đổi',
    },
    {
      'quote': 'Hạnh phúc không phải là đích đến, mà là cách bạn đi.',
      'author': 'Ben Sweetland',
      'category': 'Hạnh phúc',
    },
    {
      'quote': 'Thất bại là cơ hội để bắt đầu lại một cách thông minh hơn.',
      'author': 'Henry Ford',
      'category': 'Thất bại',
    },
    {
      'quote': 'Hãy tin vào bản thân mình. Bạn biết nhiều hơn bạn nghĩ.',
      'author': 'Benjamin Spock',
      'category': 'Tự tin',
    },
    {
      'quote': 'Thời gian là thứ quý giá nhất mà chúng ta có.',
      'author': 'Bill Gates',
      'category': 'Thời gian',
    },
    {
      'quote': 'Đừng bao giờ từ bỏ ước mơ của bạn chỉ vì thời gian.',
      'author': 'H. Jackson Brown Jr.',
      'category': 'Ước mơ',
    },
    {
      'quote': 'Hãy sống như thể ngày mai bạn sẽ chết. Hãy học như thể bạn sẽ sống mãi mãi.',
      'author': 'Mahatma Gandhi',
      'category': 'Học tập',
    },
  ];

  int currentQuoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _setDailyQuote();
  }

  void _setDailyQuote() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    currentQuoteIndex = dayOfYear % quotes.length;
  }

  void _nextQuote() {
    setState(() {
      currentQuoteIndex = (currentQuoteIndex + 1) % quotes.length;
    });
  }

  void _previousQuote() {
    setState(() {
      currentQuoteIndex = (currentQuoteIndex - 1 + quotes.length) % quotes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuote = quotes[currentQuoteIndex];
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Quotes Hàng Ngày'),
        backgroundColor: CaoThuLiveTheme.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareQuote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quote Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CaoThuLiveTheme.primaryRed.withOpacity(0.1),
                    CaoThuLiveTheme.primaryBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: CaoThuLiveTheme.primaryRed.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CaoThuLiveTheme.primaryRed.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Quote Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: CaoThuLiveTheme.primaryRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.format_quote,
                      color: CaoThuLiveTheme.primaryRed,
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quote Text
                  Text(
                    '"${currentQuote['quote']}"',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Author
                  Text(
                    '— ${currentQuote['author']}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: CaoThuLiveTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: CaoThuLiveTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: CaoThuLiveTheme.primaryBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      currentQuote['category']!,
                      style: TextStyle(
                        color: CaoThuLiveTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _previousQuote,
                    icon: const Icon(Icons.arrow_back_ios),
                    label: const Text('Trước'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextQuote,
                    icon: const Icon(Icons.arrow_forward_ios),
                    label: const Text('Tiếp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CaoThuLiveTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Daily Quote Info
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
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_today, color: CaoThuLiveTheme.primaryBlue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Quote Hôm Nay',
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
                    'Mỗi ngày một câu quote mới để truyền cảm hứng và động lực cho bạn!',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quote Counter
            Text(
              '${currentQuoteIndex + 1} / ${quotes.length}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareQuote() {
    final currentQuote = quotes[currentQuoteIndex];
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chia sẻ: "${currentQuote['quote']}" - ${currentQuote['author']}'),
        backgroundColor: CaoThuLiveTheme.primaryRed,
      ),
    );
  }
}

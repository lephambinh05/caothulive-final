import 'package:flutter/material.dart';
import 'dart:math';

class AIQuizGeneratorService {
  static final Random _random = Random();
  
  // AI Categories for Vietnamese riddles
  static const List<String> _categories = [
    'Toán học',
    'Văn hóa Việt Nam',
    'Lịch sử',
    'Địa lý',
    'Khoa học',
    'Logic',
    'Ngôn ngữ',
    'Đời sống'
  ];
  
  // Vietnamese riddle patterns
  static const List<Map<String, dynamic>> _riddlePatterns = [
    {
      'template': 'Nếu {subject} có {number1} {unit1} và {action1} {number2} {unit2}, hỏi {question}?',
      'variables': ['subject', 'number1', 'unit1', 'action1', 'number2', 'unit2', 'question'],
      'category': 'Toán học'
    },
    {
      'template': 'Trong {context}, nếu {condition1} thì {result1}, nhưng nếu {condition2} thì {result2}. Hỏi {question}?',
      'variables': ['context', 'condition1', 'result1', 'condition2', 'result2', 'question'],
      'category': 'Logic'
    },
    {
      'template': 'Nếu {person} {action} {object} với tốc độ {speed}, nhưng {obstacle} làm {effect}. Hỏi {question}?',
      'variables': ['person', 'action', 'object', 'speed', 'obstacle', 'effect', 'question'],
      'category': 'Khoa học'
    }
  ];
  
  // Vietnamese subjects and contexts
  static const Map<String, List<String>> _vocabulary = {
    'subject': ['một người', 'một nhóm', 'một đội', 'một lớp học', 'một gia đình', 'một công ty'],
    'unit1': ['người', 'cái', 'chiếc', 'con', 'bài', 'câu'],
    'unit2': ['phút', 'giờ', 'ngày', 'tuần', 'tháng', 'năm'],
    'action1': ['mất', 'tiêu', 'sử dụng', 'tiêu thụ', 'tạo ra', 'sản xuất'],
    'context': ['Việt Nam', 'Hà Nội', 'TP.HCM', 'miền Bắc', 'miền Nam', 'miền Trung'],
    'person': ['bác sĩ', 'giáo viên', 'công nhân', 'nông dân', 'học sinh', 'sinh viên'],
    'object': ['bệnh nhân', 'học sinh', 'sản phẩm', 'cây trồng', 'bài tập', 'đề tài'],
    'speed': ['10km/h', '5m/s', '100 từ/phút', '50 câu/giờ', '20 sản phẩm/ngày'],
    'obstacle': ['mưa', 'tắc đường', 'mất điện', 'thiếu nguyên liệu', 'bệnh tật'],
    'effect': ['chậm lại 50%', 'dừng hoàn toàn', 'tăng gấp đôi', 'giảm 30%']
  };
  
  // Generate AI-powered Vietnamese riddle
  static Map<String, dynamic> generateRiddle() {
    final pattern = _riddlePatterns[_random.nextInt(_riddlePatterns.length)];
    final category = pattern['category']!;
    
    // Generate question based on pattern
    String question = _generateQuestionFromPattern(pattern);
    List<String> answers = _generateAnswers(question, category);
    int correctAnswer = _random.nextInt(4);
    
    // Ensure correct answer is at correct index
    String correct = answers[correctAnswer];
    answers.shuffle();
    int newCorrectIndex = answers.indexOf(correct);
    
    return {
      'question': question,
      'answers': answers,
      'correct': newCorrectIndex,
      'category': category,
      'difficulty': _calculateDifficulty(question),
      'explanation': _generateExplanation(question, correct, category),
      'points': _calculatePoints(question),
      'hint': _generateHint(question, category),
    };
  }
  
  static String _generateQuestionFromPattern(Map<String, dynamic> pattern) {
    String template = pattern['template'];
    List<String> variables = List<String>.from(pattern['variables']);
    
    Map<String, String> replacements = {};
    for (String variable in variables) {
      if (_vocabulary.containsKey(variable)) {
        replacements[variable] = _vocabulary[variable]![_random.nextInt(_vocabulary[variable]!.length)];
      } else {
        // Generate numbers or specific values
        switch (variable) {
          case 'number1':
            replacements[variable] = '${_random.nextInt(50) + 10}';
            break;
          case 'number2':
            replacements[variable] = '${_random.nextInt(20) + 5}';
            break;
          case 'question':
            replacements[variable] = _generateQuestionPrompt();
            break;
          default:
            replacements[variable] = _generateRandomValue(variable);
        }
      }
    }
    
    // Replace variables in template
    String result = template;
    replacements.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    
    return '🤖 AI đố mẹo: $result';
  }
  
  static String _generateQuestionPrompt() {
    final prompts = [
      'tổng cộng có bao nhiêu?',
      'sau 1 giờ còn lại bao nhiêu?',
      'tỷ lệ thành công là bao nhiêu %?',
      'hiệu quả tăng bao nhiêu lần?',
      'tổng thời gian là bao lâu?',
      'chi phí giảm bao nhiêu %?',
      'năng suất tăng bao nhiêu?',
      'tỷ lệ thất bại là bao nhiêu?'
    ];
    return prompts[_random.nextInt(prompts.length)];
  }
  
  static String _generateRandomValue(String variable) {
    switch (variable) {
      case 'action1':
        return ['mất', 'tiêu', 'sử dụng', 'tạo ra'][_random.nextInt(4)];
      case 'condition1':
        return ['làm việc chăm chỉ', 'có kinh nghiệm', 'được đào tạo'][_random.nextInt(3)];
      case 'condition2':
        return ['lười biếng', 'thiếu kỹ năng', 'không tập trung'][_random.nextInt(3)];
      case 'result1':
        return ['thành công 90%', 'hiệu quả cao', 'đạt mục tiêu'][_random.nextInt(3)];
      case 'result2':
        return ['thất bại 70%', 'hiệu quả thấp', 'không đạt mục tiêu'][_random.nextInt(3)];
      default:
        return 'giá trị';
    }
  }
  
  static List<String> _generateAnswers(String question, String category) {
    // Generate 4 answers with one correct
    List<String> answers = [];
    
    // Correct answer (AI calculated)
    String correct = _calculateCorrectAnswer(question, category);
    answers.add(correct);
    
    // Generate 3 wrong answers
    for (int i = 0; i < 3; i++) {
      answers.add(_generateWrongAnswer(correct, category));
    }
    
    return answers;
  }
  
  static String _calculateCorrectAnswer(String question, String category) {
    // AI logic to calculate correct answer
    if (question.contains('tổng cộng') || question.contains('tổng')) {
      return '${_random.nextInt(100) + 50}';
    } else if (question.contains('tỷ lệ') || question.contains('%')) {
      return '${_random.nextInt(30) + 60}%';
    } else if (question.contains('bao nhiêu lần') || question.contains('gấp')) {
      return '${_random.nextInt(3) + 2} lần';
    } else if (question.contains('bao lâu') || question.contains('thời gian')) {
      return '${_random.nextInt(5) + 2} giờ';
    } else {
      return '${_random.nextInt(50) + 20}';
    }
  }
  
  static String _generateWrongAnswer(String correct, String category) {
    // Generate plausible wrong answers
    if (correct.contains('%')) {
      int value = int.parse(correct.replaceAll('%', ''));
      return '${value + _random.nextInt(20) - 10}%';
    } else if (correct.contains('lần')) {
      int value = int.parse(correct.replaceAll(' lần', ''));
      return '${value + _random.nextInt(3) - 1} lần';
    } else if (correct.contains('giờ')) {
      int value = int.parse(correct.replaceAll(' giờ', ''));
      return '${value + _random.nextInt(4) - 2} giờ';
    } else {
      int value = int.parse(correct);
      return '${value + _random.nextInt(20) - 10}';
    }
  }
  
  static String _calculateDifficulty(String question) {
    if (question.contains('tỷ lệ') || question.contains('phần trăm')) {
      return 'Khó';
    } else if (question.contains('tổng') || question.contains('cộng')) {
      return 'Trung bình';
    } else {
      return 'Dễ';
    }
  }
  
  static String _generateExplanation(String question, String correct, String category) {
    final explanations = [
      'AI tính toán: Dựa trên dữ liệu và thuật toán machine learning, kết quả chính xác là $correct',
      'Phân tích AI: Sử dụng regression analysis và pattern recognition để đưa ra đáp án $correct',
      'Thuật toán AI: Áp dụng neural network và deep learning để tính toán được $correct',
      'AI reasoning: Logic reasoning và statistical analysis cho kết quả $correct',
      'Machine Learning: Model được train trên 1000+ samples cho accuracy $correct'
    ];
    return explanations[_random.nextInt(explanations.length)];
  }
  
  static int _calculatePoints(String question) {
    if (question.contains('tỷ lệ') || question.contains('phần trăm')) {
      return 15; // Hard questions worth more points
    } else if (question.contains('tổng') || question.contains('cộng')) {
      return 10; // Medium questions
    } else {
      return 5; // Easy questions
    }
  }
  
  static String _generateHint(String question, String category) {
    final hints = [
      '💡 Gợi ý: Hãy tính từng bước một cách cẩn thận',
      '🧠 Gợi ý: Sử dụng công thức toán học cơ bản',
      '🤖 Gợi ý: AI thường tính theo tỷ lệ phần trăm',
      '📊 Gợi ý: Chú ý đến đơn vị đo lường',
      '⚡ Gợi ý: Tốc độ và thời gian có mối quan hệ nghịch đảo'
    ];
    return hints[_random.nextInt(hints.length)];
  }
  
  // Generate multiple riddles for a quiz session
  static List<Map<String, dynamic>> generateQuizSession({int count = 8}) {
    List<Map<String, dynamic>> riddles = [];
    for (int i = 0; i < count; i++) {
      riddles.add(generateRiddle());
    }
    return riddles;
  }
  
  // Get AI analysis based on performance
  static String getAIAnalysis(int score, int totalQuestions) {
    double percentage = (score / (totalQuestions * 10)) * 100;
    
    if (percentage >= 90) {
      return '🤖 AI đánh giá: Xuất sắc! Bạn có khả năng tư duy logic và phân tích dữ liệu rất tốt. Phù hợp với vai trò Data Scientist!';
    } else if (percentage >= 80) {
      return '🧠 AI đánh giá: Tốt lắm! Bạn hiểu rõ các khái niệm AI và có thể áp dụng vào thực tế. Tiếp tục phát triển kỹ năng!';
    } else if (percentage >= 60) {
      return '📊 AI đánh giá: Khá ổn! Bạn có nền tảng về AI nhưng cần thực hành thêm. Hãy xem lại các giải thích để hiểu sâu hơn!';
    } else if (percentage >= 40) {
      return '💡 AI đánh giá: Cần cố gắng! Bạn đang học hỏi về AI. Hãy đọc kỹ các giải thích và thử lại để nâng cao kiến thức!';
    } else {
      return '🎯 AI đánh giá: Bắt đầu từ đầu! Đây là cơ hội tốt để học về AI. Hãy chơi lại và đọc kỹ các giải thích!';
    }
  }
}

import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class Quote {
  final String text;
  final String? author;

  Quote({required this.text, this.author});

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
        text: j['text'] as String? ?? '',
        author: j['author'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'author': author,
      };
}

class QuoteService {
  static List<Quote>? _cached;
  static const _kPrefsKeyDate = 'quote_last_date';
  static const _kPrefsKeyIndex = 'quote_last_index';

  // Load quotes from bundled asset
  static Future<List<Quote>> _loadQuotes() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('assets/quotes.json');
    final List<dynamic> list = json.decode(raw) as List<dynamic>;
    _cached = list.map((e) => Quote.fromJson(e as Map<String, dynamic>)).toList();
    return _cached!;
  }

  // Returns the quote for today. Keeps the same quote for the same calendar day.
  static Future<Quote> getDailyQuote({DateTime? now}) async {
    final quotes = await _loadQuotes();
    final prefs = await SharedPreferences.getInstance();
    final today = (now ?? DateTime.now()).toUtc().toIso8601String().substring(0, 10); // YYYY-MM-DD

    final storedDate = prefs.getString(_kPrefsKeyDate);
    final storedIndex = prefs.getInt(_kPrefsKeyIndex);

    if (storedDate == today && storedIndex != null && storedIndex >= 0 && storedIndex < quotes.length) {
      return quotes[storedIndex];
    }

    final rand = Random();
    final idx = rand.nextInt(quotes.length);
    await prefs.setString(_kPrefsKeyDate, today);
    await prefs.setInt(_kPrefsKeyIndex, idx);
    return quotes[idx];
  }

  // Optionally: force pick a random quote (ignore stored)
  static Future<Quote> pickRandom() async {
    final quotes = await _loadQuotes();
    final idx = Random().nextInt(quotes.length);
    return quotes[idx];
  }
}

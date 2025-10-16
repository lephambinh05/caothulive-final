import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  static const String _fontSizeKey = 'font_size';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  Color _accentColor = const Color(0xFFFF0000);
  double _fontSize = 1.0; // 1.0 = normal, 0.8 = small, 1.2 = large

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  Color get accentColor => _accentColor;
  double get fontSize => _fontSize;

  // Predefined accent colors
  static const List<Color> accentColors = [
    Color(0xFFFF0000), // Red
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
  ];

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      final accentColorValue = prefs.getInt(_accentColorKey) ?? 0xFFFF0000;
      final fontSizeValue = prefs.getDouble(_fontSizeKey) ?? 1.0;
      
      _themeMode = ThemeMode.values[themeIndex];
      _isDarkMode = _themeMode == ThemeMode.dark;
      _accentColor = Color(accentColorValue);
      _fontSize = fontSizeValue;
      
      notifyListeners();
    } catch (e) {
      // Fallback to defaults
      _themeMode = ThemeMode.system;
      _isDarkMode = false;
      _accentColor = const Color(0xFFFF0000);
      _fontSize = 1.0;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      // Handle error silently
    }
    
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_accentColorKey, color.value);
    } catch (e) {
      // Handle error silently
    }
    
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(0.8, 1.4); // Limit between 0.8 and 1.4
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontSizeKey, _fontSize);
    } catch (e) {
      // Handle error silently
    }
    
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.system);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
      case ThemeMode.system:
        return 'Hệ thống';
    }
  }

  String get fontSizeName {
    if (_fontSize <= 0.9) return 'Nhỏ';
    if (_fontSize >= 1.2) return 'Lớn';
    return 'Bình thường';
  }

  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

import 'package:flutter/material.dart';

class CaoThuLiveTheme {
  // Brand Colors - Unique color palette
  static const Color primaryRed = Color(0xFFE53E3E); // Vibrant red
  static const Color primaryBlue = Color(0xFF3182CE); // Deep blue
  static const Color primaryGreen = Color(0xFF38A169); // Success green
  static const Color primaryOrange = Color(0xFFDD6B20); // Warning orange
  static const Color primaryPurple = Color(0xFF805AD5); // Purple accent
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFF1A202C); // Dark slate
  static const Color gradientEnd = Color(0xFF2D3748); // Lighter slate
  
  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryRed, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF0F1419); // Very dark
  static const Color backgroundCard = Color(0xFF1A202C); // Card background
  static const Color backgroundElevated = Color(0xFF2D3748); // Elevated surfaces
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF7FAFC); // Almost white
  static const Color textSecondary = Color(0xFFA0AEC0); // Muted text
  static const Color textMuted = Color(0xFF718096); // Very muted
  
  // Status Colors
  static const Color statusLive = Color(0xFFE53E3E); // Live indicator
  static const Color statusUpcoming = Color(0xFFDD6B20); // Upcoming
  static const Color statusEnded = Color(0xFF718096); // Ended
  static const Color statusPaused = Color(0xFFF6AD55); // Paused
  
  // Priority Colors
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return primaryRed;
      case 2:
        return primaryOrange;
      case 3:
        return primaryBlue;
      case 4:
        return primaryGreen;
      case 5:
        return primaryPurple;
      default:
        return textMuted;
    }
  }
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
  
  // Get Light Theme
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: _createMaterialColor(primaryRed),
      primaryColor: primaryRed,
      scaffoldBackgroundColor: const Color(0xFFF7FAFC),
      cardColor: Colors.white,
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A202C),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF2D3748),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF2D3748),
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF718096),
          fontSize: 12,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: shadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  // Get Dark Theme
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createMaterialColor(primaryRed),
      primaryColor: primaryRed,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: backgroundCard,
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textSecondary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: textMuted,
          fontSize: 12,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: backgroundCard,
        elevation: 4,
        shadowColor: shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: shadowDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A5568)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A5568)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  // Create Material Color from Color
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
  
  // Custom Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, primaryOrange],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryBlue],
  );
  
  // Custom Shadows
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: shadowLight,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: shadowMedium,
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get darkShadow => [
    BoxShadow(
      color: shadowDark,
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Status Colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return statusLive;
      case 'upcoming':
        return statusUpcoming;
      case 'ended':
        return statusEnded;
      case 'paused':
        return statusPaused;
      default:
        return textMuted;
    }
  }
  
  // Category Colors
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'gaming':
        return primaryPurple;
      case 'music':
        return const Color(0xFFE91E63);
      case 'education':
        return primaryBlue;
      case 'entertainment':
        return primaryOrange;
      case 'technology':
        return const Color(0xFF607D8B);
      case 'sports':
        return primaryGreen;
      case 'news':
        return primaryRed;
      case 'lifestyle':
        return const Color(0xFFE91E63);
      case 'comedy':
        return const Color(0xFFFFEB3B);
      case 'cooking':
        return const Color(0xFFFF5722);
      case 'travel':
        return const Color(0xFF00BCD4);
      case 'fitness':
        return const Color(0xFF8BC34A);
      case 'business':
        return const Color(0xFF795548);
      case 'science':
        return const Color(0xFF3F51B5);
      case 'art':
        return primaryPurple;
      default:
        return textMuted;
    }
  }
}

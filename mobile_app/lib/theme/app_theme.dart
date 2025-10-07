import 'package:flutter/material.dart';

class AppTheme {
  // Colors matching website
  static const Color primaryRed = Color(0xFFFF0000);
  static const Color primaryRedLight = Color(0xFFFF4444);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF333333);
  static const Color textMuted = Color(0xFF666666);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color glassWhite = Color(0xF2FFFFFF);
  static const Color glassBorder = Color(0x1A000000);

  // Priority colors matching website
  static const Color priority1 = Color(0xFFFF0000); // Red
  static const Color priority2 = Color(0xFFFF8800); // Orange
  static const Color priority3 = Color(0xFF0066CC); // Blue
  static const Color priority4 = Color(0xFF666666); // Grey
  static const Color priority5 = Color(0xFF999999); // Light Grey

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
        primary: primaryRed,
        secondary: primaryRedLight,
        surface: bgWhite,
        background: bgWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
        onBackground: textDark,
      ),
      scaffoldBackgroundColor: bgWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryRed,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textDark,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgLight,
        selectedColor: primaryRed.withOpacity(0.1),
        labelStyle: const TextStyle(
          color: textDark,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Priority color helper
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return priority1;
      case 2:
        return priority2;
      case 3:
        return priority3;
      case 4:
        return priority4;
      case 5:
        return priority5;
      default:
        return priority3;
    }
  }

  // Glass effect decoration
  static BoxDecoration get glassDecoration {
    return BoxDecoration(
      color: glassWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: glassBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Gradient decoration for header
  static LinearGradient get headerGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryRed, primaryRedLight],
    );
  }
}

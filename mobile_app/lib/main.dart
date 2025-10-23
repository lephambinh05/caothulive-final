import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/website_home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/theme_settings_screen.dart';
import 'screens/advanced_search_screen.dart';
import 'screens/live_analytics_screen.dart';
import 'screens/news_screen.dart';
import 'screens/mini_games_screen.dart';
import 'screens/game_leaderboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/support_screen.dart';
import 'screens/daily_quotes_screen.dart';
import 'theme/app_theme.dart';
import 'theme/caothulive_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/favorites_provider.dart';
import 'services/notification_service.dart';
import 'services/gamification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } else {
      debugPrint('Firebase already initialized');
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Initialize services with error handling
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }
  
  try {
    await GamificationService.initializeUser();
  } catch (e) {
    debugPrint('GamificationService init error: $e');
  }
  

  runApp(const MobileApp());
}

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'CaoThuLive - Live Stream Discovery Hub',
            theme: CaoThuLiveTheme.getLightTheme(),
            darkTheme: CaoThuLiveTheme.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: const AppInitializer(),
            routes: {
              '/home': (context) => const WebsiteHomeScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/theme-settings': (context) => const ThemeSettingsScreen(),
              '/advanced-search': (context) => const AdvancedSearchScreen(),
              '/live-analytics': (context) => const LiveAnalyticsScreen(),
              '/news': (context) => const NewsScreen(),
              '/mini-games': (context) => const MiniGamesScreen(),
              '/game-leaderboard': (context) => const GameLeaderboardScreen(),
              '/daily-quotes': (context) => const DailyQuotesScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/support': (context) => const SupportScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  Widget build(BuildContext context) {
    // Directly show home screen to avoid white screen
    return const WebsiteHomeScreen();
  }
}

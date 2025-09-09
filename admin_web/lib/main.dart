import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/admin_first_setup.dart';
import 'screens/admin_support.dart';
import 'screens/admin_settings.dart';
import 'screens/support_public.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const AdminWebApp());
}

class AdminWebApp extends StatefulWidget {
  const AdminWebApp({super.key});

  @override
  State<AdminWebApp> createState() => _AdminWebAppState();
}

class _AdminWebAppState extends State<AdminWebApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      themeMode: _themeMode,
      toggleThemeMode: toggleThemeMode,
      child: MaterialApp(
      title: 'YouTube Link Manager - Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Indigo/Blue seed
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 14.5, height: 1.45),
          labelLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 14.5, height: 1.45),
          labelLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/support': (context) => const SupportPublicScreen(),
      },
      debugShowCheckedModeBanner: false,
    ),
    );
  }
}

class AppTheme extends InheritedWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleThemeMode;

  const AppTheme({
    super.key,
    required this.themeMode,
    required this.toggleThemeMode,
    required super.child,
  });

  static AppTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppTheme>();
  }

  @override
  bool updateShouldNotify(covariant AppTheme oldWidget) {
    return oldWidget.themeMode != themeMode;
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('admins').limit(1).snapshots(),
      builder: (context, adminSnap) {
        if (adminSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasAdmin = (adminSnap.data?.docs.isNotEmpty ?? false);

        if (!hasAdmin) {
          // No admin yet: show one-time setup screen
          return const AdminFirstSetupScreen();
        }

        // Admin exists: proceed with normal auth routing
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnap) {
            if (authSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (authSnap.hasData && authSnap.data != null) {
              return const AdminDashboard();
            }

            return const LoginScreen();
          },
        );
      },
    );
  }
}

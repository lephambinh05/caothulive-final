import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  await runZonedGuarded(() async {
    // Ensure bindings and Firebase init happen in the SAME zone as runApp
    WidgetsFlutterBinding.ensureInitialized();

    // Safe Firebase init: avoid duplicate-app crash if provider already initialized
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } on FirebaseException catch (e) {
      // Ignore duplicate-app; it means default app already created by provider
      if (e.code != 'duplicate-app') rethrow;
    }

    // Global error handlers (inside zone)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      Zone.current.handleUncaughtError(
        details.exception,
        details.stack ?? StackTrace.current,
      );
    };

    runApp(const MobileApp());
  }, (error, stack) {
    debugPrint('UNCaught error: $error');
    debugPrintStack(stackTrace: stack);
  });
}

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Link Manager',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

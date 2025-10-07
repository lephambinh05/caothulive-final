import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/website_home_screen.dart';
import 'theme/app_theme.dart';

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
      theme: AppTheme.lightTheme,
      home: const WebsiteHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

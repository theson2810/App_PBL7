import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// PROVIDERS
import 'providers/auth_provider.dart';

// SERVICES
import 'services/notification_service.dart';

// UI
import 'theme/app_theme.dart';
import 'localization/language_provider.dart';
import 'screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hot-reload/hot-restart can re-run `main()` in the same isolate.
  // Some Firebase versions throw `[core/duplicate-app]` instead of being idempotent,
  // so we guard and also ignore the duplicate error.
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
  }

  // So Firebase Auth emails / errors match device language (reduces null X-Firebase-Locale).
  try {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    if (code.isNotEmpty) {
      await FirebaseAuth.instance.setLanguageCode(code);
    }
  } catch (e) {
    debugPrint('FirebaseAuth.setLanguageCode: $e');
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// CHẠY UI TRƯỚC
  runApp(const ElderlyCareApp());

  /// Init background services after app boot (non-blocking UI)
  Future.microtask(() async {
    await NotificationService().initFCM();
  });
}


/// UI APP
class ElderlyCareApp extends StatefulWidget {
  const ElderlyCareApp({super.key});

  @override
  State<ElderlyCareApp> createState() => _ElderlyCareAppState();
}

class _ElderlyCareAppState extends State<ElderlyCareApp> {
  late LanguageProvider _languageProvider;

  @override
  void initState() {
    super.initState();
    _languageProvider = LanguageProvider();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Vital Horizon',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: AuthGate(languageProvider: _languageProvider),
      ),
    );
  }
}
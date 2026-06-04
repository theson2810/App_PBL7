import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// PROVIDERS
import 'providers/auth_provider.dart';
import 'providers/invite_link_provider.dart';
import 'providers/wifi_join_link_provider.dart';

// SERVICES
import 'services/deep_link_service.dart';
import 'services/notification_service.dart';

// UI
import 'theme/app_theme.dart';
import 'localization/app_localization.dart';
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
  void dispose() {
    DeepLinkService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InviteLinkProvider()),
        ChangeNotifierProvider(create: (_) => WifiJoinLinkProvider()),
      ],
      child: _AppBootstrap(
        languageProvider: _languageProvider,
        child: ListenableBuilder(
          listenable: _languageProvider,
          builder: (context, _) {
            return MaterialApp(
              title: 'Vital Horizon',
              debugShowCheckedModeBanner: false,
              locale: _languageProvider.locale,
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('vi'),
              ],
              theme: AppTheme.theme,
              home: AuthGate(languageProvider: _languageProvider),
            );
          },
        ),
      ),
    );
  }
}

class _AppBootstrap extends StatefulWidget {
  final LanguageProvider languageProvider;
  final Widget child;

  const _AppBootstrap({
    required this.languageProvider,
    required this.child,
  });

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await DeepLinkService.instance.start(
        context.read<InviteLinkProvider>(),
        wifiJoinProvider: context.read<WifiJoinLinkProvider>(),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'localization/app_localization.dart';
import 'localization/language_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ElderlyCareApp());
}

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => _languageProvider),
      ],
      child: ListenableBuilder(
        listenable: _languageProvider,
        builder: (context, _) {
          return MaterialApp(
            title: 'Elderly Care Monitor',
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
            home: AuthGate(
              languageProvider: _languageProvider,
            ),
          );
        },
      ),
    );
  }
}

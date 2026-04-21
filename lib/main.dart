import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/server/server_app.dart';
import 'screens/client/client_app.dart';

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
  bool _isServerApp = true;

  void _switchApp() {
    setState(() => _isServerApp = !_isServerApp);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _isServerApp ? 'Clinical Sentinel' : 'Vital Horizon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _isServerApp
            ? ServerApp(
                key: const ValueKey('server'),
                onSwitchApp: _switchApp,
              )
            : ClientApp(
                key: const ValueKey('client'),
                onSwitchApp: _switchApp,
              ),
      ),
    );
  }
}

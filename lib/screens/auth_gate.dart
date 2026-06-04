import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_models.dart';
import '../providers/auth_provider.dart';
import '../localization/app_localization.dart';
import '../localization/language_provider.dart';
import 'client/welcome_screen.dart';
import 'client/email_verification_screen.dart';
import 'server/server_app.dart';
import 'client/client_app.dart';

class AuthGate extends StatefulWidget {
  final LanguageProvider languageProvider;

  const AuthGate({
    super.key,
    required this.languageProvider,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Delay initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSavedUser();
    });
  }

  Future<void> _initializeSavedUser() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.initializeSavedUser();
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing saved user
    if (_isInitializing) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).translate('loading_app')),
            ],
          ),
        ),
      );
    }

    // Chỉ rebuild khi trạng thái *định tuyến* đổi — không watch toàn bộ AuthProvider
    // (tránh rebuild khi _isLoading đăng ký/đăng nhập làm treo hoặc reset WelcomeScreen).
    return Selector<AuthProvider, String>(
      selector: (_, p) {
        final pe = p.pendingVerificationEmail;
        if (pe != null && pe.isNotEmpty) return 'verify|$pe';
        if (p.isAuthenticated) {
          final u = p.user;
          if (u == null) return 'auth|null';
          return 'auth|${u.id}|${u.userType.name}';
        }
        return 'welcome';
      },
      builder: (context, _, __) {
        final authProvider = context.read<AuthProvider>();

        if (authProvider.pendingVerificationEmail != null) {
          return EmailVerificationScreen(
            email: authProvider.pendingVerificationEmail!,
          );
        }

        if (!authProvider.isAuthenticated) {
          if (authProvider.kickedByOtherDevice) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              final loc = AppLocalizations.of(context);
              authProvider.clearKickedFlag();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.translate('device_session_kicked')),
                  duration: const Duration(seconds: 5),
                ),
              );
            });
          }
          return const WelcomeScreen();
        }

        final user = authProvider.user;
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context).translate('loading_app')),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      authProvider.logout();
                    },
                    child: Text(AppLocalizations.of(context).translate('back_to_login')),
                  ),
                ],
              ),
            ),
          );
        }

        final isServerApp = user.userType == UserType.admin;

        return isServerApp
            ? ServerApp(
                key: const ValueKey('server'),
                languageProvider: widget.languageProvider,
                onLogout: () => authProvider.logout(),
              )
            : ClientApp(
                key: const ValueKey('client'),
                languageProvider: widget.languageProvider,
                onLogout: () => authProvider.logout(),
              );
      },
    );
  }
}

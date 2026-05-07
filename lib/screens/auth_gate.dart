import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_models.dart';
import '../providers/auth_provider.dart';
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
              const Text('Loading...'),
            ],
          ),
        ),
      );
    }

    // Watch AuthProvider state
    final authProvider = context.watch<AuthProvider>();

    // Check if user is pending email verification
    if (authProvider.pendingVerificationEmail != null) {
      return EmailVerificationScreen(
        email: authProvider.pendingVerificationEmail!,
      );
    }

    // Show authentication screen if not authenticated
    if (!authProvider.isAuthenticated) {
      return const WelcomeScreen();
    }

    // Show main app (server or client based on user type)
    final user = authProvider.user;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Loading...'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  authProvider.logout();
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    // Determine which app to show based on user type
    final isServerApp = user.userType == UserType.admin;

    return isServerApp
        ? ServerApp(
            key: const ValueKey('server'),
            onSwitchApp: () {},
            languageProvider: widget.languageProvider,
            onLogout: () => authProvider.logout(),
          )
        : ClientApp(
            key: const ValueKey('client'),
            onSwitchApp: () {},
            languageProvider: widget.languageProvider,
            onLogout: () => authProvider.logout(),
          );
  }
}

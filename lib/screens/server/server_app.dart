import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_localization.dart';
import '../../localization/language_provider.dart';
import 'dashboard_screen.dart';
import 'camera_config_screen.dart';
import 'family_screen.dart';
import 'system_log_screen.dart';
import 'admin_profile_screen.dart';

class ServerApp extends StatefulWidget {
  final VoidCallback onSwitchApp;
  final LanguageProvider languageProvider;
  final VoidCallback? onLogout;

  const ServerApp({
    super.key,
    required this.onSwitchApp,
    required this.languageProvider,
    this.onLogout,
  });

  @override
  State<ServerApp> createState() => _ServerAppState();
}

class _ServerAppState extends State<ServerApp> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        onSwitchApp: widget.onSwitchApp,
        languageProvider: widget.languageProvider,
      ),
      const CameraConfigScreen(),
      const FamilyScreen(),
      const SystemLogScreen(),
      AdminProfileScreen(
        onSwitchApp: widget.onSwitchApp,
        languageProvider: widget.languageProvider,
        onLogout: widget.onLogout,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.languageProvider,
        builder: (context, _) {
          return IndexedStack(
            index: _currentIndex,
            children: _screens,
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black.withOpacity(0.08),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: AppTheme.primaryContainer,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard_rounded),
              label: AppLocalizations.of(context).navDashboard,
            ),
            NavigationDestination(
              icon: const Icon(Icons.videocam_outlined),
              selectedIcon: const Icon(Icons.videocam_rounded),
              label: AppLocalizations.of(context).navCamera,
            ),
            NavigationDestination(
              icon: const Icon(Icons.group_outlined),
              selectedIcon: const Icon(Icons.group_rounded),
              label: AppLocalizations.of(context).navFamily,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded),
              label: AppLocalizations.of(context).navLogs,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

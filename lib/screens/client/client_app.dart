import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_localization.dart';
import '../../localization/language_provider.dart';
import 'home_screen.dart';
import 'alerts_screen.dart';
import 'family_screen.dart';
import 'profile_screen.dart';

class ClientApp extends StatefulWidget {
  final VoidCallback onSwitchApp;
  final LanguageProvider languageProvider;
  final VoidCallback? onLogout;

  const ClientApp({
    super.key,
    required this.onSwitchApp,
    required this.languageProvider,
    this.onLogout,
  });

  @override
  State<ClientApp> createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onSwitchApp: widget.onSwitchApp),
      const AlertsScreen(),
      const ClientFamilyScreen(),
      ProfileScreen(
        onSwitchApp: widget.onSwitchApp,
        languageProvider: widget.languageProvider,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.languageProvider,
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
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
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: AppLocalizations.of(context).navHome,
                ),
                NavigationDestination(
                  icon: Badge(
                    label: const Text('3'),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  selectedIcon: Badge(
                    label: const Text('3'),
                    child: const Icon(Icons.notifications_rounded),
                  ),
                  label: AppLocalizations.of(context).navAlerts,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.group_outlined),
                  selectedIcon: const Icon(Icons.group_rounded),
                  label: AppLocalizations.of(context).navFamily,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: AppLocalizations.of(context).navProfile,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

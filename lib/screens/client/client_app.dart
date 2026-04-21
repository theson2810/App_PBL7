import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';

class ClientApp extends StatefulWidget {
  final VoidCallback onSwitchApp;

  const ClientApp({super.key, required this.onSwitchApp});

  @override
  State<ClientApp> createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp> {
  bool _isLoggedIn = false;
  int _currentIndex = 0;

  void _onLogin() => setState(() => _isLoggedIn = true);

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onSwitchApp: widget.onSwitchApp),
      const AlertsScreen(),
      ProfileScreen(onSwitchApp: widget.onSwitchApp),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return WelcomeScreen(onLogin: _onLogin);
    }

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
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
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
              label: 'Alerts',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

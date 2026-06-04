import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_localization.dart';
import '../../localization/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invite_link_provider.dart';
import '../../providers/wifi_join_link_provider.dart';
import '../../repositories/alert_repository.dart';
import '../../models/alert_model.dart' as firestore;
import 'home_screen.dart';
import 'alerts_screen.dart';
import 'family_screen.dart';
import 'profile_screen.dart';

class ClientApp extends StatefulWidget {
  final LanguageProvider languageProvider;
  final VoidCallback? onLogout;

  const ClientApp({
    super.key,
    required this.languageProvider,
    this.onLogout,
  });

  @override
  State<ClientApp> createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp> {
  int _currentIndex = 0;
  final _alertRepo = AlertRepository();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<InviteLinkProvider>().ensureRestored();
      await context.read<WifiJoinLinkProvider>().ensureRestored();
      if (!mounted) return;
      _openFamilyIfPendingJoin();
    });
    _screens = [
      const HomeScreen(),
      const AlertsScreen(),
      const ClientFamilyScreen(),
      ProfileScreen(
        languageProvider: widget.languageProvider,
        onLogout: widget.onLogout,
      ),
    ];
  }

  int _activeAlertCount(List<firestore.AlertModel> alerts) {
    return alerts.where((a) => a.status == 'active').length;
  }

  void _openFamilyIfPendingJoin() {
    if (!mounted) return;
    final hasInvite = context.read<InviteLinkProvider>().hasPendingInvite;
    final hasWifi = context.read<WifiJoinLinkProvider>().hasPendingWifiJoin;
    if (hasInvite || hasWifi) {
      setState(() => _currentIndex = 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyId = context.watch<AuthProvider>().user?.familyId;
    context.watch<InviteLinkProvider>();
    context.watch<WifiJoinLinkProvider>();

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
                  icon: _alertsNavIcon(familyId, false),
                  selectedIcon: _alertsNavIcon(familyId, true),
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

  Widget _alertsNavIcon(String? familyId, bool selected) {
    final base = Icon(
      selected ? Icons.notifications_rounded : Icons.notifications_outlined,
    );
    if (familyId == null || familyId.isEmpty) return base;

    return StreamBuilder<List<firestore.AlertModel>>(
      stream: _alertRepo.listenAlerts(familyId),
      builder: (context, snapshot) {
        final count = _activeAlertCount(snapshot.data ?? []);
        if (count <= 0) return base;
        return Badge(
          label: Text(count > 99 ? '99+' : '$count'),
          child: base,
        );
      },
    );
  }
}

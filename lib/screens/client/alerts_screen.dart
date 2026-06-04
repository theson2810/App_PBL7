import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../localization/app_localization.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/alert_repository.dart';
import '../../utils/alert_ui_mapper.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _alertRepo = AlertRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _resolveAlert(String alertId) async {
    await _alertRepo.resolveAlert(alertId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text(AppLocalizations.of(context).translate('alert_resolved')),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _resolveAllActive(List<AlertModel> active) async {
    for (final a in active) {
      await _alertRepo.resolveAlert(a.id);
    }
    if (!mounted) return;
    _markAllRead(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final familyId = context.watch<AuthProvider>().user?.familyId;

    if (familyId == null || familyId.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          backgroundColor: const Color(0xFFB71C1C),
          title: Text(loc.alertsTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              loc.translate('join_family_for_alerts'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return StreamBuilder(
      stream: _alertRepo.listenAlerts(familyId),
      builder: (context, snapshot) {
        final allUi = toUiAlerts(snapshot.data ?? []);
        final fireActive = snapshot.data?.where((a) => a.status == 'active').toList() ?? [];
        final fireResolved = snapshot.data?.where((a) => a.status == 'resolved').toList() ?? [];
        final activeUi = toUiAlerts(fireActive);
        final historyUi = toUiAlerts(fireResolved);

        final emergency = activeUi
            .where((a) =>
                a.severity == AlertSeverity.emergency ||
                a.severity == AlertSeverity.high)
            .toList();

        return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).alertsTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              loc.translate('alerts_subtitle'),
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.mark_chat_read_outlined, color: Colors.white),
            onPressed: activeUi.isEmpty
                ? null
                : () => _resolveAllActive(activeUi),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(loc.translate('tab_all')),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${allUi.length}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            Tab(text: loc.translate('tab_emergency')),
            Tab(text: loc.translate('tab_history')),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _AlertListView(
                  alerts: activeUi,
                  history: historyUi,
                  onResolve: _resolveAlert,
                ),
                _AlertListView(
                  alerts: emergency,
                  history: [],
                  onResolve: _resolveAlert,
                ),
                _AlertListView(
                  alerts: [],
                  history: historyUi,
                  historyTitle: loc.translate('tab_history'),
                  onResolve: _resolveAlert,
                ),
              ],
            ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }

  void _markAllRead(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('mark_all_resolved')),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _AlertListView extends StatelessWidget {
  final List<AlertModel> alerts;
  final List<AlertModel> history;
  final String historyTitle;
  final Future<void> Function(String alertId)? onResolve;

  const _AlertListView({
    required this.alerts,
    required this.history,
    this.historyTitle = 'Earlier History',
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty && history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 56,
              color: AppTheme.primaryLight.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).translate('no_alerts_category'),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).translate('all_safe'),
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        if (alerts.isNotEmpty) ...[
          // Emergency alert highlight
          if (alerts.any(
              (a) => a.severity == AlertSeverity.emergency)) ...[
            _EmergencyBanner(
              alert: alerts.firstWhere(
                (a) => a.severity == AlertSeverity.emergency,
              ),
            ),
            const SizedBox(height: 4),
          ],
          ...alerts.map((a) => AlertCard(
                alert: a,
                onViewRecording: () {},
                onDismiss: onResolve != null ? () => onResolve!(a.id) : null,
              )),
        ],
        if (history.isNotEmpty) ...[
          const SizedBox(height: 8),
          SectionHeader(title: historyTitle),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 52),
              itemBuilder: (_, i) => _HistoryTile(alert: history[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmergencyBanner extends StatelessWidget {
  final AlertModel alert;

  const _EmergencyBanner({required this.alert});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('emergency_alert'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.errorColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7F0000),
                  ),
                ),
                Text(
                  '${alert.location} · ${timeAgo(alert.time)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB71C1C),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: Text(loc.translate('respond')),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final AlertModel alert;

  const _HistoryTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: alert.severityBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(alert.typeIcon, size: 18, color: alert.severityColor),
      ),
      title: Text(
        alert.title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        formatTime(alert.time),
        style: const TextStyle(fontSize: 11),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.textTertiary,
        size: 18,
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _selectedSeverity;
  String? _selectedPeriod;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    _selectedSeverity ??= loc.translate('severity_all');
    _selectedPeriod ??= loc.translate('period_today');
    final severities = [
      loc.translate('severity_all'),
      loc.translate('severity_emergency'),
      loc.translate('severity_high'),
      loc.translate('severity_medium'),
      loc.translate('severity_notice'),
    ];
    final periods = [
      loc.translate('period_today'),
      loc.translate('period_week'),
      loc.translate('period_month'),
      loc.translate('period_all'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text(
            loc.translate('filter_alerts'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text(
            loc.translate('severity'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: severities
                .map((s) => ChoiceChip(
                      label: Text(s),
                      selected: _selectedSeverity == s,
                      onSelected: (_) => setState(() => _selectedSeverity = s),
                      selectedColor: AppTheme.primaryContainer,
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            loc.translate('time_period'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: periods
                .map((p) => ChoiceChip(
                      label: Text(p),
                      selected: _selectedPeriod == p,
                      onSelected: (_) => setState(() => _selectedPeriod = p),
                      selectedColor: AppTheme.primaryContainer,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.translate('reset')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.translate('apply_filter')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AlertSeverity? _filterSeverity;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security & Vital Alerts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Recent detections — Safety is our priority',
              style: TextStyle(color: Colors.white70, fontSize: 11),
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
            onPressed: () => _markAllRead(context),
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
                  const Text('All'),
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
                      '${mockAlerts.length}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            const Tab(text: 'Emergency'),
            const Tab(text: 'History'),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AlertListView(
            alerts: mockAlerts,
            history: mockHistory,
          ),
          _AlertListView(
            alerts: mockAlerts
                .where((a) =>
                    a.severity == AlertSeverity.emergency ||
                    a.severity == AlertSeverity.high)
                .toList(),
            history: [],
          ),
          _AlertListView(
            alerts: [],
            history: mockHistory,
            historyTitle: 'All History',
          ),
        ],
      ),
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
        content: const Text('All alerts marked as read'),
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

  const _AlertListView({
    required this.alerts,
    required this.history,
    this.historyTitle = 'Earlier History',
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
            const Text(
              'No alerts in this category',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Everything looks safe',
              style: TextStyle(
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
                const Text(
                  'EMERGENCY ALERT',
                  style: TextStyle(
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
            child: const Text('Respond'),
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
  String _selectedSeverity = 'All';
  String _selectedPeriod = 'Today';

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Filter Alerts',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          const Text(
            'Severity',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['All', 'Emergency', 'High', 'Medium', 'Notice']
                .map((s) => ChoiceChip(
                      label: Text(s),
                      selected: _selectedSeverity == s,
                      onSelected: (_) => setState(() => _selectedSeverity = s),
                      selectedColor: AppTheme.primaryContainer,
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Time Period',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Today', 'This Week', 'This Month', 'All Time']
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
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filter'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

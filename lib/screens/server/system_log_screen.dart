import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localization.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/alert_repository.dart';
import '../../utils/log_mapper.dart';

class SystemLogScreen extends StatefulWidget {
  const SystemLogScreen({super.key});

  @override
  State<SystemLogScreen> createState() => _SystemLogScreenState();
}

class _SystemLogScreenState extends State<SystemLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _autoScroll = true;

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

  List<LogEntry> _filteredLogs(List<LogEntry> logs, int tab) {
    switch (tab) {
      case 1:
        return logs.where((l) => l.level == LogLevel.error).toList();
      case 2:
        return logs.where((l) => l.level == LogLevel.warning).toList();
      default:
        return logs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final familyId = context.watch<AuthProvider>().user?.familyId;

    if (familyId == null || familyId.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryDark,
          title: Text(loc.translate('operational_logs')),
        ),
        body: Center(child: Text(loc.translate('no_family_selected'))),
      );
    }

    return StreamBuilder(
      stream: AlertRepository().listenAlerts(familyId),
      builder: (context, snapshot) {
        final logs = alertsToLogs(snapshot.data ?? []);

        return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('operational_logs'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              loc.translate('system_event_stream'),
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _autoScroll
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _autoScroll = !_autoScroll),
            tooltip: _autoScroll
                ? loc.translate('pause_stream')
                : loc.translate('resume_stream'),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () {},
            tooltip: loc.translate('export_logs_tooltip'),
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
            Tab(text: loc.translate('tab_all_activities')),
            Tab(text: loc.translate('tab_errors')),
            Tab(text: loc.translate('tab_warnings')),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: Column(
        children: [
          // Server status banner
          _ServerStatusBanner(),
          const SizedBox(height: 1),

          // Log list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                3,
                (i) => _LogListView(logs: _filteredLogs(logs, i)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {},
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.filter_list_rounded, color: Colors.white),
      ),
        );
      },
    );
  }
}

class _ServerStatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppTheme.surface2,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryLight,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('event_stream_title'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark,
                  ),
                ),
                Text(
                  loc.translate('event_stream_subtitle'),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '14d 02h',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryDark,
                ),
              ),
              Text(
                loc.translate('uptime_label'),
                style: const TextStyle(fontSize: 9, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '14ms',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryDark,
                ),
              ),
              Text(
                loc.translate('latency_label'),
                style: const TextStyle(fontSize: 9, color: AppTheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogListView extends StatelessWidget {
  final List<LogEntry> logs;

  const _LogListView({required this.logs});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 48, color: AppTheme.primaryLight),
            const SizedBox(height: 12),
            Text(
              loc.translate('no_events_category'),
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: logs.length + 1,
      itemBuilder: (context, i) {
        if (i == logs.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.history_rounded, size: 16),
                label: Text(loc.translate('load_historical')),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
              ),
            ),
          );
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: LogItemWidget(entry: logs[i]),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

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

  List<LogEntry> _filteredLogs(int tab) {
    switch (tab) {
      case 1:
        return mockLogs.where((l) => l.level == LogLevel.error).toList();
      case 2:
        return mockLogs.where((l) => l.level == LogLevel.warning).toList();
      default:
        return mockLogs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operational Logs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'System Event Stream',
              style: TextStyle(color: Colors.white70, fontSize: 11),
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
            tooltip: _autoScroll ? 'Pause stream' : 'Resume stream',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () {},
            tooltip: 'Export logs',
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
          tabs: const [
            Tab(text: 'All Activities'),
            Tab(text: 'Errors'),
            Tab(text: 'Warnings'),
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
                (i) => _LogListView(logs: _filteredLogs(i)),
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
  }
}

class _ServerStatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sentinel AI v4.2.1 active & processing telemetry',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark,
                  ),
                ),
                Text(
                  'Real-time analysis active across all nodes',
                  style: TextStyle(
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
            children: const [
              Text(
                '14d 02h',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryDark,
                ),
              ),
              Text(
                'Uptime',
                style: TextStyle(fontSize: 9, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                '14ms',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryDark,
                ),
              ),
              Text(
                'Latency',
                style: TextStyle(fontSize: 9, color: AppTheme.primary),
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
    if (logs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 48, color: AppTheme.primaryLight),
            SizedBox(height: 12),
            Text(
              'No events in this category',
              style: TextStyle(color: AppTheme.textSecondary),
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
                label: const Text('Load Historical Records'),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../localization/app_localization.dart';
import '../../localization/language_provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/alert_repository.dart';
import '../../repositories/camera_repository.dart';
import '../../repositories/family_repository.dart';
import '../../utils/log_mapper.dart';

class DashboardScreen extends StatefulWidget {
  final LanguageProvider languageProvider;

  const DashboardScreen({
    super.key,
    required this.languageProvider,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.languageProvider,
      builder: (context, _) {
        final loc = AppLocalizations.of(context);
        return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.appNameServer,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              loc.translate('system_overview'),
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: const [],
      ),
      body: _DashboardBody(pulseAnim: _pulseController),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final Animation<double> pulseAnim;

  const _DashboardBody({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final familyId = context.watch<AuthProvider>().user?.familyId;
    if (familyId == null || familyId.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(loc.translate('dashboard_no_family')),
        ),
      );
    }

    final alertRepo = AlertRepository();
    final cameraRepo = CameraRepository();
    final familyRepo = FamilyRepository();

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async {
        await context.read<AuthProvider>().authService.refreshCurrentUserProfile();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SystemStatusBanner(pulseAnim: pulseAnim),
            const SizedBox(height: 14),
            StreamBuilder(
              stream: cameraRepo.getCameras(familyId),
              builder: (context, camSnap) {
                final cameras = camSnap.data ?? [];
                final online = cameras.where((c) => c.status == 'online').length;
                return StreamBuilder(
                  stream: alertRepo.listenAlerts(familyId),
                  builder: (context, alertSnap) {
                    final alerts = alertSnap.data ?? [];
                    final activeAlerts =
                        alerts.where((a) => a.status == 'active').length;
                    return StreamBuilder(
                      stream: familyRepo.getMembers(familyId),
                      builder: (context, memberSnap) {
                        final members = memberSnap.data?.length ?? 0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    value: '${cameras.length}',
                                    label: loc.translate('stat_cameras'),
                                    icon: Icons.videocam_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: StatCard(
                                    value: '$online',
                                    label: loc.translate('stat_online'),
                                    icon: Icons.wifi_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    value: '$activeAlerts',
                                    label: loc.translate('stat_active_alerts'),
                                    icon: Icons.warning_amber_rounded,
                                    iconColor: AppTheme.errorColor,
                                    bgColor: const Color(0xFFFFEBEE),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: StatCard(
                                    value: '$members',
                                    label: loc.translate('stat_family_members'),
                                    icon: Icons.group_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SectionHeader(title: loc.translate('recent_alerts')),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                child: alerts.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(loc.translate('no_alerts_yet')),
                                      )
                                    : Column(
                                        children: alertsToLogs(alerts.take(5).toList())
                                            .map(
                                              (e) => Column(
                                                children: [
                                                  LogItemWidget(entry: e),
                                                  if (e != alertsToLogs(alerts.take(5).toList()).last)
                                                    const Divider(height: 1),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SystemStatusBanner extends StatelessWidget {
  final Animation<double> pulseAnim;

  const _SystemStatusBanner({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          FadeTransition(
            opacity: pulseAnim,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryLight.withOpacity(0.2),
                border: Border.all(color: AppTheme.primaryLight, width: 1.5),
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('system_online'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF69F0AE),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      loc.translate('uptime_sample'),
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.primaryLight.withOpacity(0.4)),
                ),
                child: Text(
                  loc.translate('status_active'),
                  style: const TextStyle(
                    color: Color(0xFF69F0AE),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.translate('monitoring_label'),
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetworkTelemetryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Real-time bandwidth',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                StatusBadge.green('STABLE'),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0.68,
                minHeight: 8,
                backgroundColor: AppTheme.primaryContainer,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 MB/s', style: TextStyle(fontSize: 10, color: AppTheme.textTertiary)),
                Text(
                  '18.4 MB/s',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                Text('30 MB/s', style: TextStyle(fontSize: 10, color: AppTheme.textTertiary)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TelemetryPill(label: 'Ping', value: '14ms', ok: true),
                const SizedBox(width: 8),
                _TelemetryPill(label: 'Packet Loss', value: '0.02%', ok: true),
                const SizedBox(width: 8),
                _TelemetryPill(label: 'Streams', value: '3', ok: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TelemetryPill extends StatelessWidget {
  final String label;
  final String value;
  final bool ok;

  const _TelemetryPill({
    required this.label,
    required this.value,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryContainer),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 9.5, color: AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiDetectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const modules = [
      ('Gait Analysis', Icons.directions_walk_rounded, true),
      ('Fall Detection', Icons.person_off_rounded, true),
      ('Vital Recognition', Icons.favorite_rounded, true),
      ('Boundary Watch', Icons.fence_rounded, true),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Modules',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                StatusBadge.green('4/4 ENABLED'),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: modules
                  .map(
                    (m) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surface2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryContainer),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(m.$2, size: 13, color: AppTheme.primary),
                          const SizedBox(width: 5),
                          Text(
                            m.$1,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onSwitchApp;

  const DashboardScreen({super.key, required this.onSwitchApp});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
              'Clinical Sentinel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'System Overview',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: widget.onSwitchApp,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Client',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System status banner
              _SystemStatusBanner(pulseAnim: _pulseAnim),
              const SizedBox(height: 14),

              // Stat grid
              Row(
                children: const [
                  Expanded(
                    child: StatCard(
                      value: '3',
                      label: 'Cameras Active',
                      icon: Icons.videocam_rounded,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      value: 'ON',
                      label: 'AI Processing',
                      icon: Icons.smart_toy_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Expanded(
                    child: StatCard(
                      value: '18.4',
                      label: 'MB/s Bandwidth',
                      icon: Icons.network_check_rounded,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      value: '84%',
                      label: 'Storage Used',
                      icon: Icons.storage_rounded,
                      iconColor: Color(0xFFF57F17),
                      bgColor: Color(0xFFFFF8E1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Network Telemetry
              const SectionHeader(title: 'Network Telemetry'),
              _NetworkTelemetryCard(),
              const SizedBox(height: 6),

              // AI Detection
              const SectionHeader(title: 'AI Detection Modules'),
              _AiDetectionCard(),
              const SizedBox(height: 6),

              // Recent Logs
              const SectionHeader(title: 'Recent Logs'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  child: Column(
                    children: mockLogs
                        .take(4)
                        .map(
                          (e) => Column(
                            children: [
                              LogItemWidget(entry: e),
                              if (e != mockLogs.take(4).last)
                                const Divider(height: 1),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
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
                const Text(
                  'System Online',
                  style: TextStyle(
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
                    const Text(
                      'Uptime: 14d 02h 45m',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
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
                child: const Text(
                  '● ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF69F0AE),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'AI v4.2.1',
                style: TextStyle(color: Colors.white54, fontSize: 10),
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

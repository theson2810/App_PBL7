import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class CameraConfigScreen extends StatelessWidget {
  const CameraConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: SubtitleAppBar(
        title: 'Camera Configuration',
        subtitle: 'Define AI monitoring zones for patient safety',
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add camera button
            ElevatedButton.icon(
              onPressed: () => _showAddCameraSheet(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add New Camera'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Total Cameras',
                    value: '${mockCameras.length}',
                    icon: Icons.videocam_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    label: 'Online',
                    value: '${mockCameras.where((c) => c.status == CameraStatus.live).length}',
                    icon: Icons.wifi_rounded,
                    valueColor: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    label: 'Offline',
                    value: '${mockCameras.where((c) => c.status == CameraStatus.offline).length}',
                    icon: Icons.wifi_off_rounded,
                    valueColor: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Camera list
            const SectionHeader(title: 'Configured Cameras'),
            ...mockCameras.map((cam) => _CameraConfigCard(camera: cam)),
            const SizedBox(height: 16),

            // AI Insights
            const SectionHeader(title: 'AI Insights'),
            _AiInsightsCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showAddCameraSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const _AddCameraSheet(),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryContainer),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: valueColor ?? AppTheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppTheme.primaryDark,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, color: AppTheme.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CameraConfigCard extends StatelessWidget {
  final CameraModel camera;

  const _CameraConfigCard({required this.camera});

  @override
  Widget build(BuildContext context) {
    final isLive = camera.status == CameraStatus.live;
    final isOffline = camera.status == CameraStatus.offline;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isOffline ? const Color(0xFF1A0A0A) : const Color(0xFF1A2A1A),
        borderRadius: BorderRadius.circular(14),
        border: isOffline
            ? Border.all(color: AppTheme.errorColor.withOpacity(0.4))
            : Border.all(color: AppTheme.primaryLight.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          // Preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            child: Container(
              height: 90,
              width: double.infinity,
              color: isOffline
                  ? const Color(0xFF0D0505)
                  : const Color(0xFF0A1A0A),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_rounded,
                          size: 32,
                          color: isOffline
                              ? AppTheme.errorColor.withOpacity(0.4)
                              : AppTheme.primaryLight.withOpacity(0.25),
                        ),
                        if (!isOffline) ...[
                          const SizedBox(height: 6),
                          Text(
                            camera.resolution,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryLight.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isLive
                            ? AppTheme.errorColor
                            : const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isLive ? 'LIVE' : 'OFFLINE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  if (camera.aiEnabled)
                    Positioned(
                      top: 8,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.smart_toy_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'AI ON',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Meta
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        camera.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE8F5E9),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLive
                                  ? AppTheme.primaryLight
                                  : AppTheme.errorColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            camera.location,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF81C784),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isOffline)
                  _DarkButton(
                    label: 'Reconnect',
                    icon: Icons.refresh_rounded,
                    color: AppTheme.errorColor,
                    onTap: () {},
                  )
                else
                  _DarkButton(
                    label: 'AI Zone',
                    icon: Icons.settings_suggest_rounded,
                    color: AppTheme.primaryLight,
                    onTap: () => _showAiZoneSheet(context, camera),
                  ),
              ],
            ),
          ),
          if (isLive)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: _CpuLoadBar(load: camera.cpuLoad),
            ),
        ],
      ),
    );
  }

  void _showAiZoneSheet(BuildContext context, CameraModel cam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AiZoneSheet(camera: cam),
    );
  }
}

class _DarkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DarkButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CpuLoadBar extends StatelessWidget {
  final double load;

  const _CpuLoadBar({required this.load});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'CPU',
          style: TextStyle(fontSize: 9, color: Color(0xFF81C784)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: load,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                load > 0.7 ? AppTheme.warningColor : AppTheme.primaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${(load * 100).round()}%',
          style: const TextStyle(fontSize: 9, color: Color(0xFF81C784)),
        ),
      ],
    );
  }
}

class _AiInsightsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryContainer, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy_rounded, size: 18, color: AppTheme.primary),
              SizedBox(width: 6),
              Text(
                'AI Insights',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Update exclusion zones in Ward A to reduce false positives during shift rotations. 3 recommended zone adjustments detected.',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InsightMetric(
                  label: 'Alerts Today',
                  value: '24',
                  icon: Icons.notifications_active_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InsightMetric(
                  label: 'System Uptime',
                  value: '99.8%',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InsightMetric(
                  label: 'Accuracy',
                  value: '97.3%',
                  icon: Icons.track_changes_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InsightMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryContainer),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppTheme.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AiZoneSheet extends StatelessWidget {
  final CameraModel camera;

  const _AiZoneSheet({required this.camera});

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
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'AI Zone — ${camera.name}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Configure detection zones and sensitivity thresholds.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          // Zone preview placeholder
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0A1A0A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.crop_square_rounded, color: Color(0xFF4CAF50), size: 36),
                  SizedBox(height: 6),
                  Text(
                    'Tap to draw AI detection zone',
                    style: TextStyle(color: Color(0xFF81C784), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Detection Sensitivity',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Slider(
            value: 0.75,
            onChanged: (_) {},
            activeColor: AppTheme.primary,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Save Zone'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddCameraSheet extends StatelessWidget {
  const _AddCameraSheet();

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
            'Add New Camera',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Camera Name',
              prefixIcon: Icon(Icons.videocam_outlined),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'IP Address / RTSP URL',
              prefixIcon: Icon(Icons.link_rounded),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Location / Zone',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Camera'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }
}

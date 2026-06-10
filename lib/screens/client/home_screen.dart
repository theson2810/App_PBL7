import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../localization/app_localization.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/alert_repository.dart';
import '../../repositories/camera_repository.dart';
import '../../utils/alert_ui_mapper.dart';
import '../../utils/camera_ui_mapper.dart';
import 'live_view_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final familyId = user?.familyId;
    final alertRepo = AlertRepository();
    final cameraRepo = CameraRepository();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vital Horizon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              AppLocalizations.of(context).appNameClient,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  user.fullName,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: familyId == null || familyId.isEmpty
          ? _NoFamilyBody(
              userName: user?.fullName,
              message: AppLocalizations.of(context).translate('join_family_hint'),
              onRefresh: () async {
                await context.read<AuthProvider>().refreshUserProfile();
              },
            )
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () async {
                await context.read<AuthProvider>().refreshUserProfile();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showQrScanner(context),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                      label: Text(AppLocalizations.of(context).translate('scan_chip_qr')),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder(
                      stream: cameraRepo.getCameras(familyId),
                      builder: (context, camSnap) {
                        final cameras = toUiCameras(camSnap.data ?? []);
                        final online = cameras
                            .where((c) => c.status == CameraStatus.live)
                            .length;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: AppLocalizations.of(context).translate('registered_cameras'),
                              trailing: StatusBadge.green(
                                '$online ${AppLocalizations.of(context).translate('online_count')}',
                              ),
                            ),
                            if (camSnap.connectionState == ConnectionState.waiting)
                              const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (cameras.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  AppLocalizations.of(context).translate('no_cameras_admin_hint'),
                                  style: const TextStyle(color: AppTheme.textSecondary),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.1,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: cameras.length,
                                itemBuilder: (context, i) {
                                  final cam = cameras[i];
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LiveViewScreen(camera: cam),
                                      ),
                                    ),
                                    child: CameraThumbCard(camera: cam, darkMode: true),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder(
                      stream: alertRepo.listenAlerts(familyId),
                      builder: (context, alertSnap) {
                        final uiAlerts = toUiAlerts(alertSnap.data ?? []);
                        final recent = uiAlerts.take(3).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: AppLocalizations.of(context).translate('recent_alerts'),
                            ),
                            if (recent.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  AppLocalizations.of(context).translate('no_alerts_yet'),
                                  style: const TextStyle(color: AppTheme.textSecondary),
                                ),
                              )
                            else
                              ...recent.map((a) => _AlertPreviewTile(alert: a)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  void _showQrScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1A0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Scan QR Code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Point camera at the QR code on the server device',
              style: TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryLight, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 60,
                  color: AppTheme.primaryLight,
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryLight,
                side: const BorderSide(color: AppTheme.primaryLight),
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoFamilyBody extends StatelessWidget {
  final String? userName;
  final String message;
  final Future<void> Function() onRefresh;

  const _NoFamilyBody({
    this.userName,
    required this.message,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_off_outlined, size: 56, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Hello${userName != null ? ', $userName' : ''}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(180, 42),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCameraPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryLight.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: 30,
                color: AppTheme.primaryLight,
              ),
              SizedBox(height: 6),
              Text(
                'Add Camera',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertPreviewTile extends StatelessWidget {
  final AlertModel alert;

  const _AlertPreviewTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: alert.severity == AlertSeverity.emergency
              ? AppTheme.errorColor.withOpacity(0.25)
              : Colors.black.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: alert.severityBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(alert.typeIcon, size: 16, color: alert.severityColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: alert.severityColor,
                  ),
                ),
                Text(
                  '${alert.location} · ${timeAgo(alert.time)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: alert.severityLabel,
            color: alert.severityColor,
            bgColor: alert.severityBg,
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textTertiary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

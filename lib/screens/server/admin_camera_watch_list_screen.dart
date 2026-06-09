import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localization.dart';
import '../../models/camera_model.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/camera_repository.dart';
import '../../config/relay_config.dart';
import '../../services/relay/relay_api_client.dart';
import '../../services/relay/relay_token_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'admin_camera_live_screen.dart';

/// Tab "Xem trực tiếp" — danh sách Firestore + trạng thái online từ VPS `GET /cameras`.
class AdminCameraWatchListScreen extends StatefulWidget {
  const AdminCameraWatchListScreen({super.key});

  @override
  State<AdminCameraWatchListScreen> createState() =>
      _AdminCameraWatchListScreenState();
}

class _AdminCameraWatchListScreenState extends State<AdminCameraWatchListScreen> {
  Set<String> _onlineOnRelay = {};
  String? _relayError;
  bool _loadingRelay = true;

  @override
  void initState() {
    super.initState();
    _refreshRelayStatus();
  }

  String _relayErrorText(AppLocalizations loc, Object error) {
    final raw = error.toString();
    if (raw.contains('relay_not_configured')) {
      return loc.translate('relay_not_configured');
    }
    if (raw.contains('relay_token_not_configured')) {
      return loc.translate('relay_token_not_configured');
    }
    if (raw.contains('relay_auth_failed')) {
      return loc.translate('relay_auth_failed');
    }
    return raw;
  }

  Future<void> _refreshRelayStatus() async {
    setState(() {
      _loadingRelay = true;
      _relayError = null;
    });
    try {
      RelayConfig.reset();
      await RelayConfig.loadFromFirestore();
      final token = await RelayTokenService.instance.fetchWatchToken('_list');
      final online = await RelayApiClient.instance.getOnlineCameras(token);
      if (!mounted) return;
      setState(() {
        _onlineOnRelay = online.toSet();
        _loadingRelay = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _relayError = e.toString();
        _loadingRelay = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final familyId = context.watch<AuthProvider>().user?.familyId;

    if (familyId == null || familyId.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(loc.translate('create_family_before_camera')),
        ),
      );
    }

    final cameraRepo = CameraRepository();

    return Column(
      children: [
        if (_relayError != null)
          MaterialBanner(
            content: Text(_relayErrorText(loc, _relayError!)),
            actions: [
              TextButton(
                onPressed: _refreshRelayStatus,
                child: Text(loc.translate('relay_watch_retry')),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  loc.translate('relay_online_hint'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              IconButton(
                icon: _loadingRelay
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                onPressed: _loadingRelay ? null : _refreshRelayStatus,
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<CameraModel>>(
            stream: cameraRepo.getCameras(familyId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final cameras = snapshot.data ?? [];
              if (cameras.isEmpty) {
                return Center(
                  child: Text(
                    loc.translate('no_cameras_chip_hint'),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshRelayStatus,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cameras.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final cam = cameras[index];
                    final onRelay = _onlineOnRelay.contains(cam.relayCameraId);

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.videocam_rounded,
                          color: onRelay ? AppTheme.primary : Colors.grey,
                        ),
                        title: Text(cam.name),
                        subtitle: Text(
                          '${loc.translate('relay_camera_id')}: ${cam.relayCameraId}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                        ),
                        trailing: onRelay
                            ? StatusBadge.green(loc.translate('relay_on_vps'))
                            : StatusBadge.orange(loc.translate('relay_off_vps')),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminCameraLiveScreen(camera: cam),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../localization/app_localization.dart';
import '../../models/camera_model.dart';
import '../../services/relay/relay_watch_service.dart';
import '../../theme/app_theme.dart';

/// Màn xem live WebRTC qua relay VPS cho admin.
///
/// Luồng:
/// token → offer → POST /watch/{relayCameraId} → answer → RTCVideoView
class AdminCameraLiveScreen extends StatefulWidget {
  final CameraModel camera;

  const AdminCameraLiveScreen({super.key, required this.camera});

  @override
  State<AdminCameraLiveScreen> createState() => _AdminCameraLiveScreenState();
}

class _AdminCameraLiveScreenState extends State<AdminCameraLiveScreen>
    with WidgetsBindingObserver {
  final _watchService = RelayWatchService();
  final _renderer = RTCVideoRenderer();

  RelayWatchState _state = RelayWatchState.idle;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    if (_state != RelayWatchState.connected || _renderer.srcObject == null) {
      _retry();
    }
  }

  Future<void> _bootstrap() async {
    await _renderer.initialize();
    _renderer.srcObject = null;

    _watchService.onStateChanged = (state, error) {
      if (!mounted) return;
      setState(() {
        _state = state;
        _errorCode = error;
      });
    };

    await _startWatch();
  }

  Future<void> _startWatch() async {
    await _watchService.watch(
      relayCameraId: widget.camera.relayCameraId,
      renderer: _renderer,
    );
  }

  Future<void> _retry() async {
    await _watchService.reconnect(
      relayCameraId: widget.camera.relayCameraId,
      renderer: _renderer,
    );
  }

  String _errorText(AppLocalizations loc) {
    final code = _errorCode;
    if (code == null) return '';
    switch (code) {
      case 'relay_not_configured':
        return loc.translate('relay_not_configured');
      case 'relay_token_not_configured':
        return loc.translate('relay_token_not_configured');
      case 'camera_not_online':
        return loc.translate('camera_not_online');
      case 'relay_auth_failed':
        return loc.translate('relay_auth_failed');
      default:
        return code;
    }
  }

  String _statusText(AppLocalizations loc) {
    switch (_state) {
      case RelayWatchState.loading:
        return loc.translate('relay_watch_loading');
      case RelayWatchState.connected:
        return loc.translate('relay_watch_connected');
      case RelayWatchState.reconnecting:
        return loc.translate('relay_watch_reconnecting');
      case RelayWatchState.failed:
        return loc.translate('relay_watch_failed');
      case RelayWatchState.disconnected:
        return loc.translate('relay_watch_disconnected');
      case RelayWatchState.idle:
        return loc.translate('relay_watch_idle');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _watchService.dispose();
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isLive = _state == RelayWatchState.connected;
    final isBusy = _state == RelayWatchState.loading ||
        _state == RelayWatchState.reconnecting;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF202642),
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.camera.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF202642),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: isBusy ? null : _retry,
            tooltip: loc.translate('relay_watch_retry'),
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _AdminVideoPane(
              isLive: isLive,
              isBusy: isBusy,
              statusText: _statusText(loc),
              errorText: _errorText(loc),
              renderer: _renderer,
              onRetry: _retry,
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _AdminAction(icon: Icons.remove_red_eye_outlined),
                _AdminAction(icon: Icons.photo_camera_outlined),
                _AdminAction(icon: Icons.videocam_outlined),
                _AdminAction(icon: Icons.volume_off_outlined),
                _AdminAction(icon: Icons.open_in_full_rounded),
              ],
            ),
          ),
          Expanded(child: _PtzPlaceholder(statusText: _statusText(loc))),
        ],
      ),
    );
  }
}

class _AdminVideoPane extends StatelessWidget {
  final bool isLive;
  final bool isBusy;
  final String statusText;
  final String errorText;
  final RTCVideoRenderer renderer;
  final VoidCallback onRetry;

  const _AdminVideoPane({
    required this.isLive,
    required this.isBusy,
    required this.statusText,
    required this.errorText,
    required this.renderer,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isLive)
            RTCVideoView(
              renderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
            )
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBusy)
                    const CircularProgressIndicator(color: AppTheme.primaryLight)
                  else
                    const Icon(
                      Icons.videocam_off_outlined,
                      color: Colors.white54,
                      size: 42,
                    ),
                  const SizedBox(height: 12),
                  Text(
                    errorText.isNotEmpty ? errorText : statusText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (!isBusy) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          Positioned(
            top: 10,
            left: 12,
            child: Text(
              _clockText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
          if (isLive)
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'HD',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _clockText() {
    final now = DateTime.now();
    return '${now.year}/${now.month.toString().padLeft(2, '0')}/'
        '${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }
}

class _AdminAction extends StatelessWidget {
  final IconData icon;

  const _AdminAction({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: const Color(0xFF3D4568), size: 30);
  }
}

class _PtzPlaceholder extends StatelessWidget {
  final String statusText;

  const _PtzPlaceholder({required this.statusText});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F7FB),
      child: Center(
        child: Container(
          width: 230,
          height: 230,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: const [
              Icon(Icons.keyboard_arrow_up_rounded,
                  size: 42, color: Color(0xFF6C7498)),
              Positioned(
                bottom: 18,
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 42, color: Color(0xFF6C7498)),
              ),
              Positioned(
                left: 18,
                child: Icon(Icons.keyboard_arrow_left_rounded,
                    size: 42, color: Color(0xFF6C7498)),
              ),
              Positioned(
                right: 18,
                child: Icon(Icons.keyboard_arrow_right_rounded,
                    size: 42, color: Color(0xFF6C7498)),
              ),
              CircleAvatar(radius: 38, backgroundColor: Color(0xFFF9F9FC)),
            ],
          ),
        ),
      ),
    );
  }
}

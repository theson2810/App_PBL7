import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class LiveViewScreen extends StatefulWidget {
  final CameraModel camera;

  const LiveViewScreen({super.key, required this.camera});

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen>
    with SingleTickerProviderStateMixin {
  bool _isMuted = false;
  bool _isTalking = false;
  bool _isRecording = false;
  bool _isFullscreen = false;
  late AnimationController _recordingAnim;

  @override
  void initState() {
    super.initState();
    _recordingAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _recordingAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      appBar: _isFullscreen
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0D1B0D),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.camera.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'HD · Live',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
      body: Column(
        children: [
          // Live stream area
          _LiveStreamArea(
            camera: widget.camera,
            isFullscreen: _isFullscreen,
            isRecording: _isRecording,
            recordingAnim: _recordingAnim,
            onToggleFullscreen: () {
              setState(() => _isFullscreen = !_isFullscreen);
              if (_isFullscreen) {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
              } else {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              }
            },
          ),

          // Controls bar
          Container(
            color: const Color(0xFF1A2A1A),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ControlButton(
                  icon: _isMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  label: _isMuted ? 'Unmute' : 'Audio',
                  isActive: !_isMuted,
                  onTap: () => setState(() => _isMuted = !_isMuted),
                ),
                _ControlButton(
                  icon: _isTalking
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
                  label: _isTalking ? 'Talking...' : 'Talk',
                  isActive: _isTalking,
                  activeColor: AppTheme.warningColor,
                  onTap: () => setState(() => _isTalking = !_isTalking),
                ),
                _ControlButton(
                  icon: Icons.photo_camera_rounded,
                  label: 'Snapshot',
                  onTap: () => _takeSnapshot(context),
                ),
                _ControlButton(
                  icon: Icons.fiber_manual_record_rounded,
                  label: _isRecording ? 'Stop' : 'Record',
                  isActive: _isRecording,
                  activeColor: AppTheme.errorColor,
                  onTap: () => setState(() => _isRecording = !_isRecording),
                ),
                _ControlButton(
                  icon: Icons.switch_camera_rounded,
                  label: 'Switch',
                  onTap: () {},
                ),
              ],
            ),
          ),

          if (!_isFullscreen)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2-way audio status
                    if (_isTalking)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.warningColor.withOpacity(0.4),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.mic_rounded,
                              color: AppTheme.warningColor,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '2-way audio active — speak now',
                              style: TextStyle(
                                color: AppTheme.warningColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Recent activity
                    SectionHeader(
                      title: 'Recent Activity',
                      trailing: TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ),
                    ...mockAlerts
                        .take(3)
                        .map((a) => AlertCard(alert: a))
                        .toList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _takeSnapshot(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Snapshot saved to gallery'),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _LiveStreamArea extends StatelessWidget {
  final CameraModel camera;
  final bool isFullscreen;
  final bool isRecording;
  final AnimationController recordingAnim;
  final VoidCallback onToggleFullscreen;

  const _LiveStreamArea({
    required this.camera,
    required this.isFullscreen,
    required this.isRecording,
    required this.recordingAnim,
    required this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    final aspectRatio = isFullscreen ? 16 / 9 : 4 / 3;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        width: double.infinity,
        color: const Color(0xFF050F05),
        child: Stack(
          children: [
            // Stream placeholder
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_rounded,
                    size: 40,
                    color: AppTheme.primaryLight.withOpacity(0.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loading ${camera.resolution} stream...',
                    style: TextStyle(
                      color: AppTheme.primaryLight.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Top-left: LIVE badge
            Positioned(
              top: 10,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BlinkingDot(),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top-right: recording indicator
            if (isRecording)
              Positioned(
                top: 10,
                right: 12,
                child: FadeTransition(
                  opacity: recordingAnim,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fiber_manual_record_rounded,
                          color: AppTheme.errorColor,
                          size: 10,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'REC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom-left: Alert indicator
            Positioned(
              bottom: 10,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ALERT ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-right: timestamp + fullscreen
            Positioned(
              bottom: 10,
              right: 12,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _currentTime(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onToggleFullscreen,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        isFullscreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? (activeColor ?? AppTheme.primaryLight)
        : const Color(0xFF81C784);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? color.withOpacity(0.2)
                  : Colors.white.withOpacity(0.08),
              border: Border.all(
                color: color.withOpacity(isActive ? 0.8 : 0.3),
              ),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

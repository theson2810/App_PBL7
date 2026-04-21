import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ─── Stat Card ─────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? bgColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor ?? AppTheme.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: iconColor ?? AppTheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.only(bottom: 10, top: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Status Badge ──────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  factory StatusBadge.green(String label) => StatusBadge(
        label: label,
        color: const Color(0xFF2E7D32),
        bgColor: const Color(0xFFC8E6C9),
      );

  factory StatusBadge.red(String label) => StatusBadge(
        label: label,
        color: const Color(0xFFC62828),
        bgColor: const Color(0xFFFFEBEE),
      );

  factory StatusBadge.orange(String label) => StatusBadge(
        label: label,
        color: const Color(0xFFE65100),
        bgColor: const Color(0xFFFFF8E1),
      );

  factory StatusBadge.blue(String label) => StatusBadge(
        label: label,
        color: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
      );

  factory StatusBadge.gray(String label) => StatusBadge(
        label: label,
        color: const Color(0xFF616161),
        bgColor: const Color(0xFFF5F5F5),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Camera Thumbnail Card ─────────────────────────────────
class CameraThumbCard extends StatelessWidget {
  final CameraModel camera;
  final VoidCallback? onTap;
  final bool darkMode;

  const CameraThumbCard({
    super.key,
    required this.camera,
    this.onTap,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = camera.status == CameraStatus.live;
    final isOffline = camera.status == CameraStatus.offline;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: darkMode ? const Color(0xFF1A2A1A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isOffline
              ? Border.all(color: const Color(0xFFEF5350).withOpacity(0.5))
              : Border.all(color: Colors.black.withOpacity(0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview area
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: isOffline
                    ? const Color(0xFF1A0A0A)
                    : const Color(0xFF0D1B0D),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.videocam_rounded,
                      size: 28,
                      color: isOffline
                          ? const Color(0xFFEF5350).withOpacity(0.5)
                          : AppTheme.primaryLight.withOpacity(0.3),
                    ),
                  ),
                  if (isLive)
                    Positioned(
                      top: 6,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF5350),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  if (isOffline)
                    Positioned(
                      top: 6,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OFFLINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          camera.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: darkMode
                                ? const Color(0xFFE8F5E9)
                                : AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isLive
                                    ? AppTheme.primaryLight
                                    : const Color(0xFFEF5350),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isLive
                                  ? 'Connected · ${camera.resolution}'
                                  : 'Disconnected',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: darkMode
                                    ? const Color(0xFF81C784)
                                    : (isLive
                                        ? AppTheme.primary
                                        : const Color(0xFFEF5350)),
                              ),
                            ),
                          ],
                        ),
                      ],
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
}

// ─── Alert Card Widget ──────────────────────────────────────
class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onViewRecording;

  const AlertCard({super.key, required this.alert, this.onViewRecording});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: alert.severityBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    alert.typeIcon,
                    size: 16,
                    color: alert.severityColor,
                  ),
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
                          fontWeight: FontWeight.w700,
                          color: alert.severityColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        alert.description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label: alert.severityLabel,
                  color: alert.severityColor,
                  bgColor: alert.severityBg,
                ),
              ],
            ),
          ),
          if (alert.hasSnapshot)
            Container(
              height: 72,
              width: double.infinity,
              color: const Color(0xFF0D0D1A),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_camera_rounded, color: Color(0xFF9E9E9E), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Evidence Snapshot Available',
                      style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTime(alert.time),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      alert.location,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onViewRecording,
                  icon: const Icon(Icons.play_circle_outline, size: 14),
                  label: const Text('View Recording'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Log Item Widget ────────────────────────────────────────
class LogItemWidget extends StatelessWidget {
  final LogEntry entry;

  const LogItemWidget({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.levelColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.message,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: entry.level == LogLevel.error
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: entry.level == LogLevel.error
                        ? AppTheme.errorColor
                        : AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
                if (entry.detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.detail!,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  timeAgo(entry.time),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom App Bar with subtitle ─────────────────────────
class SubtitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const SubtitleAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.backgroundColor,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppTheme.primary,
      leading: leading,
      centerTitle: centerTitle,
      actions: actions,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(
              subtitle!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle != null ? 64 : kToolbarHeight);
}

// ─── Green Banner Card ──────────────────────────────────────
class GreenBannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final Color bgColor;
  final Color borderColor;

  const GreenBannerCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.bottom,
    this.bgColor = AppTheme.surface2,
    this.borderColor = const Color(0xFFA5D6A7),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: 10),
            bottom!,
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

// ─── Camera ───────────────────────────────────────────────
enum CameraStatus { live, offline, connecting }

class CameraModel {
  final String id;
  final String name;
  final String location;
  final CameraStatus status;
  final String resolution;
  final bool aiEnabled;
  final double cpuLoad;

  const CameraModel({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    this.resolution = '1080p',
    this.aiEnabled = true,
    this.cpuLoad = 0.0,
  });
}

final List<CameraModel> mockCameras = [
  const CameraModel(
    id: 'cam1',
    name: 'Ward A — Room 104',
    location: 'Main Building, Floor 1',
    status: CameraStatus.live,
    resolution: '1080p',
    aiEnabled: true,
    cpuLoad: 0.24,
  ),
  const CameraModel(
    id: 'cam2',
    name: 'Common Area East',
    location: 'Main Building, Floor 1',
    status: CameraStatus.live,
    resolution: '1080p',
    aiEnabled: true,
    cpuLoad: 0.18,
  ),
  const CameraModel(
    id: 'cam3',
    name: 'ICU Corridor 2',
    location: 'ICU Wing, Floor 2',
    status: CameraStatus.offline,
    resolution: '720p',
    aiEnabled: false,
    cpuLoad: 0.0,
  ),
];

final List<CameraModel> mockClientCameras = [
  const CameraModel(
    id: 'c1',
    name: 'Living Room',
    location: 'Home · Floor 1',
    status: CameraStatus.live,
    resolution: '1080p',
  ),
  const CameraModel(
    id: 'c2',
    name: 'Bedroom',
    location: 'Home · Floor 2',
    status: CameraStatus.live,
    resolution: '720p',
  ),
  const CameraModel(
    id: 'c3',
    name: 'Kitchen',
    location: 'Home · Floor 1',
    status: CameraStatus.live,
    resolution: '1080p',
  ),
  const CameraModel(
    id: 'c4',
    name: 'Front Door',
    location: 'Home · Entrance',
    status: CameraStatus.live,
    resolution: '1080p',
  ),
];

// ─── Family Member ─────────────────────────────────────────
enum MemberRole { admin, viewer }
enum MemberStatus { active, pending }

class FamilyMember {
  final String id;
  final String name;
  final String email;
  final String relationship;
  final MemberRole role;
  final MemberStatus status;
  final Color avatarColor;
  final String initials;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.email,
    required this.relationship,
    required this.role,
    required this.status,
    required this.avatarColor,
    required this.initials,
  });
}

final List<FamilyMember> mockFamilyMembers = [
  FamilyMember(
    id: 'f1',
    name: 'Sarah Mitchell',
    email: 'sarah@mitchell.com',
    relationship: 'Daughter',
    role: MemberRole.admin,
    status: MemberStatus.active,
    avatarColor: AppColors.green50,
    initials: 'SM',
  ),
  FamilyMember(
    id: 'f2',
    name: 'David Chen',
    email: 'david.chen@mail.com',
    relationship: 'Son',
    role: MemberRole.viewer,
    status: MemberStatus.active,
    avatarColor: const Color(0xFFE3F2FD),
    initials: 'DC',
  ),
  FamilyMember(
    id: 'f3',
    name: 'lisa.roberts@gmail.com',
    email: 'lisa.roberts@gmail.com',
    relationship: 'Pending invite',
    role: MemberRole.viewer,
    status: MemberStatus.pending,
    avatarColor: const Color(0xFFFFF8E1),
    initials: 'LR',
  ),
];

class AppColors {
  static const Color green50 = Color(0xFFE8F5E9);
  static const Color green100 = Color(0xFFC8E6C9);
  static const Color green200 = Color(0xFFA5D6A7);
  static const Color green700 = Color(0xFF388E3C);
  static const Color green800 = Color(0xFF1B5E20);
}

// ─── Alert ─────────────────────────────────────────────────
enum AlertSeverity { emergency, high, medium, notice, info }
enum AlertType { fallDetected, irregularMovement, boundaryEntry, medication, sleep }

class AlertModel {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String description;
  final String location;
  final DateTime time;
  final bool hasSnapshot;

  const AlertModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.location,
    required this.time,
    this.hasSnapshot = false,
  });

  Color get severityColor {
    switch (severity) {
      case AlertSeverity.emergency:
        return const Color(0xFFC62828);
      case AlertSeverity.high:
        return const Color(0xFFD32F2F);
      case AlertSeverity.medium:
        return const Color(0xFFF57F17);
      case AlertSeverity.notice:
        return const Color(0xFF1565C0);
      case AlertSeverity.info:
        return const Color(0xFF2E7D32);
    }
  }

  Color get severityBg {
    switch (severity) {
      case AlertSeverity.emergency:
      case AlertSeverity.high:
        return const Color(0xFFFFEBEE);
      case AlertSeverity.medium:
        return const Color(0xFFFFF8E1);
      case AlertSeverity.notice:
        return const Color(0xFFE3F2FD);
      case AlertSeverity.info:
        return const Color(0xFFE8F5E9);
    }
  }

  String get severityLabel {
    switch (severity) {
      case AlertSeverity.emergency:
        return 'EMERGENCY';
      case AlertSeverity.high:
        return 'HIGH';
      case AlertSeverity.medium:
        return 'MEDIUM';
      case AlertSeverity.notice:
        return 'NOTICE';
      case AlertSeverity.info:
        return 'INFO';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case AlertType.fallDetected:
        return Icons.person_off_rounded;
      case AlertType.irregularMovement:
        return Icons.directions_walk_rounded;
      case AlertType.boundaryEntry:
        return Icons.meeting_room_rounded;
      case AlertType.medication:
        return Icons.medication_rounded;
      case AlertType.sleep:
        return Icons.bedtime_rounded;
    }
  }
}

final List<AlertModel> mockAlerts = [
  AlertModel(
    id: 'a1',
    type: AlertType.fallDetected,
    severity: AlertSeverity.emergency,
    title: 'Fall Detected',
    description: 'Automated sudden downward movement consistent with a fall event. Immediate response recommended.',
    location: 'Room 104',
    time: DateTime.now().subtract(const Duration(minutes: 5)),
    hasSnapshot: true,
  ),
  AlertModel(
    id: 'a2',
    type: AlertType.irregularMovement,
    severity: AlertSeverity.medium,
    title: 'Irregular Movement',
    description: 'Physical movement pattern detected. Subject appears to be pacing. Visual check suggested.',
    location: 'Living Room',
    time: DateTime.now().subtract(const Duration(minutes: 43)),
    hasSnapshot: true,
  ),
  AlertModel(
    id: 'a3',
    type: AlertType.boundaryEntry,
    severity: AlertSeverity.notice,
    title: 'Boundary Entry',
    description: 'Subject entered the foyer area after scheduled rest hours. Door sensor confirmed entry.',
    location: 'Foyer',
    time: DateTime.now().subtract(const Duration(hours: 11, minutes: 21)),
    hasSnapshot: false,
  ),
];

final List<AlertModel> mockHistory = [
  AlertModel(
    id: 'h1',
    type: AlertType.sleep,
    severity: AlertSeverity.info,
    title: 'Sleep Routine Logged',
    description: 'Regular sleep pattern confirmed.',
    location: 'Bedroom',
    time: DateTime.now().subtract(const Duration(hours: 15)),
    hasSnapshot: false,
  ),
  AlertModel(
    id: 'h2',
    type: AlertType.medication,
    severity: AlertSeverity.info,
    title: 'Medication Confirmation',
    description: 'Daily medication intake confirmed at scheduled time.',
    location: 'Kitchen',
    time: DateTime.now().subtract(const Duration(hours: 18, minutes: 45)),
    hasSnapshot: false,
  ),
];

// ─── System Log ─────────────────────────────────────────────
enum LogLevel { error, warning, info, success }

class LogEntry {
  final String id;
  final LogLevel level;
  final String message;
  final String? detail;
  final DateTime time;

  const LogEntry({
    required this.id,
    required this.level,
    required this.message,
    this.detail,
    required this.time,
  });

  Color get levelColor {
    switch (level) {
      case LogLevel.error:
        return const Color(0xFFEF5350);
      case LogLevel.warning:
        return const Color(0xFFFF9800);
      case LogLevel.info:
        return const Color(0xFF2196F3);
      case LogLevel.success:
        return const Color(0xFF4CAF50);
    }
  }
}

final List<LogEntry> mockLogs = [
  LogEntry(
    id: 'l1',
    level: LogLevel.error,
    message: 'Fall detected — Alert pushed to family contacts',
    detail: 'Room 104 · Ward A',
    time: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  LogEntry(
    id: 'l2',
    level: LogLevel.success,
    message: 'AI Model updated: llama-Core-v5 integration',
    detail: 'Version 4.2.1 → 5.0.0',
    time: DateTime.now().subtract(const Duration(minutes: 18)),
  ),
  LogEntry(
    id: 'l3',
    level: LogLevel.warning,
    message: 'MQTT offer sent to hospital internal server',
    detail: 'Awaiting acknowledgment',
    time: DateTime.now().subtract(const Duration(minutes: 93)),
  ),
  LogEntry(
    id: 'l4',
    level: LogLevel.success,
    message: 'Scheduled routine snapshot backup completed',
    detail: '847 frames archived',
    time: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  LogEntry(
    id: 'l5',
    level: LogLevel.info,
    message: 'Camera 1 connected via PoE interface 8/1',
    detail: 'Interface: eth8/1 · PoE class 4',
    time: DateTime.now().subtract(const Duration(hours: 11, minutes: 24)),
  ),
  LogEntry(
    id: 'l6',
    level: LogLevel.info,
    message: 'WebRTC stream initialized — Client: Sarah Mitchell',
    detail: 'Session ID: wrtc-9b3f2a',
    time: DateTime.now().subtract(const Duration(hours: 13)),
  ),
  LogEntry(
    id: 'l7',
    level: LogLevel.success,
    message: 'Daily summary generated and delivered',
    detail: '3 family members notified',
    time: DateTime.now().subtract(const Duration(hours: 17)),
  ),
  LogEntry(
    id: 'l8',
    level: LogLevel.error,
    message: 'ICU Corridor 2 — Camera offline',
    detail: 'PoE port 3 power loss detected',
    time: DateTime.now().subtract(const Duration(hours: 20)),
  ),
];

// ─── Helper Functions ──────────────────────────────────────
String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return 'Yesterday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

String formatTime(DateTime time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  final diff = DateTime.now().difference(time);
  if (diff.inDays == 0) return '$h:$m PM';
  return 'Yesterday · $h:$m PM';
}

import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Current Wi-Fi network used to verify admin and member are on the same LAN.
class WifiNetworkInfo {
  final String ssid;
  final String ssidFingerprint;
  final String? bssid;
  final String? bssidFingerprint;

  const WifiNetworkInfo({
    required this.ssid,
    required this.ssidFingerprint,
    this.bssid,
    this.bssidFingerprint,
  });

  bool get isValid =>
      ssidFingerprint.isNotEmpty ||
      (bssidFingerprint != null && bssidFingerprint!.isNotEmpty);
}

class WifiNetworkService {
  WifiNetworkService._();

  static final WifiNetworkService instance = WifiNetworkService._();

  final NetworkInfo _networkInfo = NetworkInfo();

  static String normalizeFingerprint(String raw) {
    return raw.replaceAll('"', '').trim().toLowerCase();
  }

  static String? normalizeBssid(String? raw) {
    if (raw == null) return null;
    final cleaned = raw
        .replaceAll('"', '')
        .replaceAll(':', '')
        .replaceAll('-', '')
        .trim()
        .toLowerCase();
    if (cleaned.isEmpty ||
        cleaned == '02:00:00:00:00:00'.replaceAll(':', '') ||
        cleaned == '000000000000') {
      return null;
    }
    return cleaned;
  }

  static bool _isUnknownSsid(String value) {
    final v = value.toLowerCase();
    return v.isEmpty ||
        v == '<unknown ssid>' ||
        v == 'unknown' ||
        v == 'null' ||
        v == '0x' ||
        v == 'wlan0';
  }

  Future<bool> ensurePermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final camera = await Permission.camera.request();
    if (!camera.isGranted) return false;

    if (Platform.isAndroid || Platform.isIOS) {
      final location = await Permission.locationWhenInUse.request();
      if (!location.isGranted) return false;
    }
    return true;
  }

  Future<WifiNetworkInfo> getCurrentNetwork() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return const WifiNetworkInfo(ssid: '', ssidFingerprint: '');
    }

    String? ssid;
    String? bssid;
    try {
      ssid = await _networkInfo.getWifiName();
      bssid = await _networkInfo.getWifiBSSID();
    } catch (_) {}

    final ssidRaw = (ssid ?? '').replaceAll('"', '').trim();
    final ssidFp = normalizeFingerprint(ssidRaw);
    final bssidFp = normalizeBssid(bssid);

    if (!_isUnknownSsid(ssidFp)) {
      return WifiNetworkInfo(
        ssid: ssidRaw,
        ssidFingerprint: ssidFp,
        bssid: bssid,
        bssidFingerprint: bssidFp,
      );
    }

    if (bssidFp != null) {
      return WifiNetworkInfo(
        ssid: ssidRaw.isNotEmpty ? ssidRaw : 'Wi-Fi',
        ssidFingerprint: '',
        bssid: bssid,
        bssidFingerprint: bssidFp,
      );
    }

    return const WifiNetworkInfo(ssid: '', ssidFingerprint: '');
  }
}

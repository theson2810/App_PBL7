import '../services/wifi_network_service.dart';

/// Compares admin session network with member device (SSID + BSSID).
class WifiMatchHelper {
  static String _coreSsid(String fp) {
    var s = fp.toLowerCase();
    for (final suffix in ['-5g', '_5g', ' 5g', '-2.4g', '_2.4g']) {
      if (s.endsWith(suffix)) {
        s = s.substring(0, s.length - suffix.length);
        break;
      }
    }
    return s.trim();
  }

  static bool matches({
    required String? sessionSsidFp,
    String? sessionBssidFp,
    required WifiNetworkInfo member,
  }) {
    final adminBssid = (sessionBssidFp ?? '').trim().toLowerCase();
    final memberBssid = member.bssidFingerprint ?? '';

    if (adminBssid.isNotEmpty &&
        memberBssid.isNotEmpty &&
        adminBssid == memberBssid) {
      return true;
    }

    final adminSsid = (sessionSsidFp ?? '').trim().toLowerCase();
    final memberSsid = member.ssidFingerprint;

    if (adminSsid.isNotEmpty && memberSsid.isNotEmpty) {
      if (adminSsid == memberSsid) return true;
      if (_coreSsid(adminSsid) == _coreSsid(memberSsid)) return true;
    }

    return false;
  }
}

/// URL RTSP và relay ID chuẩn cho camera Tenda CP6.
class TendaCameraHelper {
  TendaCameraHelper._();

  static final _ipv4 = RegExp(
    r'^(?:25[0-5]|2[0-4]\d|1?\d?\d)(?:\.(?:25[0-5]|2[0-4]\d|1?\d?\d)){3}$',
  );

  static bool isValidIpv4(String ip) => _ipv4.hasMatch(ip.trim());

  static String mainRtspUrl(String ip) => 'rtsp://${ip.trim()}/tenda';

  static String subRtspUrl(String ip) => 'rtsp://${ip.trim()}/tenda_sub';

  /// Khớp `CAMERA_ID` / `relay_id_from_ip` trên publisher Python.
  static String relayIdFromIp(String ip) =>
      'tenda_${ip.trim().replaceAll('.', '_')}';

  static String defaultName(String ip) => 'Tenda CP6 — $ip';
}

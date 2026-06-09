import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Cấu hình relay VPS — **không hardcode IP trong app**.
///
/// Toàn bộ URL relay đọc từ Firestore `app_config/relay` (đổi IP VPS chỉ cần sửa Firestore):
/// ```json
/// {
///   "baseUrl": "http://YOUR_VPS_PUBLIC_IP:8080",
///   "stunUrl": "stun:stun.l.google.com:19302",
///   "relayToken": "cùng giá trị RELAY_TOKEN trên VPS"
/// }
/// ```
///
/// Chip/laptop dùng `python/.env` (`RELAY_URL`) — tách biệt với app mobile.
class RelayConfig {
  RelayConfig._();

  /// STUN công cộng — không phải IP VPS, có thể giữ mặc định.
  static const String defaultStunUrl = 'stun:stun.l.google.com:19302';

  static String baseUrl = '';
  static String stunUrl = defaultStunUrl;
  static String? relayToken;

  static bool get isBaseUrlReady => baseUrl.trim().isNotEmpty;

  static bool get isRelayTokenReady =>
      relayToken != null && relayToken!.trim().isNotEmpty;

  /// Đủ `baseUrl` + `relayToken` từ Firestore.
  static bool get isConfigured => isBaseUrlReady && isRelayTokenReady;

  /// Đọc / làm mới cấu hình từ Firestore. Trả `true` nếu đủ dữ liệu.
  static Future<bool> loadFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('relay')
          .get();
      final data = doc.data();
      if (data == null) {
        if (kDebugMode) {
          debugPrint(
            'RelayConfig: document app_config/relay không tồn tại — '
            'tạo trên Firebase Console',
          );
        }
        return false;
      }

      final url = data['baseUrl'] as String?;
      final stun = data['stunUrl'] as String?;
      final token = data['relayToken'] as String?;

      if (url != null && url.trim().isNotEmpty) {
        baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
      }
      if (stun != null && stun.trim().isNotEmpty) {
        stunUrl = stun.trim();
      }
      if (token != null && token.trim().isNotEmpty) {
        relayToken = token.trim();
      }

      if (kDebugMode) {
        debugPrint(
          'RelayConfig: loaded baseUrl=${isBaseUrlReady ? baseUrl : "(missing)"} '
          'token=${isRelayTokenReady}',
        );
      }
      return isConfigured;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RelayConfig.loadFromFirestore: $e');
      }
      return false;
    }
  }

  /// Gọi trước mọi request relay — luôn thử tải lại nếu thiếu baseUrl hoặc token.
  static Future<void> ensureLoaded() async {
    if (isConfigured) return;
    await loadFromFirestore();
  }

  /// Xóa cache — gọi sau khi admin cập nhật Firestore.
  static void reset() {
    baseUrl = '';
    stunUrl = defaultStunUrl;
    relayToken = null;
  }

  static void _requireBaseUrl() {
    if (!isBaseUrlReady) {
      throw RelayConfigException('relay_not_configured');
    }
  }

  static Map<String, dynamic> get iceServers => {
        'iceServers': [
          {'urls': stunUrl},
        ],
      };

  static Uri rootUri() {
    _requireBaseUrl();
    return Uri.parse('$baseUrl/');
  }

  static Uri camerasUri() {
    _requireBaseUrl();
    return Uri.parse('$baseUrl/cameras');
  }

  static Uri watchUri(String relayCameraId) {
    _requireBaseUrl();
    return Uri.parse('$baseUrl/watch/$relayCameraId');
  }
}

class RelayConfigException implements Exception {
  final String code;
  RelayConfigException(this.code);

  @override
  String toString() => 'RelayConfigException: $code';
}

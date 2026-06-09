import 'package:flutter/foundation.dart';

import '../../config/relay_config.dart';
import 'relay_auth_service.dart';

/// Cấp Bearer token cho `/watch/{cameraId}` — khớp VPS `check_auth`.
///
/// VPS hiện tại (main.py):
/// ```python
/// expected = f"Bearer {RELAY_TOKEN}"
/// if authorization != expected: raise 403
/// ```
///
/// Luồng app (không hardcode token trong APK):
/// 1. User phải đăng nhập Firebase Auth (xác thực danh tính).
/// 2. `relayToken` đọc từ Firestore `app_config/relay` (admin cấu hình 1 lần).
/// 3. Gửi `Authorization: Bearer {relayToken}` khi POST `/watch/...`.
///
/// Sau này nâng cấp VPS: thêm `POST /auth/watch-token` nhận Firebase JWT,
/// trả token ngắn hạn — chỉ cần sửa service này.
class RelayTokenService {
  RelayTokenService._();

  static final RelayTokenService instance = RelayTokenService._();

  final RelayAuthService _auth = RelayAuthService.instance;

  /// Token Bearer cho relay VPS.
  Future<String> fetchWatchToken(String relayCameraId) async {
    // Bước 1: Bắt buộc có phiên Firebase (admin / member).
    await _auth.getFirebaseIdToken(forceRefresh: false);

    // Bước 2: URL VPS + token relay từ Firestore (không hardcode trong APK).
    await RelayConfig.ensureLoaded();

    if (!RelayConfig.isBaseUrlReady) {
      throw RelayTokenException('relay_not_configured');
    }

    final token = RelayConfig.relayToken;
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'RelayTokenService: missing app_config/relay.relayToken for $relayCameraId',
        );
      }
      throw RelayTokenException('relay_token_not_configured');
    }

    return token;
  }
}

class RelayTokenException implements Exception {
  final String code;
  RelayTokenException(this.code);

  @override
  String toString() => 'RelayTokenException: $code';
}

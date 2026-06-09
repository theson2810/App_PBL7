import 'package:firebase_auth/firebase_auth.dart';

/// Xác thực người dùng app qua Firebase Auth trước khi xem camera.
///
/// Relay VPS (`main.py`) hiện dùng `RELAY_TOKEN` tĩnh — token đó lấy từ
/// Firestore qua [RelayTokenService], không nhúng trong APK.
///
/// Firebase Auth đảm bảo chỉ user đã đăng nhập mới gọi được relay
/// (kết hợp Firestore Security Rules cho `app_config/relay`).
class RelayAuthService {
  RelayAuthService._();

  static final RelayAuthService instance = RelayAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getFirebaseIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw RelayAuthException('not_signed_in');
    }

    final token = await user.getIdToken(forceRefresh);
    if (token == null || token.isEmpty) {
      throw RelayAuthException('empty_id_token');
    }
    return token;
  }

  String? get currentUid => _auth.currentUser?.uid;
}

class RelayAuthException implements Exception {
  final String code;
  RelayAuthException(this.code);

  @override
  String toString() => 'RelayAuthException: $code';
}

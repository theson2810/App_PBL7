import '../localization/app_localization.dart';

String mapAuthError(AppLocalizations loc, String? raw) {
  if (raw == null || raw.isEmpty) return loc.translate('login_failed');
  if (raw.contains('permission-denied')) {
    return loc.translate('firestore_permission_denied');
  }
  if (raw.contains('user-not-found') || raw.contains('invalid-credential')) {
    return loc.translate('login_failed');
  }
  if (raw.contains('wrong-password')) {
    return loc.translate('login_failed');
  }
  return raw;
}

import '../localization/app_localization.dart';

String mapFamilyJoinError(AppLocalizations loc, Object error) {
  final raw = error.toString();
  final code = raw.contains('Exception:')
      ? raw.split('Exception:').last.trim()
      : raw.trim();

  switch (code) {
    case 'wifi_unavailable':
      return loc.translate('wifi_unavailable');
    case 'wifi_mismatch':
      return loc.translate('wifi_mismatch');
    case 'invalid_session':
    case 'session_used':
      return loc.translate('wifi_session_invalid');
    case 'session_expired':
      return loc.translate('wifi_session_expired');
    case 'already_member':
      return loc.translate('already_member_family');
    case 'cannot_join_own_family':
      return loc.translate('cannot_join_own_family');
    case 'not_admin':
      return loc.translate('wifi_not_admin');
    case 'not_signed_in':
      return loc.translate('invite_login_required');
    case 'invalid_code':
      return loc.translate('invalid_code');
    case 'already_pending':
      return loc.translate('already_pending_join');
    case 'already_in_other_family':
      return loc.translate('already_in_other_family');
    case 'qr_refresh_cooldown':
      return loc.translate('qr_refresh_cooldown');
    case 'member_not_found':
      return loc.translate('member_not_found');
    case 'cannot_remove_admin':
      return loc.translate('cannot_remove_admin');
    default:
      return '${loc.translate('error_prefix')}: $code';
  }
}

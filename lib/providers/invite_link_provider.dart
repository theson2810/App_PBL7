import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPendingInviteToken = 'pending_invite_token';

/// Holds a family invite token from `elderlycare://family-invite?t=...` until consumed.
class InviteLinkProvider extends ChangeNotifier {
  String? _token;
  bool _restored = false;

  String? get pendingToken => _token;

  bool get hasPendingInvite => _token != null && _token!.isNotEmpty;

  InviteLinkProvider() {
    _restoreFromDisk();
  }

  Future<void> _restoreFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kPendingInviteToken)?.trim();
      if (saved != null && saved.isNotEmpty) {
        _token = saved;
      }
    } catch (_) {}
    _restored = true;
    notifyListeners();
  }

  Future<void> setInviteToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return;
    _token = trimmed;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPendingInviteToken, trimmed);
    } catch (_) {}
    notifyListeners();
  }

  /// Returns token and clears it (one-time use).
  String? consumeToken() {
    final t = _token;
    _token = null;
    _clearDisk();
    if (t != null) notifyListeners();
    return t;
  }

  void clear() {
    _token = null;
    _clearDisk();
    notifyListeners();
  }

  Future<void> _clearDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPendingInviteToken);
    } catch (_) {}
  }

  /// Wait until disk restore finishes (for cold start deep links).
  Future<void> ensureRestored() async {
    if (_restored) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!_restored) await _restoreFromDisk();
  }
}

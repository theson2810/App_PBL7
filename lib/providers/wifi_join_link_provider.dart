import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPendingWifiJoinSession = 'pending_wifi_join_session';

/// Holds session id from `elderlycare://family-wifi-join?s=...` until consumed.
class WifiJoinLinkProvider extends ChangeNotifier {
  String? _sessionId;
  bool _restored = false;

  String? get pendingSessionId => _sessionId;

  bool get hasPendingWifiJoin =>
      _sessionId != null && _sessionId!.isNotEmpty;

  WifiJoinLinkProvider() {
    _restoreFromDisk();
  }

  Future<void> _restoreFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kPendingWifiJoinSession)?.trim();
      if (saved != null && saved.isNotEmpty) {
        _sessionId = saved;
      }
    } catch (_) {}
    _restored = true;
    notifyListeners();
  }

  Future<void> setSessionId(String sessionId) async {
    final trimmed = sessionId.trim();
    if (trimmed.isEmpty) return;
    _sessionId = trimmed;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPendingWifiJoinSession, trimmed);
    } catch (_) {}
    notifyListeners();
  }

  String? consumeSessionId() {
    final id = _sessionId;
    _sessionId = null;
    _clearDisk();
    if (id != null) notifyListeners();
    return id;
  }

  void clear() {
    _sessionId = null;
    _clearDisk();
    notifyListeners();
  }

  Future<void> _clearDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPendingWifiJoinSession);
    } catch (_) {}
  }

  Future<void> ensureRestored() async {
    if (_restored) return;
    await _restoreFromDisk();
  }
}

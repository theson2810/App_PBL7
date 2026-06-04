import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import '../providers/invite_link_provider.dart';
import '../providers/wifi_join_link_provider.dart';

/// Handles family invite and Wi-Fi QR join deep links.
class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  InviteLinkProvider? _inviteProvider;
  WifiJoinLinkProvider? _wifiJoinProvider;

  Future<void> start(
    InviteLinkProvider inviteProvider, {
    WifiJoinLinkProvider? wifiJoinProvider,
  }) async {
    _inviteProvider = inviteProvider;
    _wifiJoinProvider = wifiJoinProvider;
    await _sub?.cancel();

    try {
      final initial = await _appLinks.getInitialLink();
      _handleUri(initial);
    } catch (e) {
      debugPrint('DeepLinkService.getInitialLink: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (e) => debugPrint('DeepLinkService.uriLinkStream: $e'),
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _inviteProvider = null;
    _wifiJoinProvider = null;
  }

  void _handleUri(Uri? uri) {
    final token = parseFamilyInviteToken(uri);
    if (token != null && token.isNotEmpty) {
      _inviteProvider?.setInviteToken(token);
      return;
    }
    final wifiSession = parseWifiJoinSessionId(uri);
    if (wifiSession != null && wifiSession.isNotEmpty) {
      _wifiJoinProvider?.setSessionId(wifiSession);
    }
  }

  /// Parses invite token from custom scheme or path-style URIs.
  static String? parseFamilyInviteToken(Uri? uri) {
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    final isInvite = host == 'family-invite' || path.contains('family-invite');
    if (!isInvite) return null;

    final t = uri.queryParameters['t'] ?? uri.queryParameters['token'];
    return t?.trim();
  }

  /// Parses `elderlycare://family-wifi-join?s=<sessionId>`.
  static String? parseWifiJoinSessionId(Uri? uri) {
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    final isWifiJoin =
        host == 'family-wifi-join' || path.contains('family-wifi-join');
    if (!isWifiJoin) return null;

    return uri.queryParameters['s']?.trim();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../localization/app_localization.dart';
import '../repositories/family_repository.dart';
import '../services/wifi_network_service.dart';
import '../theme/app_theme.dart';
import '../utils/family_join_error_mapper.dart';

/// Admin: shows a time-limited QR code for same-Wi-Fi family join.
class FamilyWifiQrSheet extends StatefulWidget {
  final String familyId;

  const FamilyWifiQrSheet({super.key, required this.familyId});

  static Future<void> show(BuildContext context, {required String familyId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FamilyWifiQrSheet(familyId: familyId),
    );
  }

  @override
  State<FamilyWifiQrSheet> createState() => _FamilyWifiQrSheetState();
}

class _FamilyWifiQrSheetState extends State<FamilyWifiQrSheet> {
  final _familyRepo = FamilyRepository();
  Timer? _countdownTimer;

  String? _uri;
  String? _networkLabel;
  DateTime? _expiresAt;
  DateTime? _nextRefreshAt;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _createSession());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _createSession() async {
    final loc = AppLocalizations.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await WifiNetworkService.instance.ensurePermissions();
    if (!ok) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = loc.translate('wifi_permission_denied');
      });
      return;
    }

    try {
      final result = await _familyRepo.createWifiJoinSession(widget.familyId);
      if (!mounted) return;
      setState(() {
        _uri = result['uri'] as String?;
        _networkLabel = result['networkLabel'] as String?;
        _expiresAt = result['expiresAt'] as DateTime?;
        _nextRefreshAt = DateTime.now().add(const Duration(minutes: 1));
        _loading = false;
      });
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = mapFamilyJoinError(loc, e);
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_expiresAt != null && DateTime.now().isAfter(_expiresAt!)) {
        _countdownTimer?.cancel();
      }
      setState(() {});
    });
  }

  bool get _canRefresh =>
      _nextRefreshAt == null || !DateTime.now().isBefore(_nextRefreshAt!);

  int get _refreshCooldownSeconds {
    if (_nextRefreshAt == null) return 0;
    final left = _nextRefreshAt!.difference(DateTime.now()).inSeconds;
    return left > 0 ? left : 0;
  }

  Future<void> _onRefreshPressed() async {
    final loc = AppLocalizations.of(context);
    if (!_canRefresh) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${loc.translate('qr_refresh_wait')}: ${_refreshCooldownSeconds}s',
          ),
        ),
      );
      return;
    }
    await _createSession();
  }

  String _remainingLabel(AppLocalizations loc) {
    if (_expiresAt == null) return '';
    final left = _expiresAt!.difference(DateTime.now());
    if (left.isNegative) return loc.translate('wifi_session_expired');
    final m = left.inMinutes;
    final s = left.inSeconds % 60;
    return '${loc.translate('wifi_expires_in')}: ${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            loc.translate('wifi_qr_title'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            loc.translate('wifi_qr_admin_help'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _createSession,
                    child: Text(loc.translate('try_again')),
                  ),
                ],
              ),
            )
          else if (_uri != null) ...[
            if (_networkLabel != null && _networkLabel!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_rounded, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('wifi_network_label'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            _networkLabel!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryContainer, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: _uri!,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _remainingLabel(loc),
              style: TextStyle(
                fontSize: 12,
                color: _expiresAt != null && DateTime.now().isAfter(_expiresAt!)
                    ? AppTheme.errorColor
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _canRefresh ? _onRefreshPressed : null,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                _canRefresh
                    ? loc.translate('wifi_refresh_qr')
                    : '${loc.translate('qr_refresh_wait')} (${_refreshCooldownSeconds}s)',
              ),
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('close')),
          ),
        ],
      ),
    );
  }
}

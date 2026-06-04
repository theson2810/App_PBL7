import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localization.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/family_repository.dart';
import '../../services/deep_link_service.dart';
import '../../services/wifi_network_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/family_join_error_mapper.dart';

/// Family member scans admin Wi-Fi QR to join instantly on the same network.
class FamilyWifiQrScanScreen extends StatefulWidget {
  const FamilyWifiQrScanScreen({super.key});

  @override
  State<FamilyWifiQrScanScreen> createState() => _FamilyWifiQrScanScreenState();
}

class _FamilyWifiQrScanScreenState extends State<FamilyWifiQrScanScreen> {
  final _familyRepo = FamilyRepository();
  final _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _processing = false;
  bool _permissionReady = false;
  String? _wifiName;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final loc = AppLocalizations.of(context);
    final ok = await WifiNetworkService.instance.ensurePermissions();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('wifi_permission_denied'))),
      );
      Navigator.pop(context);
      return;
    }
    final network = await WifiNetworkService.instance.getCurrentNetwork();
    if (!mounted) return;
    setState(() {
      _permissionReady = true;
      _wifiName = network.ssid;
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handlePayload(String raw) async {
    if (_processing) return;
    final loc = AppLocalizations.of(context);

    final sessionId = _parseSessionId(raw);
    if (sessionId == null || sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('wifi_invalid_qr'))),
      );
      return;
    }

    setState(() => _processing = true);
    await _scannerController.stop();

    try {
      await _familyRepo.joinFamilyViaWifiSession(sessionId);
      if (!mounted) return;
      await context.read<AuthProvider>().reloadUserProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('wifi_join_success')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapFamilyJoinError(loc, e))),
      );
      await _scannerController.start();
      setState(() => _processing = false);
    }
  }

  String? _parseSessionId(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      final fromUri = DeepLinkService.parseWifiJoinSessionId(uri);
      if (fromUri != null && fromUri.isNotEmpty) return fromUri;
    }

    if (trimmed.length >= 12 && !trimmed.contains('://')) {
      return trimmed;
    }
    return null;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        _handlePayload(value);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: Text(loc.translate('wifi_scan_title')),
      ),
      body: !_permissionReady
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                if (_wifiName != null && _wifiName!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: AppTheme.primaryContainer,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_rounded, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${loc.translate('wifi_your_network')}: $_wifiName',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    loc.translate('wifi_scan_help'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                      ),
                      if (_processing)
                        Container(
                          color: Colors.black54,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: Colors.white),
                              const SizedBox(height: 12),
                              Text(
                                loc.translate('wifi_join_processing'),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

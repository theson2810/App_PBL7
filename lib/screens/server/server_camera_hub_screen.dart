import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../theme/app_theme.dart';
import 'camera_config_screen.dart';

class ServerCameraHubScreen extends StatelessWidget {
  const ServerCameraHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.cameraConfig,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              loc.translate('camera_hub_subtitle'),
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
      body: const CameraConfigScreen(embedded: true),
    );
  }
}

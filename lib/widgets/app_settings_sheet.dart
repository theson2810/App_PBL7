import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/app_localization.dart';
import '../localization/language_provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';

Future<void> showAppSettingsSheet(
  BuildContext context, {
  required LanguageProvider languageProvider,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AppSettingsSheet(languageProvider: languageProvider),
  );
}

class _AppSettingsSheet extends StatelessWidget {
  final LanguageProvider languageProvider;

  const _AppSettingsSheet({required this.languageProvider});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = context.watch<AppSettingsProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            loc.translate('app_settings'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text(loc.translate('dark_mode')),
            value: settings.darkMode,
            onChanged: settings.setDarkMode,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language_outlined),
            title: Text(loc.language),
            subtitle: Text(
              languageProvider.isVietnamese ? loc.vietnamese : loc.english,
            ),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'vi', label: Text(loc.vietnamese)),
                ButtonSegment(value: 'en', label: Text(loc.english)),
              ],
              selected: {languageProvider.isVietnamese ? 'vi' : 'en'},
              onSelectionChanged: (value) {
                languageProvider.setLanguage(value.first);
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('text_size'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Slider(
            value: settings.textScale,
            min: 0.9,
            max: 1.25,
            divisions: 7,
            activeColor: AppTheme.primary,
            label: '${(settings.textScale * 100).round()}%',
            onChanged: settings.setTextScale,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/app_settings_sheet.dart';
import '../../widgets/edit_profile_sheet.dart';
import '../../localization/app_localization.dart';
import '../../localization/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_models.dart';

class ProfileScreen extends StatefulWidget {
  final LanguageProvider languageProvider;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    required this.languageProvider,
    this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.languageProvider,
      builder: (context, _) {
        final loc = AppLocalizations.of(context);
        final user = context.watch<AuthProvider>().user;

        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _ProfileHeader(user: user),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Aegis Premium banner
                      _PremiumBanner(),
                      const SizedBox(height: 16),

                      // Account settings
                      SectionHeader(title: AppLocalizations.of(context).translate('personal_info')),
                      _SettingsGroup(
                        items: [
                          _SettingsItem(
                            icon: Icons.person_outline_rounded,
                            label: loc.translate('personal_info'),
                            subtitle: user != null
                                ? '${user.fullName} · ${user.email}'
                                : '—',
                            onTap: user == null
                                ? () {}
                                : () => showEditProfileSheet(context, user: user),
                          ),
                          _SettingsItem(
                            icon: Icons.phonelink_rounded,
                            label: loc.translate('shared_devices'),
                            subtitle: loc.translate('shared_devices_sub'),
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.group_outlined,
                            label: loc.translate('family_members_setting'),
                            subtitle: loc.translate('family_members_sub'),
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      SectionHeader(title: loc.translate('monitoring_section')),
                      _SettingsGroup(
                        items: [
                          _SettingsItem(
                            icon: Icons.notifications_active_outlined,
                            label: loc.translate('alert_preferences'),
                            subtitle: loc.translate('alert_preferences_sub'),
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.schedule_rounded,
                            label: loc.translate('monitoring_schedule'),
                            subtitle: loc.translate('monitoring_schedule_sub'),
                            trailing: StatusBadge.green(loc.translate('monitoring_on')),
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      SectionHeader(title: loc.translate('app_section')),
                      _SettingsGroup(
                        items: [
                          _SettingsItem(
                            icon: Icons.language_outlined,
                            label: AppLocalizations.of(context).language,
                            subtitle: widget.languageProvider.isVietnamese ? 'Tiếng Việt' : 'English',
                            trailing: LanguageSwitcher(
                              isVietnamese: widget.languageProvider.isVietnamese,
                              onToggle: () {
                                widget.languageProvider.toggleLanguage();
                              },
                            ),
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.settings_outlined,
                            label: loc.translate('app_settings'),
                            subtitle: loc.translate('app_settings_sub'),
                            onTap: () => showAppSettingsSheet(
                              context,
                              languageProvider: widget.languageProvider,
                            ),
                          ),
                          _SettingsItem(
                            icon: Icons.security_rounded,
                            label: loc.translate('privacy_security'),
                            subtitle: loc.translate('privacy_sub'),
                            trailing: StatusBadge.green(loc.translate('privacy_secure')),
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.help_outline_rounded,
                            label: loc.translate('help_support'),
                            subtitle: loc.translate('help_sub'),
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.info_outline_rounded,
                            label: loc.translate('about'),
                            subtitle: loc.translate('about_sub'),
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      _SettingsGroup(
                        items: [
                          _SettingsItem(
                            icon: Icons.logout_rounded,
                            label: loc.logout,
                            subtitle: loc.translate('logout_subtitle'),
                            iconColor: AppTheme.errorColor,
                            labelColor: AppTheme.errorColor,
                            showArrow: false,
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc.logout,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          loc.translate('logout_confirm_message'),
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              widget.onLogout?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(loc.logout),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserAccount? user;

  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.primaryDark,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).translate('profile_header'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                onPressed: user == null
                    ? null
                    : () => showEditProfileSheet(context, user: user!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor:
                    user?.avatarColor ?? Colors.white.withOpacity(0.15),
                backgroundImage: user?.avatar?.isNotEmpty == true
                    ? NetworkImage(user!.avatar!)
                    : null,
                child: user?.avatar?.isNotEmpty == true
                    ? null
                    : Text(
                        user?.initials ?? 'MB',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryLight,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user?.fullName ?? 'Member',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user?.email ?? '',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ProfileStat(label: 'Cameras', value: '4'),
              _ProfileStatDivider(),
              _ProfileStat(label: 'Alerts', value: '127'),
              _ProfileStatDivider(),
              _ProfileStat(label: 'Days Active', value: '42'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white24,
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryLight.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aegis Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your health history is secured with end-to-end protection everywhere.',
                  style: TextStyle(
                    color: Color(0xFF81C784),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              backgroundColor: AppTheme.primaryLight.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: AppTheme.primaryLight.withOpacity(0.4),
                ),
              ),
            ),
            child: const Text('View', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;

  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 52),
        itemBuilder: (_, i) => items[i],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final Color? labelColor;
  final bool showArrow;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.trailing,
    this.iconColor,
    this.labelColor,
    this.showArrow = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: labelColor ?? AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            if (showArrow) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textTertiary,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

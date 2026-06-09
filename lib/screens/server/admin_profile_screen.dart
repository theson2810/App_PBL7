import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/auth_models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/app_settings_sheet.dart';
import '../../localization/app_localization.dart';
import '../../localization/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/edit_profile_sheet.dart';

class AdminProfileScreen extends StatefulWidget {
  final LanguageProvider languageProvider;
  final VoidCallback? onLogout;

  const AdminProfileScreen({
    super.key,
    required this.languageProvider,
    this.onLogout,
  });

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return ListenableBuilder(
      listenable: widget.languageProvider,
      builder: (context, _) {
        final loc = AppLocalizations.of(context);
        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                _ProfileHeader(user: user),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account settings
                      SectionHeader(title: AppLocalizations.of(context).translate('personal_info')),
                      _SettingsGroup(
                        items: [
                          _SettingsItem(
                            icon: Icons.person_outline_rounded,
                            label: loc.translate('personal_info'),
                            subtitle: user?.email ?? 'admin@example.com',
                            onTap: user == null
                                ? () {}
                                : () => showEditProfileSheet(context, user: user),
                          ),
                          _SettingsItem(
                            icon: Icons.badge_outlined,
                            label: loc.translate('account_type_label'),
                            subtitle: loc.translate('administrator_role'),
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.phone_outlined,
                            label: loc.translate('contact_label'),
                            subtitle: user?.phone ?? loc.translate('not_set'),
                            onTap: user == null
                                ? () {}
                                : () => showEditProfileSheet(context, user: user),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      SectionHeader(title: loc.translate('system_section')),
                      _SettingsGroup(
                        items: [
                          _SettingsItem(
                            icon: Icons.security_rounded,
                            label: loc.translate('permissions'),
                            subtitle: loc.translate('full_system_access'),
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.history_rounded,
                            label: loc.translate('activity_log'),
                            subtitle: loc.translate('view_system_changes'),
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      SectionHeader(title: loc.translate('app_section')),
                      _SettingsGroup(
                        items: [
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
                            icon: Icons.info_outline_rounded,
                            label: loc.translate('about'),
                            subtitle: loc.translate('about_server_sub'),
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
                            subtitle: loc.translate('logout_admin_subtitle'),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(ctx).logout,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          AppLocalizations.of(ctx).translate('admin_logout_message'),
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx).translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(AppLocalizations.of(ctx).logout),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserAccount? user;

  const _ProfileHeader({required this.user});

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
                AppLocalizations.of(context).translate('admin_profile_header'),
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
                backgroundColor: user?.avatarColor ?? Colors.white.withOpacity(0.15),
                backgroundImage: user?.avatar?.isNotEmpty == true
                    ? NetworkImage(user!.avatar!)
                    : null,
                child: user?.avatar?.isNotEmpty == true
                    ? null
                    : Text(
                        user?.initials ?? 'AD',
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
            user?.fullName ?? AppLocalizations.of(context).translate('administrator_default'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user?.email ?? 'admin@example.com',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
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

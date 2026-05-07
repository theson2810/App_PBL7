import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/auth_models.dart';
import '../../widgets/common_widgets.dart';
import '../../localization/app_localization.dart';
import '../../localization/language_provider.dart';
import '../../providers/auth_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  final VoidCallback onSwitchApp;
  final LanguageProvider languageProvider;
  final VoidCallback? onLogout;

  const AdminProfileScreen({
    super.key,
    required this.onSwitchApp,
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
        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                _ProfileHeader(
                  user: user,
                  onSwitchApp: widget.onSwitchApp,
                ),

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
                            label: 'Personal Information',
                            subtitle: user?.email ?? 'admin@example.com',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.badge_outlined,
                            label: 'Account Type',
                            subtitle: 'Administrator',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.family_restroom_rounded,
                            label: 'Family Code',
                            subtitle: user?.familyCode ?? 'FAM-XXXXXXXX',
                            trailing: IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Copied: ${user?.familyCode}',
                                    ),
                                  ),
                                );
                              },
                            ),
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.phone_outlined,
                            label: 'Contact',
                            subtitle: user?.phone ?? 'Not set',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      const SectionHeader(title: 'System'),
                      _SettingsGroup(
                        items: [
                          _SettingsItem(
                            icon: Icons.security_rounded,
                            label: 'Permissions',
                            subtitle: 'Full system access',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.history_rounded,
                            label: 'Activity Log',
                            subtitle: 'View system changes',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      const SectionHeader(title: 'App'),
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
                            label: 'App Settings',
                            subtitle: 'Theme, language & display',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.info_outline_rounded,
                            label: 'About',
                            subtitle: 'Version 1.0.0 · Clinical Sentinel',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      _SettingsGroup(
                        items: [
                          _SettingsItem(
                            icon: Icons.logout_rounded,
                            label: 'Logout',
                            subtitle: 'Sign out of the system',
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
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to log out from the admin panel?',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserAccount? user;
  final VoidCallback onSwitchApp;

  const _ProfileHeader({
    required this.user,
    required this.onSwitchApp,
  });

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
              const Text(
                'Admin Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                  GestureDetector(
                    onTap: onSwitchApp,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'User',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: user?.avatarColor ?? Colors.white.withOpacity(0.15),
                child: Text(
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
            user?.fullName ?? 'Administrator',
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

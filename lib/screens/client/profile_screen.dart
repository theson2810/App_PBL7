import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onSwitchApp;

  const ProfileScreen({super.key, required this.onSwitchApp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            _ProfileHeader(onSwitchApp: onSwitchApp),

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
                  const SectionHeader(title: 'Account'),
                  _SettingsGroup(
                    items: [
                      _SettingsItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Personal Information',
                        subtitle: 'Eleanor Vance · eleanor@vitalhorizon.com',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.phonelink_rounded,
                        label: 'Shared Devices',
                        subtitle: 'Manage connected health monitors',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.group_outlined,
                        label: 'Family Members',
                        subtitle: 'Complete your security circle',
                        trailing: StatusBadge.green('3'),
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  const SectionHeader(title: 'Monitoring'),
                  _SettingsGroup(
                    items: [
                      _SettingsItem(
                        icon: Icons.notifications_active_outlined,
                        label: 'Alert Preferences',
                        subtitle: 'Push, SMS & email settings',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.schedule_rounded,
                        label: 'Monitoring Schedule',
                        subtitle: '24/7 continuous monitoring',
                        trailing: StatusBadge.green('ON'),
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.speed_rounded,
                        label: 'AI Sensitivity',
                        subtitle: 'Detection threshold: Medium',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  const SectionHeader(title: 'App'),
                  _SettingsGroup(
                    items: [
                      _SettingsItem(
                        icon: Icons.settings_outlined,
                        label: 'App Settings',
                        subtitle: 'Theme, language & display',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.security_rounded,
                        label: 'Privacy & Security',
                        subtitle: '2FA enabled · Data encrypted',
                        trailing: StatusBadge.green('Secure'),
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        subtitle: 'FAQ, guides & contact support',
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
                        subtitle: 'Sign out of Vital Horizon',
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
          'Are you sure you want to log out? You will stop receiving real-time alerts.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
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
  final VoidCallback onSwitchApp;

  const _ProfileHeader({required this.onSwitchApp});

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
                'Profile',
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
                            'Server',
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
                backgroundColor: Colors.white.withOpacity(0.15),
                child: const Text(
                  'EV',
                  style: TextStyle(
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
          const Text(
            'Eleanor Vance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'eleanor@vitalhorizon.com',
            style: TextStyle(
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

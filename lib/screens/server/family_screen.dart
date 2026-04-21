import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _searchController = TextEditingController();
  List<FamilyMember> _filtered = mockFamilyMembers;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? mockFamilyMembers
          : mockFamilyMembers
              .where((m) =>
                  m.name.toLowerCase().contains(q) ||
                  m.email.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: SubtitleAppBar(
        title: 'Family Management',
        subtitle: 'Manage trusted members & alert recipients',
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invite button
            ElevatedButton.icon(
              onPressed: _showInviteDialog,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Invite Member'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Search
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search members...',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 14),

            // Coverage banner
            GreenBannerCard(
              title: 'Sentinel Coverage',
              subtitle: 'Active monitoring across all registered family members.',
              trailing: const Text(
                '100%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              bottom: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 6,
                  backgroundColor: AppTheme.primaryContainer,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            ),

            // Members list
            SectionHeader(
              title: 'Members (${_filtered.length})',
              trailing: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined, size: 14),
                label: const Text('Manage'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
                itemBuilder: (context, i) => _MemberTile(member: _filtered[i]),
              ),
            ),
            const SizedBox(height: 16),

            // Alert settings
            const SectionHeader(title: 'Alert Delivery Settings'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _AlertSettingRow(
                      icon: Icons.notifications_active_rounded,
                      label: 'Push Notifications',
                      subtitle: 'All family members',
                      enabled: true,
                    ),
                    const Divider(height: 1),
                    _AlertSettingRow(
                      icon: Icons.sms_rounded,
                      label: 'SMS Alerts',
                      subtitle: 'Admin only',
                      enabled: true,
                    ),
                    const Divider(height: 1),
                    _AlertSettingRow(
                      icon: Icons.email_rounded,
                      label: 'Email Digest',
                      subtitle: 'Daily summary',
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: const _InviteSheet(),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final FamilyMember member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final isActive = member.status == MemberStatus.active;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: member.avatarColor,
        child: Text(
          member.initials,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryDark,
          ),
        ),
      ),
      title: Text(
        member.name,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${member.relationship} · ${member.role == MemberRole.admin ? 'Admin' : 'Viewer'}',
        style: const TextStyle(fontSize: 11),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            StatusBadge.green('Active')
          else
            StatusBadge.orange('Pending'),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 18),
        ],
      ),
    );
  }
}

class _AlertSettingRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool enabled;

  const _AlertSettingRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.enabled,
  });

  @override
  State<_AlertSettingRow> createState() => _AlertSettingRowState();
}

class _AlertSettingRowState extends State<_AlertSettingRow> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _InviteSheet extends StatelessWidget {
  const _InviteSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Invite Family Member',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'They will receive an email to join your monitoring circle.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 18),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Relationship',
              prefixIcon: Icon(Icons.people_outline_rounded),
            ),
            items: ['Son', 'Daughter', 'Spouse', 'Other']
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Send Invite'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

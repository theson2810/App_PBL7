import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../localization/app_localization.dart';
import '../../providers/auth_provider.dart';
import '../widgets/add_family_dialog.dart';

class ClientFamilyScreen extends StatefulWidget {
  const ClientFamilyScreen({super.key});

  @override
  State<ClientFamilyScreen> createState() => _ClientFamilyScreenState();
}

class _ClientFamilyScreenState extends State<ClientFamilyScreen> {
  final List<FamilyMember> familyMembers = [];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;
    final userFamilyCode = user?.familyCode;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: SubtitleAppBar(
        title: loc.translate('family_title'),
        subtitle: 'View and manage family connections',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action button
            if (userFamilyCode == null)
              ElevatedButton.icon(
                onPressed: _showJoinFamilyDialog,
                icon: const Icon(Icons.group_add_outlined, size: 18),
                label: Text(loc.translate('join_family')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${loc.translate('family_joined')}!',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                userFamilyCode,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${loc.translate('copy_link')}: $userFamilyCode',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            
            // Family members section
            SectionHeader(
              title: '${loc.translate('family_title')} (${familyMembers.length})',
            ),
            if (familyMembers.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 48,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No family members yet',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: familyMembers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) =>
                      _FamilyMemberTile(member: familyMembers[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showJoinFamilyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => JoinFamilyDialog(
        onJoin: (code) {
          // TODO: Save family code to user via AuthProvider
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).translate('family_joined'),
              ),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {}); // Trigger rebuild to show family code
        },
      ),
    );
  }

  void _copyFamilyCode() {
    final user = context.read<AuthProvider>().user;
    if (user?.familyCode != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context).translate('copy_link')}: ${user!.familyCode}',
          ),
        ),
      );
    }
  }
}

class _FamilyMemberTile extends StatelessWidget {
  final FamilyMember member;

  const _FamilyMemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: member.avatarColor,
        child: Text(
          member.initials,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        member.name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        member.relationship,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Icon(
        member.status == MemberStatus.active
            ? Icons.check_circle_rounded
            : Icons.circle_outlined,
        color: member.status == MemberStatus.active
            ? Colors.green
            : AppTheme.textSecondary,
        size: 20,
      ),
    );
  }
}

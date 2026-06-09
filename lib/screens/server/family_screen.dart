import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localization.dart';
import '../../models/family_member_model.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/family_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/family_join_error_mapper.dart';
import '../../widgets/family_wifi_qr_sheet.dart';
import '../widgets/add_family_dialog.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _familyRepo = FamilyRepository();
  final _searchController = TextEditingController();
  bool _showJoinCode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    await context.read<AuthProvider>().refreshUserProfile();
  }

  Future<void> _createFamily() async {
    final loc = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: loc.translate('my_family_default'));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('create_family_dialog_title')),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: loc.translate('family_group_name'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.translate('create_btn')),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final id = await _familyRepo.createFamily(ctrl.text.trim());
    if (!mounted) return;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('family_create_failed'))),
      );
      return;
    }
    await _refreshProfile();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.translate('family_created')),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _confirmRemoveMember(
    String familyId,
    FamilyMemberModel member,
  ) async {
    final loc = AppLocalizations.of(context);
    final label = member.displayName?.isNotEmpty == true
        ? member.displayName!
        : (member.email ?? member.userId);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('remove_member')),
        content: Text(
          '${loc.translate('remove_member_confirm')}\n\n$label',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: Text(loc.translate('remove_member')),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await _familyRepo.removeFamilyMember(familyId, member.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('member_removed')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapFamilyJoinError(loc, e))),
      );
    }
  }

  Future<void> _inviteByEmail(
    String familyId,
    String name,
    String email,
    String relation,
  ) async {
    final loc = AppLocalizations.of(context);
    try {
      final result = await _familyRepo.inviteMemberByEmail(familyId, email);
      if (!mounted) return;
      final link = result['inviteLink'] ?? '';
      final relationLabel = relation.startsWith('relation_')
          ? loc.translate(relation)
          : relation;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(loc.translate('invite_created_title')),
          content: SelectableText(
            '${loc.translate('invite_email_line')}: $email\n'
            '${loc.translate('invite_relation_line')}: $relationLabel ($name)\n\n'
            '${loc.translate('invite_link_line')}:\n$link\n\n'
            '${loc.translate('invite_approval_hint')}',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: link));
              },
              child: Text(loc.translate('copy_link')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(loc.translate('close')),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('error_prefix')}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;
    final familyId = user?.familyId;
    final joinCode = user?.familyCode;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: SubtitleAppBar(
        title: loc.translate('server_family_title'),
        subtitle: loc.translate('server_family_subtitle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (familyId == null) ...[
              GreenBannerCard(
                title: loc.translate('no_family_banner_title'),
                subtitle: loc.translate('no_family_banner_subtitle'),
                trailing: const Icon(Icons.info_outline_rounded, color: AppTheme.primary),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _createFamily,
                icon: const Icon(Icons.add_home_rounded, size: 18),
                label: Text(loc.translate('create_family_btn')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AddFamilyDialog(
                            onAdd: (name, email, relation) {
                              _inviteByEmail(familyId, name, email, relation);
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: Text(loc.translate('invite_gmail_otp')),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => FamilyWifiQrSheet.show(
                  context,
                  familyId: familyId,
                ),
                icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                label: Text(loc.translate('wifi_show_qr')),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                ),
              ),
              const SizedBox(height: 10),
              if (joinCode != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(loc.translate('join_code')),
                  subtitle: Text(
                    _showJoinCode ? joinCode : '••••••',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: Icon(
                          _showJoinCode
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() => _showJoinCode = !_showJoinCode);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: _showJoinCode
                            ? () async {
                                await Clipboard.setData(
                                  ClipboardData(text: joinCode),
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(loc.translate('join_code_copied')),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              SectionHeader(title: loc.translate('pending_join_requests')),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _familyRepo.joinRequests(familyId),
                builder: (context, snap) {
                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return Text(
                      loc.translate('no_pending_requests'),
                      style: const TextStyle(color: AppTheme.textSecondary),
                    );
                  }
                  return Column(
                    children: snap.data!.docs.map((d) {
                      final m = d.data();
                      final src = m['source'] as String? ?? 'join_code';
                      final srcLabel = src == 'email_invite'
                          ? loc.translate('source_email_invite')
                          : loc.translate('source_join_code');
                      return Card(
                        child: ListTile(
                          title: Text(m['requesterEmail']?.toString() ?? ''),
                          subtitle: Text(
                            '${m['requesterName'] ?? ''}\n$srcLabel',
                            style: const TextStyle(height: 1.35),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  try {
                                    await _familyRepo.acceptJoinRequest(d.id);
                                    await _refreshProfile();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.translate('request_accepted')),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${loc.translate('error_prefix')}: $e'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await _familyRepo.rejectJoinRequest(d.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.translate('request_rejected')),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${loc.translate('error_prefix')}: $e'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              SectionHeader(title: loc.translate('members_section')),
              StreamBuilder<List<FamilyMemberModel>>(
                stream: _familyRepo.getMembers(familyId),
                builder: (context, snapshot) {
                  final all = snapshot.data ?? [];
                  final q = _searchController.text.toLowerCase();
                  final filtered = q.isEmpty
                      ? all
                      : all.where((m) {
                          final hay =
                              '${m.email} ${m.displayName} ${m.userId}'.toLowerCase();
                          return hay.contains(q);
                        }).toList();

                  return Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: loc.translate('search_members_hint'),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(loc.translate('no_members_yet')),
                        )
                      else
                        Card(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, indent: 56),
                            itemBuilder: (context, i) {
                              final m = filtered[i];
                              final label = m.displayName?.isNotEmpty == true
                                  ? m.displayName!
                                  : (m.email ?? m.userId);
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    label.isNotEmpty ? label[0].toUpperCase() : '?',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                title: Text(label),
                                subtitle: Text('${m.role} · ${m.status}'),
                                trailing: m.role == 'admin'
                                    ? Chip(
                                        label: Text(loc.translate('admin_badge')),
                                        visualDensity: VisualDensity.compact,
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                          Icons.person_remove_outlined,
                                          color: AppTheme.errorColor,
                                        ),
                                        tooltip: loc.translate('remove_member'),
                                        onPressed: () => _confirmRemoveMember(
                                          familyId,
                                          m,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

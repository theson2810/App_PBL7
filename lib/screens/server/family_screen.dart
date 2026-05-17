import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/family_member_model.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/family_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../widgets/add_family_dialog.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _familyRepo = FamilyRepository();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    await context.read<AuthProvider>().refreshUserProfile();
  }

  Future<void> _createFamily() async {
    final ctrl = TextEditingController(text: 'My family');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo nhóm gia đình'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Tên nhóm'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tạo')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final id = await _familyRepo.createFamily(ctrl.text.trim());
    if (!mounted) return;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tạo được (có thể bạn đã là admin của một nhóm khác).')),
      );
      return;
    }
    await _refreshProfile();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tạo nhóm gia đình'), backgroundColor: Colors.green),
    );
  }

  Future<void> _inviteByEmail(String familyId, String name, String email, String relation) async {
    try {
      final result = await _familyRepo.inviteMemberByEmail(familyId, email);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Lời mời đã tạo'),
          content: SelectableText(
            'Email: $email\n'
            'Quan hệ: $relation ($name)\n\n'
            'Liên kết mời (gửi cho thành viên, kèm trong email / tin nhắn):\n${result['inviteLink']}\n\n'
            'Sau khi thành viên đăng nhập đúng Gmail và gửi token trong app, họ vẫn nằm trong hàng đợi — bạn duyệt Accept/Reject giống yêu cầu tham gia bằng mã nhóm.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: result['inviteLink'] ?? ''));
              },
              child: const Text('Sao chép link'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final familyId = user?.familyId;
    final joinCode = user?.familyCode;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: SubtitleAppBar(
        title: 'Family Management',
        subtitle: 'Một admin / nhóm — duyệt thành viên & mời qua Gmail + OTP',
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
                title: 'Chưa có nhóm gia đình',
                subtitle: 'Admin tạo một nhóm duy nhất. Bạn sẽ nắm familyId và mã tham gia 6 số.',
                trailing: const Icon(Icons.info_outline_rounded, color: AppTheme.primary),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _createFamily,
                icon: const Icon(Icons.add_home_rounded, size: 18),
                label: const Text('Tạo nhóm gia đình'),
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
                      label: const Text('Mời qua Gmail + OTP'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (joinCode != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mã tham gia (6 số)'),
                  subtitle: Text(joinCode, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: joinCode));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã sao chép mã')),
                      );
                    },
                  ),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Family ID'),
                subtitle: SelectableText(familyId, style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 8),
              const SectionHeader(title: 'Yêu cầu tham gia (chờ duyệt)'),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _familyRepo.joinRequests(familyId),
                builder: (context, snap) {
                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return const Text('Không có yêu cầu chờ duyệt', style: TextStyle(color: AppTheme.textSecondary));
                  }
                  return Column(
                    children: snap.data!.docs.map((d) {
                      final m = d.data();
                      final src = m['source'] as String? ?? 'join_code';
                      final srcLabel = src == 'email_invite' ? 'Lời mời email' : 'Mã nhóm';
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
                                        const SnackBar(content: Text('Đã chấp nhận')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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
                                        const SnackBar(content: Text('Đã từ chối')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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
              const SectionHeader(title: 'Thành viên'),
              StreamBuilder<List<FamilyMemberModel>>(
                stream: _familyRepo.getMembers(familyId),
                builder: (context, snapshot) {
                  final all = snapshot.data ?? [];
                  final q = _searchController.text.toLowerCase();
                  final filtered = q.isEmpty
                      ? all
                      : all.where((m) {
                          final hay = '${m.email} ${m.displayName} ${m.userId}'.toLowerCase();
                          return hay.contains(q);
                        }).toList();

                  return Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Tìm thành viên...',
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Không có thành viên'),
                        )
                      else
                        Card(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
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
                                    ? const Chip(label: Text('Admin'), visualDensity: VisualDensity.compact)
                                    : null,
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

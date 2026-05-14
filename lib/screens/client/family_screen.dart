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
import '../widgets/add_family_dialog.dart';

class ClientFamilyScreen extends StatefulWidget {
  const ClientFamilyScreen({super.key});

  @override
  State<ClientFamilyScreen> createState() => _ClientFamilyScreenState();
}

class _ClientFamilyScreenState extends State<ClientFamilyScreen> {
  final _familyRepo = FamilyRepository();
  final _tokenCtrl = TextEditingController();

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitJoinRequest(String code) async {
    try {
      await _familyRepo.requestJoinFamily(code.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi yêu cầu. Admin sẽ duyệt bạn sớm.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gửi yêu cầu: $e')),
      );
    }
  }

  Future<void> _acceptEmailInvite() async {
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập token từ liên kết mời trong email')),
      );
      return;
    }
    try {
      await _familyRepo.acceptEmailInvite(token);
      if (!mounted) return;
      _tokenCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi yêu cầu. Admin duyệt xong bạn sẽ vào được nhóm.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;
    final familyId = user?.familyId;
    final familyCode = user?.familyCode;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: SubtitleAppBar(
        title: loc.translate('family_title'),
        subtitle: 'Mã gia đình, yêu cầu tham gia và lời mời qua email',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (familyId == null) ...[
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _familyRepo.myPendingJoinRequests(),
                builder: (context, snap) {
                  final pending = snap.data?.docs.isNotEmpty == true;
                  if (!pending) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GreenBannerCard(
                      title: 'Đang chờ admin duyệt',
                      subtitle:
                          'Bạn đã gửi yêu cầu (mã nhóm hoặc lời mời email). Admin chấp nhận sau bạn mới vào nhóm.',
                      trailing: const Icon(Icons.hourglass_top_rounded, color: AppTheme.primary),
                    ),
                  );
                },
              ),
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => JoinFamilyDialog(
                    onJoin: (code) => _submitJoinRequest(code),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Gửi yêu cầu tham gia (mã / ID gia đình)'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Lời mời qua email (link)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sau khi bấm link mời trên Gmail, dán token (tham số t=...) vào đây. Bạn vẫn phải chờ admin chấp nhận lần nữa.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tokenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Token từ link mời',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _acceptEmailInvite,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Gửi yêu cầu từ lời mời email'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
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
                            'ID: $familyId',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                          if (familyCode != null)
                            Text(
                              'Mã: $familyCode',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      onPressed: () async {
                        final text = '$familyId ${familyCode ?? ''}'.trim();
                        await Clipboard.setData(ClipboardData(text: text));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã sao chép')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionHeader(title: loc.translate('family_title')),
              StreamBuilder<List<FamilyMemberModel>>(
                stream: _familyRepo.getMembers(familyId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  final members = snapshot.data ?? [];
                  if (members.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('Chưa có thành viên')),
                      ),
                    );
                  }
                  return Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final m = members[i];
                        final label = m.displayName?.isNotEmpty == true
                            ? m.displayName!
                            : (m.email ?? m.userId);
                        return ListTile(
                          title: Text(label),
                          subtitle: Text('${m.role} · ${m.status}'),
                          trailing: m.role == 'admin'
                              ? const Chip(label: Text('Admin'), visualDensity: VisualDensity.compact)
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localization.dart';
import '../../models/family_member_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invite_link_provider.dart';
import '../../providers/wifi_join_link_provider.dart';
import '../../repositories/family_repository.dart';
import '../../services/wifi_network_service.dart';
import '../../utils/family_join_error_mapper.dart';
import 'family_wifi_qr_scan_screen.dart';
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
  bool _processingInvite = false;
  bool _processingWifiJoin = false;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<InviteLinkProvider>().ensureRestored();
      await context.read<WifiJoinLinkProvider>().ensureRestored();
      if (!mounted) return;
      if (context.read<InviteLinkProvider>().hasPendingInvite) {
        _tryConsumeInviteLink();
      }
      if (context.read<WifiJoinLinkProvider>().hasPendingWifiJoin) {
        _tryConsumeWifiJoinLink();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.read<InviteLinkProvider>().hasPendingInvite) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryConsumeInviteLink());
    }
    if (context.read<WifiJoinLinkProvider>().hasPendingWifiJoin) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryConsumeWifiJoinLink());
    }
  }

  Future<void> _tryConsumeWifiJoinLink() async {
    if (_processingWifiJoin || !mounted) return;
    final wifi = context.read<WifiJoinLinkProvider>();
    final sessionId = wifi.pendingSessionId;
    if (sessionId == null || sessionId.isEmpty) return;

    final loc = AppLocalizations.of(context);
    if (!context.read<AuthProvider>().isAuthenticated) return;
    if (context.read<AuthProvider>().user?.familyId != null) return;

    wifi.consumeSessionId();
    _processingWifiJoin = true;

    final permitted = await WifiNetworkService.instance.ensurePermissions();
    if (!permitted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('wifi_permission_denied'))),
        );
      }
      _processingWifiJoin = false;
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('wifi_join_processing'))),
    );

    try {
      await _familyRepo.joinFamilyViaWifiSession(sessionId);
      if (!mounted) return;
      await context.read<AuthProvider>().reloadUserProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('wifi_join_success')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapFamilyJoinError(loc, e))),
      );
    } finally {
      _processingWifiJoin = false;
    }
  }

  Future<void> _openWifiQrScanner() async {
    final joined = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const FamilyWifiQrScanScreen()),
    );
    if (joined == true && mounted) {
      await context.read<AuthProvider>().reloadUserProfile();
    }
  }

  Future<void> _tryConsumeInviteLink() async {
    if (_processingInvite || !mounted) return;
    final invite = context.read<InviteLinkProvider>();
    final token = invite.pendingToken;
    if (token == null || token.isEmpty) return;

    final loc = AppLocalizations.of(context);
    if (!context.read<AuthProvider>().isAuthenticated) {
      return;
    }

    invite.consumeToken();
    _processingInvite = true;
    _tokenCtrl.text = token;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('invite_processing'))),
    );

    try {
      await _familyRepo.acceptEmailInvite(token);
      if (!mounted) return;
      await context.read<AuthProvider>().reloadUserProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('invite_accepted')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('invite_invalid')}: $e')),
      );
    } finally {
      _processingInvite = false;
    }
  }

  Future<void> _submitJoinRequest(String code) async {
    final loc = AppLocalizations.of(context);
    try {
      await _familyRepo.requestJoinFamily(code.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('pending_admin_subtitle')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('error_prefix')}: $e')),
      );
    }
  }

  Future<void> _acceptEmailInvite() async {
    final loc = AppLocalizations.of(context);
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('invite_token_required'))),
      );
      return;
    }
    try {
      await _familyRepo.acceptEmailInvite(token);
      if (!mounted) return;
      _tokenCtrl.clear();
      await context.read<AuthProvider>().reloadUserProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('invite_accepted')),
          backgroundColor: Colors.green,
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
    final familyCode = user?.familyCode;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: SubtitleAppBar(
        title: loc.familyTitle,
        subtitle: loc.translate('family_subtitle'),
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
                      title: loc.translate('pending_admin_approval'),
                      subtitle: loc.translate('pending_admin_subtitle'),
                      trailing: const Icon(
                        Icons.hourglass_top_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                  );
                },
              ),
              ElevatedButton.icon(
                onPressed: _openWifiQrScanner,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                label: Text(loc.translate('wifi_scan_join')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                loc.translate('wifi_same_network_hint'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => JoinFamilyDialog(
                    onJoin: (code) => _submitJoinRequest(code),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(loc.translate('send_join_request')),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                loc.translate('email_invite_section'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                loc.translate('email_invite_help'),
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tokenCtrl,
                decoration: InputDecoration(
                  labelText: loc.translate('invite_token_label'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _acceptEmailInvite,
                icon: const Icon(Icons.verified_outlined),
                label: Text(loc.translate('submit_email_invite')),
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
                              '${loc.translate('family_code')}: $familyCode',
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
                          SnackBar(content: Text(loc.translate('copied'))),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionHeader(title: loc.familyTitle),
              StreamBuilder<List<FamilyMemberModel>>(
                stream: _familyRepo.getMembers(familyId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final members = snapshot.data ?? [];
                  if (members.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(loc.translate('no_members_yet'))),
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
                              ? Chip(
                                  label: Text(loc.translate('admin_badge')),
                                  visualDensity: VisualDensity.compact,
                                )
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
